#!/bin/bash

grep "${CMD_USER}" /etc/passwd >/dev/null
if [ $? -ne 0 ]
then
    if [ -z "${USER_UID}" ]; then export USER_UID=1001; fi
    adduser -s /bin/bash -D -u ${USER_UID} ${CMD_USER}
    export _USER_PATH=/home/${CMD_USER} && mkdir -p ${_USER_PATH}
    if [ "${PWD}" != "/" ]
    then
        export _USER_PATH="${_USER_PATH} ${PWD}"
    fi
    chown -R ${CMD_USER}:${CMD_USER} ${_USER_PATH}
fi
