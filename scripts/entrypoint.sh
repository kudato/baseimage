#!/bin/bash
source /usr/bin/lib.sh
setTimeZone "${TZ}"

# Load env from Vault:
if [[ -z "${VAULT_DISABLED}" ]] \
&& [[ -n "${VAULT_TOKEN}" ]]
then
	source /usr/bin/vault.sh
fi

# Configure user:
if [[ -n "${CMD_USER}" ]]
then
	createUser "${CMD_USER}" "${CMD_USER_UID}"
	set -- su-exec "${CMD_USER}" "$@"
fi

for result in $(map "runFile" "$(searchEnv.Values INIT_ SCRIPT)")
do
	if [[ "$(getLeft "|" "${result}")" != "0" ]]
	then
		getRight "|" "${result}"
		exit 1
	fi
done
exec "$@"
