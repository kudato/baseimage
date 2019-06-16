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
    if ! grep "${1}" /etc/passwd
    then
        if [ ! -d "${path}" ]; then mkdir -p "$path"; fi

        if [ -z "$2" ]
        then
            local uid
            uid=$(uid_counter)
        else
            local uid
            uid=$2
        fi

        if [ -z "$3" ]
        then
            local shell
            shell=/bin/bash
        else
            local shell
            shell=$3
        fi

        adduser -s "${shell}" -D -u "${uid}" "${1}" \
        && chown -R "${1}":"${1}" "${path}"
    fi
}
