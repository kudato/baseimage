#!/bin/bash

# checks is set required vars
if [ -z "${VAULT_TOKEN}" ] \
 | [ -z "${VAULT_ADDR}" ] \
 | [ -z "${VAULT_PATH}" ]
then
    echo "ERROR! Vault is enabled, but required variables are not set."
    exit 2
fi

# default verison
if [ -z "${VAULT_KV_VERSION}" ]
then
    export VAULT_KV_VERSION=1
fi

vault_url() {
    local base

    if [ "${VAULT_KV_VERSION}" == "1" ]
    then
        base=${VAULT_ADDR}/v1/secret/${VAULT_PATH}

    elif [ "${VAULT_KV_VERSION}" == "2" ]
    then
        base=${VAULT_ADDR}/v1/secret/data/${VAULT_PATH}
    fi

    if [ -n "${ENVIRONMENT}" ]
    then
        base=$base/${ENVIRONMENT}
    fi

    echo "$base"
}

vault_request() {
    local response
    response=$(curl -s \
        -H "Accept: application/json" \
        -H "X-Vault-Token: ${VAULT_TOKEN}" \
        -X GET "$(vault_url)")

    echo "$response"
}

if [ "${VAULT_KV_VERSION}" == "1" ]
then
    secret_data=$(vault_request \
                  | jq '.data | to_entries | map([.key, .value]|join("___"))|join(" ")')

elif [ "${VAULT_KV_VERSION}" == "2" ]
then
    secret_data=$(vault_request \
                  | jq '.data | .data | to_entries | map([.key, .value]|join("___"))|join(" ")')

else
    echo "ERROR! Wrong version of the secrets engine."
    echo "Please set version 1 or 2 to VAULT_KV_VERSION variable"
    exit 2
fi

if [ "${secret_data}" == "" ]; then
    echo "ERROR! Received data has failed or either Vault is empty"
    exit 1
fi

for var in ${secret_data:1:${#secret_data}-2}; do
    export ${var%___*}=${var#*___}
done
