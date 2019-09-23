#!/usr/bin/env bash
source /usr/bin/lib.sh

SECRET_ENV_INDEX=0
declare -a SECRET_ENV

addSE() {
    SECRET_ENV[${SECRET_ENV_INDEX}]="${1}"
    ((SECRET_ENV_INDEX+=1))
}

# Vault
if [[ -n "${VAULT_TOKEN}" ]] \
&& [[ -z "${VAULT_DISABLE}" ]]
then
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

    if [[ -n "${ENVIRONMENT}" ]]
    then
        if [[ "${ENVIRONMENT}" != "$(getRight "/" "${VAULT_PATH}")" ]]
        then
            export VAULT_PATH="${VAULT_PATH}/${ENVIRONMENT}"
        fi
    fi

    # $1     - url without VAULT_ADDR;
    # return - json string.
    vault_request_base()  {
        curl -s \
             -H "Accept: application/json" \
             -H "X-Vault-Token: ${VAULT_TOKEN}" \
             -X GET "${@}"
    }

    # return - array of key___value.
    vault_request() {
        local uri=${VAULT_ADDR}/v1/secret

        if [[ "${VAULT_KV_VERSION}" == "1" ]]
        then
            vault_request_base "${uri}/${VAULT_PATH}" \
            | jq '.data | to_entries | map([.key, .value]|join("___"))|join(" ")'

        elif [[ "${VAULT_KV_VERSION}" == "2" ]]
        then
            vault_request_base "${uri}/data/${VAULT_PATH}" \
            | jq '.data | .data | to_entries | map([.key, .value]|join("___"))|join(" ")'
        fi
    }

    _VAULT_DATA=$(vault_request)
    if [[ -z "${_VAULT_DATA}" ]]
    then
        echo "Failed retrieving data from Vault."
        exit 1
    fi
    for var in ${_VAULT_DATA:1:${#_VAULT_DATA}-2}; do
        export "${var%___*}"="${var#*___}"
        addSE "${var%___*}"
    done
    unset _VAULT_DATA
fi

echo "${SECRET_ENV[@]}" > /.senv
