#!/bin/bash

CHECK_TIMEOUT=10
CHECK_TASKS=""

unhealthy() {
    for process in ${CHECK_TASKS}
    do
        kill -9 $process >/dev/null 2>/dev/null &
    done
    exit 1
}

check_exitcode() {
    if [ "$?" -ne "0" ]
    then
        unhealthy
    fi
}

check_http() {
    local url=$(echo "${1}" | cut -f1 -d",")
    local code=$(echo "${1}" | sed -r 's/[^,]+//' | sed 's|,||g')
    local response=$(curl -s -m ${CHECK_TIMEOUT} -o /dev/null -w "%{http_code}" ${url})
    check_exitcode
    if [ "${response}" != "${code}" ]
    then
          unhealthy
    fi
}

check_tcp() {
    local url=$(echo "${1}" | cut -f1 -d":")
    local port=$(echo "${1}" | sed -r 's/[^:]+//' | sed 's|:||g')
    nc -z -v -w${CHECK_TIMEOUT} $url $port >/dev/null 2>/dev/null
    check_exitcode
}

check_udp() {
    local url=$(echo "${1}" | cut -f1 -d":")
    local port=$(echo "${1}" | sed -r 's/[^:]+//' | sed 's|:||g')
    nc -vzu -w${CHECK_TIMEOUT} $url $port >/dev/null 2>/dev/null
    check_exitcode
}

check_pidfile() {
    if [ ! -f ${1} ]; then unhealthy; fi # if no file
    timeout ${CHECK_TIMEOUT} kill -0 $(cat ${1}) >/dev/null
    check_exitcode
}

check_socket() {
    if [ ! -S ${1} ]
    then
        unhealthy
    fi
}

check_sh() {
    chmod +x $1
    timeout ${CHECK_TIMEOUT} $1
    check_exitcode
}

health_env() {
    echo $(env | grep HEALTHCHECK | grep $1 | sort)
}

env_value() { # $1 is 'EXAMPLE=value' -> value returned
    echo "$1" | sed -r 's/[^=]+//' | sed 's|=||g'
}

check_counter() {
    export CHECK_TASKS="${1} ${CHECK_TASKS}"
}

for i in $(health_env PIDFILE)
do
    if [ $(env_value $i) ]; then
        check_pidfile $(env_value $i) &
        check_counter $!
    fi
done

for i in $(health_env SOCKET)
do
    if [ $(env_value $i) ]; then
        check_socket $(env_value $i) &
        check_counter $!
    fi
done

for i in $(health_env SH)
do
    check_sh $(env_value $i) &
    check_counter $!
done

for i in $(health_env HTTP)
do
    check_http $(env_value $i) &
    check_counter $!
done

for i in $(health_env TCP)
do
    check_tcp $(env_value $i) &
    check_counter $!
done

for i in $(health_env UDP)
do
    check_udp $(env_value $i) &
    check_counter $!
done

for i in ${CHECK_TASKS}
do
    wait $i
    check_exitcode $?
done

exit 0
