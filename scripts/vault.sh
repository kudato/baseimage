#!/bin/bash

requestEnv.Vault() {
    # ------------------------------------------
    # Get data from Vault KV storage
    # ------------------------------------------
    # $* - None
    # ------------------------------------------
    # return - NAME___VALUE like array
    # ------------------------------------------
    # required env vars:
    #   - VAULT_KV_VERSION
    #   - VAULT_TOKEN
    #   - VAULT_ADDR
    #   - VAULT_PATH
    # ------------------------------------------

    Vault.request() {
        curl -s \
             -H "Accept: application/json" \
             -H "X-Vault-Token: ${VAULT_TOKEN}" \
             -X GET ${VAULT_ADDR}/"${1}"
    }

    local uri=v1/secret
    if [[ "${VAULT_KV_VERSION}" == "1" ]]
    then
        Vault.request "${uri}/${VAULT_PATH}/${ENVIRONMENT}" \
        | jq '.data | to_entries | map([.key, .value]|join("___"))|join(" ")'
    elif [[ "${VAULT_KV_VERSION}" == "2" ]]
    then
        Vault.request "${uri}/data/${VAULT_PATH}/${ENVIRONMENT}" \
        | jq '.data | .data | to_entries | map([.key, .value]|join("___"))|join(" ")'
    fi
}

if [[ -z "${VAULT_ADDR}" ]] \
 | [[ -z "${VAULT_PATH}" ]]
then
    echo "ERROR! Vault is enabled but not configured."
    exit 1
else
	if [[ -z "${VAULT_KV_VERSION}" ]]
    then
        export VAULT_KV_VERSION=1
    fi

	VAULT_RESPONSE=$(requestEnv.Vault)
    if [[ -z "${VAULT_RESPONSE}" ]]
    then
        echo "ERROR! Failed retrieving data from Vault."
        exit 1
    fi
	for var in ${VAULT_RESPONSE:1:${#VAULT_RESPONSE}-2}; do
	    export "${var%___*}"="${var#*___}"
	done
    unset VAULT_RESPONSE
fi
