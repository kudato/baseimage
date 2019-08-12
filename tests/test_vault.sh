#!/usr/bin/env bash
source ../scripts/lib.sh

export \
    VAULT_TOKEN=test
    VAULT_ADDR=test
    VAULT_PATH=test
    ENVIRONMENT=test


get_secrets() { source ../scripts/vault.sh; }

# mock vault_request
mock_vault_request_v1() {
    cat <<EOF
{
    "auth": null,
    "data": {
      "FOO": "bar",
      "BAR": "baz"
    },
    "lease_duration": 3600,
    "lease_id": "",
    "renewable": false
}
EOF
}

mock_vault_request_v2() {
    cat <<EOF
{
    "data": {
      "data": {
          "FOO": "bar",
          "BAR": "baz"
      },
      "metadata": {
        "created_time": "2018-03-22T02:24:06.945319214Z",
        "deletion_time": "",
        "destroyed": false,
        "version": 1
      }
    }
}
EOF
}

test_vault_v1() {
    export VAULT_CUSTOM_REQUEST_FUNC="mock_vault_request_v1"
    get_secrets
    assertEquals "$(getEnv FOO)" "bar"
    assertEquals "$(getEnv BAR)" "baz"
}

test_vault_v2() {
    export \
        VAULT_CUSTOM_REQUEST_FUNC="mock_vault_request_v2" \
        VAULT_KV_VERSION=2
    get_secrets
    assertEquals "$(getEnv FOO)" "bar"
    assertEquals "$(getEnv BAR)" "baz"
}

source shunit2