#!/usr/bin/env bash

# $1 - new function name; $2+ - function with args; No return.
curry() {
    local new f args; new=${1}; shift; f=${1}; shift; args=${*}
    eval $"${new}() { ${f} ${args} \${*}; }"
}

# $1 - delimiter; return - left side of $2.
getLeft() { echo "${2%${1}*}"; }

# $1 - delimiter; return - right side of $2.
getRight() { echo "${2#*${1}}"; }

# $1 - var name as string; return - value of $1 variable.
getEnv() { echo "${!1}"; }

# $1 - function name as string; $2 - list of strings;
# $3 - optional delimiter; return - stdouts array.
map() {
    local delimiter=" "
    if [[ -n "${3}" ]]
    then
        delimiter="${3}"
    fi

    local index array result
    declare -a array result
    OLDIFS=${IFS}; IFS=${delimiter}
    read -ra array <<< "${2}"
    IFS=${OLDIFS}
    index=0
    for item in "${array[@]}"
    do
        result[${index}]=$(${1} "${item}")
        ((index+=1))
    done
    echo "${result[*]}"
    unset array result
}

# export VAR with VAR2 value or default value.
# $1 - VAR2,VAR=default_value, or VAR=default_value.
defaultEnv() {
    local vars name value; value=$(getRight "=" ${1})
    vars=$(getLeft "=" "${1}"); name=${vars##*,}
    for v in $(map "echo" "${vars}" ",")
    do
        local curr; curr=$(getEnv "${v}")
        if [[ -n "${curr}" ]]
        then
            value="${curr}"
        fi
    done
    export "${name}"="${value}"
}

# $1     - first key; $2 - second key; return - key=value array.
searchEnv() {
    declare -a result; local index=0
    for item in $(env | sort)
    do
        if getLeft "=" "${item}" | grep "${1}" | grep "${2}" &>/dev/null
        then
            result[${index}]=${item}
            ((index+=1))
        fi
    done
    echo "${result[@]}"
}

# $1     - first Key;
# $2     - second Key;
# return - array of values ​​found.
searchEnv.keys() {
    curry _getKey getLeft "="; map "_getKey" "$(searchEnv "${1}" "${2}")"
}

# $1     - first key;
# $2     - second key;
# return - array of values ​​found.
searchEnv.values() {
    curry _getValue getRight "="; map "_getValue" "$(searchEnv "${1}" "${2}")"
}

# $* - command with args;
runThread() {
    if [[ -f "${1}" ]]
    then
        chmod +x "${1}"
    fi
    local cmd pid
    cmd=${1}; shift
    "${cmd}" ${@} > /proc/1/fd/1 2>/proc/1/fd/2 &
    pid=${!}
    _ESH_THREADS="${pid} ${_ESH_THREADS}"
}

# return - 1 if at least one thread fails, else 0.
waitThreads() {
    for i in ${_ESH_THREADS}
    do
        if ! wait "${i}"
        then
            unset _ESH_THREADS
            return 1
        fi
    done
    unset _ESH_THREADS
    return 0
}

# Checks exists ENVIRONMENT or ENVIRONMENT NAME variables
# and adds it values to the end of the VAULT_PATH variable.
vault_check_environment() {
    defaultEnv ENVIRONMENT,ENVIRONMENT_NAME=''
    if [[ -n "${ENVIRONMENT_NAME}" ]]
    then
        if [[ "${ENVIRONMENT_NAME}" != "$(getRight "/" "${VAULT_PATH}")" ]]
        then
            export VAULT_PATH="${VAULT_PATH}/${ENVIRONMENT_NAME}"
        fi
    fi
}

vault_request_base()  {
    curl -s \
         -H "Accept: application/json" \
         -H "X-Vault-Token: ${VAULT_TOKEN}" \
         -X GET "${1}"
}

vault_request_v1() {
    vault_request_base "${VAULT_ADDR}/v1/secret/${VAULT_PATH}" \
    | jq '.data | to_entries | map([.key, .value]|join("___"))|join(" ")'
}

vault_request_v2() {
    vault_request_base "${VAULT_ADDR}/v1/secret/data/${VAULT_PATH}" \
    | jq '.data | .data | to_entries | map([.key, .value]|join("___"))|join(" ")'
}

vault_load_env() {
    vault_check_environment

    local data
    if [[ "${VAULT_KV_VERSION}" == "1" ]]
    then
        data=$(vault_request_v1)
    elif [[ "${VAULT_KV_VERSION}" == "2" ]]
    then
        data=$(vault_request_v2)
    fi

    if [[ -z "${data}" ]]
    then
        echo "Failed retrieving data from Vault."
        exit 1
    fi
    for var in ${data:1:${#data}-2}; do
        export "${var%___*}"="${var#*___}"
    done
}

# $1 - name (required); $2 - uid; $3 - user shell.
create_user() {
    local home user uid; home=/home/${1}
    user=${1}; uid=${2}; shell=${3}
    if ! grep "${user}" "/etc/passwd" &>/dev/null
    then
        if [[ ! -d "${home}" ]]; then mkdir -p "${home}"; fi
        addgroup --gid "${uid}" "${user}" \
        && adduser -s "${shell}" \
           --disabled-password \
           --home "${home}" \
           --ingroup "${user}" \
           --no-create-home \
           --uid "${uid}" \
           "${user}" \
        && chown -R "${user}":"${user}" "${home}"
        if [[ "${PWD}" != "/" ]]
        then
            chown -R "${user}":"${user}" "${PWD}"
        fi
    fi
}

setup_userspace() {
    for var in \
        CMD_USER=root \
        CMD_USER_UID=1009 \
        USER_SHELL=/bin/bash \
        TZ=UTC
    do
        defaultEnv ${var}
    done
}

setup_timezone() {
    if [[ -f "/etc/localtime" ]]; then rm "/etc/localtime"; fi
    cp "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
    echo "${TZ}" > "/etc/timezone"
}

init_func() {
    for i in $(searchEnv.values _INIT _SCRIPT)
    do
        runThread ${i}
    done

    if [[ -d /init ]]
    then
        for i in /init/*.sh
        do
            runThread "${i}"
        done
    fi

    if ! waitThreads
    then
    	echo "Start failed!"
    	exit 1
    fi
}

main_func() {
    setup_userspace
    setup_timezone
    init_func
}

if [[ "${1}" != "--import" ]]
then
    if [[ -n "${VAULT_TOKEN}" ]] \
    && [[ -z "${VAULT_DISABLE}" ]]
    then
        vault_load_env
    fi

    main_func
    if [[ -n "${CMD_USER}" ]] \
    && [[ "${CMD_USER}" != "root" ]]
    then
        create_user "${CMD_USER}" "${CMD_USER_UID}" "${USER_SHELL}"
    	set -- su-exec "${CMD_USER}" "$@"
    fi
    exec "$@"
fi
