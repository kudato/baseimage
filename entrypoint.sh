#!/bin/bash

# checking if vault is enabled
if [ "${VAULT_ENABLED}" == "True" ]; then
    source /usr/bin/vault.sh
fi

# checking the needexec to run the init script
# be careful, the script run as root,
# but the app will be run as APP_USER
if [ -n "${INIT_SH}" ]; then
	source /usr/bin/init.sh
fi


# timezone setup
if [ -f "/etc/localtime" ]; then rm /etc/localtime; fi
cp /usr/share/zoneinfo/${TZ} /etc/localtime
echo "${TZ}" > /etc/timezone

# run using su-exec
# more details - https://github.com/ncopa/su-exec
exec su-exec ${RUN_AS} $@