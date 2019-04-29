#!/bin/bash

# checks is set required variables
if [ -z "${VAULT_TOKEN}" ] \
 | [ -z "${VAULT_ADDR}" ] \
 | [ -z "${VAULT_PATH}" ]
then
    echo "ERROR! Vault is enabled, but required variables are not set."
    exit 2
fi

request_data() {
    echo $(curl -s \
                -H "Accept: application/json" \
                -H "X-Vault-Token: ${VAULT_TOKEN}" \
                -X GET $1)
}

# for version 1 of kv-storage
if [ -z "${VAULT_KV_VERSION}" ] | [ "${VAULT_KV_VERSION}" == "1" ]
then
    secret_data=$(request_data "${VAULT_ADDR}/v1/secret/${VAULT_PATH}" \
                  | jq '.data | to_entries | map([.key, .value]|join("="))|join(" ")')

# for version 2 of kv-storage
elif [ "${VAULT_KV_VERSION}" == "2" ]
then
    secret_data=$(request_data "${VAULT_ADDR}/v1/secret/data/${VAULT_PATH}" \
                  | jq '.data | .data | to_entries | map([.key, .value]|join("="))|join(" ")')

# error handling
else
    echo "ERROR! Wrong version of the secrets engine."
    echo "Please set version 1 or 2 to VAULT_KV_VERSION variable"
    exit 2
fi

if [ "${secret_data}" == "" ]; then
    echo "ERROR! Received data has failed or either Vault is empty"
    exit 1
fi

# exporting received secrets in environment variables
for var in $(echo ${secret_data:1:${#secret_data}-2}); do
    export $var
done
