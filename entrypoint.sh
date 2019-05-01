#!/bin/bash

if [ "${VAULT_ENABLED}" == "True" ]; then source /usr/bin/vault.sh; fi

if [ -f "/etc/localtime" ]; then rm /etc/localtime; fi
cp /usr/share/zoneinfo/${TZ} /etc/localtime
echo "${TZ}" > /etc/timezone

if [ -n "${INIT}" ]; then source /usr/bin/init.sh; fi
if [ -n "${CMD_USER}" ]
then
	source /usr/bin/adduser.sh
	exec su-exec ${CMD_USER} $@
else
	exec $@
fi
