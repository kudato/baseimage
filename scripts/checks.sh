#!/usr/bin/env bash
CHECK_TIMEOUT=15

# $1 - url;
HTTPCode() {
    curl -s -m "${CHECK_TIMEOUT}" \
         -o /dev/null -w "%{http_code}" "${1}"
}

# $1 - code,url;
checkHTTPCode() {
    local url
    url=$(getRight "," "${1}")
    if [[ "$(HTTPCode "${url}")" != "$(getLeft "," "${1}")" ]]
    then
        return 1
    else
        return 0
    fi
}

# $1 - url:port;
checkTCPPort() {
    if ! nc -vz -w${CHECK_TIMEOUT} \
         "$(getLeft ":" "${1}")" \
         "$(getRight ":" "${1}")" &>/dev/null
    then
        return 1
    else
        return 0
    fi
}

# $1 - url with port;
checkUDPPort() {
    if ! nc -vzu -w${CHECK_TIMEOUT} \
         "$(getLeft ":" "${1}")" \
         "$(getRight ":" "${1}")" &>/dev/null
    then
        return 1
    else
        return 0
    fi
}

# $1 - path to socket;
checkTCPSocket() {
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

# $1 - path to socket;
checkUDPSocket() {
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

# $1 - path to pidfile;
checkPidfile() {
    echo "444" > /pidchecked
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
