#!/usr/bin/env bash

# $1     - length;
# return - random string.
random() { < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c"${1:-"${1}"}"; echo; }

# No args.
# return  - uuid4.
uuid4() { cat /proc/sys/kernel/random/uuid; }

# $1 - string.
# return - length string.
length() { echo -n "${*}" | wc -c; }

# $1 - function name;
# $* - carrying function with args;
# No return
curry() {
    local new f args
    new=${1}; shift
    f=${1}; shift
    args=${*}
    eval $"${new}() { ${f} ${args} \${*}; }"
}

# $1 - delimiter;
# return - left side of $2.
getLeft() { echo "${2%${1}*}"; }

# $1 - delimiter;
# return - right side of $2.
getRight() { echo "${2#*${1}}"; }

# replace $2 to $3 in $1.
replace() { echo "${1//${2}/${3}}"; }

# replace $2 to $3 in File, $1 is path.
replaceInFile() { sed -i "s/${2}/:${3}:/g" "${1}"; }

# return - $1 repeated $2 times.
repeat() {
    local index
    declare -a array
    index=0
    for _ in $(seq "${2}")
    do
        array[${index}]="${1}"
        ((index+=1))
    done
    echo "${array[@]}"
    unset array
}

# $1     - function name as string;
# $2     - list of strings;
# $3     - optional delimiter;
# return - stdouts array.
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

# $1     - var name as string;
# return - value of $1 variable.
getEnv() { echo "${!1}"; }

# export VAR with VAR2 value or default value.
# $1     - VAR2,VAR=default value; or
#        - VAR=default value.
defaultEnv() {
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

# $1     - first key;
# $2     - second key;
# return - key=value array.
searchEnv() {
    declare -a result
    local index=0
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
    curry _getKey getLeft "="
    map "_getKey" "$(searchEnv "${1}" "${2}")"
}

# $1     - first key;
# $2     - second key;
# return - array of values ​​found.
searchEnv.values() {
    curry _getValue getRight "="
    map "_getValue" "$(searchEnv "${1}" "${2}")"
}

# $* - function with args;
runThread() {
    if [[ -f "${1}" ]]
    then
        chmod +x "${1}"
    fi
    local pid
    "${@}" &>/dev/null &
    pid=${!}
    F_THREADS="${pid} ${F_THREADS}"
}

# return - 1 if at least one thread fails, else 0.
waitThreads() {
    for i in ${F_THREADS}
    do
        if ! wait "${i}"
        then
            unset F_THREADS
            return 1
        fi
    done
    unset F_THREADS
    return 0
}

# $1 - name (required);
# $2 - uid;
# $3 - user shell.
createUser() {
    local home=/home/${1}
    local uid=${2}
    local shell=${3}

    _userUidSeq() {
        local new_uid
        new_uid=${_LASTUID}
        ((new_uid+=1))
        export _LASTUID=${new_uid}
        echo "${new_uid}"
    }

    if ! grep "${1}" "/etc/passwd"
    then
        if [[ ! -d "${home}" ]]; then mkdir -p "${home}"; fi
        if [[ -z "$2" ]]; then uid=$(_userUidSeq); fi
        if [[ -z "$3" ]]; then shell=${_USER_DEFAULT_SHELL}; fi

        addgroup --gid "${uid}" "${1}"
        adduser -s "${shell}" \
           --disabled-password \
           --home "${home}" \
           --ingroup "${1}" \
           --no-create-home \
           --uid "${uid}" \
           "${1}" \
        && chown -R "${1}":"${1}" "${home}"
        if [[ "${PWD}" != "/" ]]
        then
            chown -R "${1}":"${1}" "${PWD}"
        fi
    fi
}
