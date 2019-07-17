#!/bin/bash

####################################################
## Functions
####################################################

getLeft() {
    # ------------------------------------------
    # Left side.
    # ------------------------------------------
    # $1 - delimiter;
    # $2 - input string.
    # ------------------------------------------
    # return - string.
    # ------------------------------------------

    echo "${2%${1}*}"
}

getRight() {
    # ------------------------------------------
    # Right side.
    # ------------------------------------------
    # $1 - delimiter;
    # $2 - input string.
    # ------------------------------------------
    # return - string.
    # ------------------------------------------

    echo "${2#*${1}}"
}

curry() {
    # ------------------------------------------
    # Curry function.
    # ------------------------------------------
    # $1     - new function name;
    # $2     - caring function;
    # $3-... - args caring function.
    # ------------------------------------------
    # return - name new function.
    # ------------------------------------------

    local new func args
    new=${1}; shift
    func=${1}; shift
    args=${*}
    eval $"${new}() { ${func} ${args} \${*}; }"
    echo "${new}"
}

# uuid4
curry uuid4 cat /proc/sys/kernel/random/uuid &>/dev/null

uuid() {
    # ------------------------------------------
    # $1 - length.
    # ------------------------------------------

    < /dev/urandom \
    tr -dc A-Z-a-z-0-9 | head -c"${1:-"${1}"}";echo;
}

repeat() {
    # ------------------------------------------
    # $1 repeated $2 times
    # ------------------------------------------
    declare -a array
    local index
    index=0
    for _ in $(seq "${2}")
    do
        result[${index}]=${1}
        ((index+=1))
    done
    echo "${result[@]}"
}

map() {
    # ------------------------------------------
    # This is a map function.
    # ------------------------------------------
    # $1 - function name as string;
    # $2 - space-separated list of strings;
    # $3 - delimiter.
    # ------------------------------------------
    # return - array of the results of the
    # function applied to each item in the list.
    # ------------------------------------------

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
}


####################################################
## Environment
####################################################

getEnv() {
    # ------------------------------------------
    # Get value from environment variable.
    # ------------------------------------------
    # $1 - var name as string.
    # ------------------------------------------
    # return - value of $1 variable.
    # ------------------------------------------

    echo "${!1}"
}

defaultEnv() {
    # ------------------------------------------
    # Checks the existence of each variable in
    # list and exports the first value found
    # with the name of last variable name.
    # ------------------------------------------
    # $1 - VAR1,VAR2,VAR3=default_value,
    # VAR3=value will be exported
    # ------------------------------------------
    # return - None.
    # ------------------------------------------

    local vars name value
    value=$(getRight "=" ${1})
    vars=$(getLeft "=" "${1}")
    name=${vars##*,}
    for v in $(map "echo" "${vars}" ",")
    do
        local curr
        curr=$(getEnv "${v}")
        if [[ -n "${curr}" ]]
        then
            value="${curr}"
        fi
    done
    export "${name}"="${value}"
}

searchEnv() {
    # ------------------------------------------
    # Finds variables by two keys and
    # returns in key=value format.
    # ------------------------------------------
    # $1 - first;
    # $2 - second.
    # ------------------------------------------
    # return - array of values ​​found.
    # ------------------------------------------
    declare -a result
    local index=0
    for item in $(env)
    do
        if getLeft "=" "${item}" | grep "${1^^}" | grep "${2^^}" &>/dev/null
        then
            result[${index}]=${item}
            ((index+=1))
        fi
    done
    echo "${result[@]}"
}

searchEnv.Keys() {
    # ------------------------------------------
    # Finds variables by two keys,
    # returns variable names.
    # ------------------------------------------
    # $1 - first Key;
    # $2 - second Key.
    # ------------------------------------------
    # return - array of values ​​found.
    # ------------------------------------------

    curry "searchEnv.Keys.left" getLeft "=" &> /dev/null
    map "searchEnv.Keys.left" "$(searchEnv "${1}" "${2}")"
}

searchEnv.Values() {
    # ------------------------------------------
    # Finds variables by two keys,
    # returns values.
    # ------------------------------------------
    # $1 - first Key;
    # $2 - second Key.
    # ------------------------------------------
    # return - array of values ​​found.
    # ------------------------------------------

    map "getEnv" "$(searchEnv.Keys "${1}" "${2}")"
}

####################################################
## Execution
####################################################
BG_TASKS_EXITCODES=""
BG_TASKS=""

runFile() {
    # ------------------------------------------
    # Exec file.
    # ------------------------------------------
    # $1 - file path.
    # ------------------------------------------
    # return - "1|${1}:FAILED" and exitcode 1.
    # ------------------------------------------

    if [[ -f "${1}" ]]
    then
        chmod +x "${1}"
        sed -i '1a\source /usr/bin/lib.sh\n' "${1}"
        if ! ${1}
        then
            echo "1|${1}:FAILED"
            return 1
        else
            echo "0|${1}:SUCCESS"
            return 0
        fi
    else
        echo "1|${1}:NOT_FOUND"
        return 1
    fi
}

bgStart() {
    # ------------------------------------------
    # Run in background
    # and write pid to BG_TASKS.
    # ------------------------------------------
    # $1, ... - function with arguments.
    # ------------------------------------------
    # return  - None.
    # ------------------------------------------

    local pid
    "${@}" &
    pid=${!}
    BG_TASKS="${pid} ${BG_TASKS}"
    echo "${pid}"
}

bgWait() {
    # ------------------------------------------
    # Sleep until processes from BG_TASKS
    # run out and export exitcodes to BG_TASKS_EXITCODES.
    # ------------------------------------------
    # ...    - None.
    # ------------------------------------------
    # return - None.
    # ------------------------------------------

    declare -a array result
    OLDIFS=${IFS}; IFS=' '
    read -ra array <<< "${BG_TASKS}"
    IFS=${OLDIFS}

    for i in "${array[@]}"
    do
        wait "${i}"
        result+=("${?}")
    done

    export \
    BG_TASKS_EXITCODES=${result[*]} \
    BG_TASKS=""
}

####################################################
## System
####################################################
TZ_CONFIG_FILE=/etc/localtime
TZ_DATA_FILES=/usr/share/zoneinfo
TZ_LINUX_CONFIG_FILE=/etc/timezone

USERS_HOME=/home
USERS_PASSWD_FILE=/etc/passwd
USERS_DEFAULT_SHELL=/bin/bash
USERS_UID_START_FROM=1001

setTimeZone() {
    # ------------------------------------------
    # $1 - Time zone id.
    # ------------------------------------------
    # return - None.
    # ------------------------------------------
    if [[ -f "${TZ_CONFIG_FILE}" ]]
    then
        rm "${TZ_CONFIG_FILE}"
    fi
    cp "${TZ_DATA_FILES}/${1}" ${TZ_CONFIG_FILE}
    echo "${1}" > "${TZ_LINUX_CONFIG_FILE}"
}

createUser() {
    # ------------------------------------------
    # $1 - name (required);
    # $2 - uid;
    # $3 - user shell.
    # ------------------------------------------
    # return - None.
    # ------------------------------------------
    local home=${USERS_HOME}/${1}
    local uid=${2}
    local shell=${3}

    userUid() {
        local new_uid
        if [[ -z "${LASTUID}" ]]
        then
            export LASTUID="${USERS_UID_START_FROM}"
        fi
        new_uid=${LASTUID}
        ((new_uid+=1))
        export LASTUID="${new_uid}"
        echo "${new_uid}"
    }

    if ! grep "${1}" "${USERS_PASSWD_FILE}"
    then
        if [[ ! -d "${home}" ]]; then mkdir -p "${home}"; fi
        if [[ -z "$2" ]]; then uid=$(userUid); fi
        if [[ -z "$3" ]]; then shell="${USERS_DEFAULT_SHELL}"; fi

        local workdir
        workdir=$(pwd)
        if [[ "${workdir}" == "/" ]]
        then
            workdir=""
        fi
        adduser -s "${shell}" -D -u "${uid}" "${1}" \
        && chown -R "${1}":"${1}" "${home}" "${workdir}"
    fi
}

####################################################
## Checks
####################################################
CHECK_TIMEOUT=15

checkHttpCode() {
    # ------------------------------------------
    # $1 - "http-code,url".
    # ------------------------------------------
    # return - exit code.
    # ------------------------------------------

    local response required url
    url=$(getRight "," "${1}")
    required=$(getLeft "," "${1}")
    response=$(curl -s -m "${CHECK_TIMEOUT}" \
                -o /dev/null -w "%{http_code}" ${url})

    if [[ "${response}" != "${required}" ]]
    then
        return 1
    else
        return 0
    fi
}

checkTcp() {
    # ------------------------------------------
    # Attempts to establish a TCP connection,
    # immediately closes after a successful attempt.
    # ------------------------------------------
    # $1 - url with port;
    # ------------------------------------------
    # return - 1 or 0.
    # ------------------------------------------

    if ! nc -vz -w${CHECK_TIMEOUT} \
         "$(getLeft ":" "${1}")" \
         "$(getRight ":" "${1}")" &>/dev/null
    then
        return 1
    else
        return 0
    fi
}

checkUdp() {
    # ------------------------------------------
    # Attempts to establish a UDP connection,
    # immediately closes after a successful attempt.
    # ------------------------------------------
    # $1 - url with port;
    # ------------------------------------------
    # return - 1 or 0
    # ------------------------------------------

    if ! nc -vzu -w${CHECK_TIMEOUT} \
         "$(getLeft ":" "${1}")" \
         "$(getRight ":" "${1}")" &>/dev/null
    then
        return 1
    else
        return 0
    fi
}

checkTcpSocket() {
    # ------------------------------------------
    # Check availability TCP unix-socket.
    # ------------------------------------------
    # $1 - path to socket;
    # ------------------------------------------
    # return - 1 or 0.
    # ------------------------------------------

    if [[ ! -S "${1}" ]]
    then
        return 1
    else
        if ! ncat -Uvz -w${CHECK_TIMEOUT} "${1}" &>/dev/null
        then
            return 1
        else
            return 0
        fi
    fi
}

checkUdpSocket() {
    # ------------------------------------------
    # Check availability UDP unix-socket.
    # ------------------------------------------
    # $1 - path to socket;
    # ------------------------------------------
    # return - 1 or 0.
    # ------------------------------------------

    if [[ ! -S "${1}" ]]
    then
        return 1
    else
        if ! nc -Uvzu -w${CHECK_TIMEOUT} "${1}" &>/dev/null
        then
            return 1
        else
            return 0
        fi
    fi
}

checkPidfile() {
    # ------------------------------------------
    # Check availability pidfile.
    # ------------------------------------------
    # $1 - path to pidfile;
    # ------------------------------------------
    # return - 1 or 0.
    # ------------------------------------------

    if [[ ! -f "${1}" ]]
    then
        exit 1
    fi
    if ! timeout "${CHECK_TIMEOUT}" \
         kill -0 "$(< "${1}")" &>/dev/null
    then
        return 1
    else
        return 0
    fi
}
