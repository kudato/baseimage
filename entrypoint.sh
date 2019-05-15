#!/bin/bash

if [ "${VAULT}" == "True" ]
then
	source /usr/bin/vault.sh
fi

source /usr/bin/timezone.sh
source /usr/bin/adduser.sh

if [ -n "${CMD_USER}" ]
then
	create_user ${CMD_USER} ${CMD_USER_UID}
	set -- su-exec ${CMD_USER} $@
fi

source /usr/bin/init.sh
exec $@
