#!/usr/bin/env bash
ESH_SCRIPT=/usr/bin/entrypoint.sh
source "${ESH_SCRIPT}" --import

test_entrypoint_as_default() {
    local exitcode; ${ESH_SCRIPT} test -n 1; exitcode=${?}
    assertEquals "${exitcode}" "0"
}

test_entrypoint_as_user() {
    local user test_user; user=testuser328
    export CMD_USER=${user}
    test_user=$(${ESH_SCRIPT} whoami)
    assertEquals "${user}" "${test_user}"
    unset CMD_USER
}

test_entrypoint_as_user_uid() {
    local uid test_uid; uid=1033
    export CMD_USER=test525 CMD_USER_UID=${uid}
    test_uid=$(${ESH_SCRIPT} id -u)
    assertEquals "${uid}" "${test_uid}"
    unset CMD_USER CMD_USER_UID
}

test_entrypoint_timezone() {
    local tzv test_tz; tzv=Europe/Moscow; export TZ=${tzv}
    test_tz=$(${ESH_SCRIPT} cat /etc/timezone)
    assertEquals "${tzv}" "${test_tz}"
    unset TZ
}

test_entrypoint_init_file() {
    local file result_file test_init
    file=/tmp/initfile.sh; result_file=/tmp/initfile
    printf '#!/usr/bin/env bash\necho "012345" >> /tmp/initfile' > "${file}"
    export TEST_INIT_SCRIPT=${file}; test_init=$(${ESH_SCRIPT} cat ${result_file})
    assertEquals "${test_init}" "012345"; rm "${file}" "${result_file}"
    unset TEST_INIT_SCRIPT
}

test_curry() {
    curry test_curry_f echo FOOOOOO=BARRRRR
    assertEquals "$(test_curry_f)" "FOOOOOO=BARRRRR"
    unset -f test_curry_f
}

test_getLeft() {
    assertEquals "$(getLeft "=" "a=1")" "a"
}

test_getRight() {
    assertEquals "$(getRight "=" "a=1")" "1"
}

test_getEnv() {
    export FOOOOOOOO=baaaaarrrrrrrr
    assertEquals "$(getEnv FOOOOOOOO)" "baaaaarrrrrrrr"
    unset FOOOOOOOO
}

test_map() {
    assertEquals \
        "$(map "echo" "FOOOOOO BARRRRR BAZZZZZ")" "FOOOOOO BARRRRR BAZZZZZ"
}

test_defaultEnv_case1() {
    export BARRRRR=baaaaazzzzz
    defaultEnv "FOO,BARRRRR,TEST=12"
    assertEquals "${TEST}" "baaaaazzzzz"
    unset TEST BARRRRR
}

test_defaultEnv_case2() {
    export BARRRRR=baaaaazzzzz
    defaultEnv "FOO,BAR,TEST=12"
    assertEquals "${TEST}" "12"
    unset TEST BARRRRR
}


test_defaultEnv_case3() {
    export BARRRRR=baaaaazzzzz
    defaultEnv "BARRRRR,FOO,TEST=12"
    assertEquals "${TEST}" "baaaaazzzzz"
    unset TEST BARRRRR
}

test_searchEnv() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals \
        "$(searchEnv BAR RRRR)" "BARRRRR2=12345 BARRRRR=baaaaazzzzz"
    unset BARRRRR BARRRRR2
}

test_searchEnv_keys() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals "$(searchEnv.keys BAR RRRR)" "BARRRRR2 BARRRRR"
    unset BARRRRR BARRRRR2
}

test_searchEnv_values() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals "$(searchEnv.values BAR RRRR)" "12345 baaaaazzzzz"
    unset BARRRRR BARRRRR2
}

test_Threads_positive_file() {
    local file; file=/tmp/positive.sh
    printf '#!/usr/bin/env bash\nexit 0' > "${file}"
    runThread "${file}"; waitThreads &>/dev/null
    assertEquals "${?}" "0"
    rm ${file}
}

test_Threads_negative_file() {
    local file; file=/tmp/negative.sh
    printf '#!/usr/bin/env bash\nexit 1' > "${file}"
    runThread "${file}"; waitThreads &>/dev/null
    assertEquals "${?}" "1"
    rm ${file}
}

test_Threads_onesec_file() {
    local file; file=/tmp/onesec_file.sh
    printf '#!/usr/bin/env bash\nsleep 1\nexit 0' > "${file}"
    runThread "${file}"; waitThreads &>/dev/null
    assertEquals "${?}" "0"
    rm ${file}
}

test_Threads_positive_function() {
    runThread "exit" "0"; waitThreads &>/dev/null;
    assertEquals "${?}" "0"
}

test_Threads_negative_function() {
    runThread "exit" "1"; waitThreads &>/dev/null
    assertEquals "${?}" "1"
}

test_vault_request_v1() {
    vault_request_base()  {
        echo '{"request_id":"string","lease_id":"","renewable":false,"lease_duration":540000000,"data":{"FOO":"BAR","BAZ":"FOO"},"wrap_info":null,"warnings":null,"auth":null}'
    }
    assertEquals "$(vault_request_v1)" '"FOO___BAR BAZ___FOO"'
}

test_vault_request_v2() {
    vault_request_base() {
        echo '{"request_id":"string","lease_id":"","renewable":false,"lease_duration":0,"data":{"data":{"FOO":"BAR","BAZ":"FOO"},"metadata":{"created_time":"2020-01-05T22:48:18.115870241Z","deletion_time":"","destroyed":false,"version":12}},"wrap_info":null,"warnings":null,"auth":null}'
    }
    assertEquals "$(vault_request_v2)" '"FOO___BAR BAZ___FOO"'
}

test_vault_load_env_v1() {
    vault_request_base()  {
        echo '{"request_id":"string","lease_id":"","renewable":false,"lease_duration":540000000,"data":{"FOO":"BAR","BAZ":"FOO"},"wrap_info":null,"warnings":null,"auth":null}'
    }
    export VAULT_KV_VERSION=1
    vault_load_env
    assertEquals "$(getEnv FOO)_$(getEnv BAZ)" "BAR_FOO"
    unset VAULT_KV_VERSION FOO BAZ
    unset -f vault_request_base
}

test_vault_load_env_v2() {
    vault_request_base() {
        echo '{"request_id":"string","lease_id":"","renewable":false,"lease_duration":0,"data":{"data":{"FOO":"BAR","BAZ":"FOO"},"metadata":{"created_time":"2020-01-05T22:48:18.115870241Z","deletion_time":"","destroyed":false,"version":12}},"wrap_info":null,"warnings":null,"auth":null}'
    }
    export VAULT_KV_VERSION=2
    vault_load_env
    assertEquals "$(getEnv FOO)_$(getEnv BAZ)" "BAR_FOO"
    unset VAULT_KV_VERSION FOO BAZ
    unset -f vault_request_base
}

source shunit2