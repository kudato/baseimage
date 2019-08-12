#!/bin/bash
source /usr/bin/lib.sh

defaultEnv VAULT_KV_VERSION=1

for var in \
    VAULT_ADDR \
    VAULT_TOKEN \
    VAULT_PATH
do
    if [[ -z "$(getEnv var)" ]]
    then
        echo "Requred variable ${var} is not defined"
        exit 1
    fi
done

# $1     - url without VAULT_ADDR;
# return - json string.
curry vault_request curl -s \
    -H "Accept: application/json" \
    -H "X-Vault-Token: ${VAULT_TOKEN}" \
    -X GET

# return - array of key___value.
vault_response() {
    local uri=${VAULT_ADDR}/v1/secret
    local request_func="vault_request"

    if [[ -n "${VAULT_CUSTOM_REQUEST_FUNC}" ]]
    then
        request_func="${VAULT_CUSTOM_REQUEST_FUNC}"
    fi

    if [[ -n "${ENVIRONMENT}" ]]
    then
        export VAULT_PATH="${VAULT_PATH}/${ENVIRONMENT}"
    fi

    if [[ "${VAULT_KV_VERSION}" == "1" ]]
    then
        "${request_func}" "${uri}/${VAULT_PATH}" \
        | jq '.data | to_entries | map([.key, .value]|join("___"))|join(" ")'

    elif [[ "${VAULT_KV_VERSION}" == "2" ]]
    then
        "${request_func}" "${uri}/data/${VAULT_PATH}" \
        | jq '.data | .data | to_entries | map([.key, .value]|join("___"))|join(" ")'
    fi
}

VAULT_DATA=$(vault_response)
if [[ -z "${VAULT_DATA}" ]]
then
    echo "ERROR! Failed retrieving data from Vault."
    exit 1
fi
for var in ${VAULT_DATA:1:${#VAULT_DATA}-2}; do
    export "${var%___*}"="${var#*___}"
done
unset VAULT_DATA