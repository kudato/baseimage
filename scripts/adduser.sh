#!/bin/bash

uid_counter() {
    if [ -z "${LASTUID}" ]; then
        export LASTUID=1001
    fi
    let uid=$((LASTUID + 1))
    export LASTUID=$uid
    echo $uid
}

create_user() { # $1 - name(required), $2 - uid, $3 - shell
    local path=/home/${1}
    grep "${1}" /etc/passwd >/dev/null
    if [ "$?" -ne "0" ]; then
        if [ ! -d "${path}" ]; then mkdir -p $path; fi

        if [ -z "$2" ]
        then
            local uid
            uid=$(uid_counter)
        else
            local uid=$2
        fi
        adduser -s /bin/bash -D -u ${uid} ${1} \
        && chown -R ${1}:${1} ${path}
    fi
}
