#!/usr/bin/env bash
source ../scripts/lib.sh

test_random() {
    for i in \
        4 \
        12 \
        32 \
        4096
    do
        assertNotNull "$(random "${i}")"
    done
}

test_uuid4() {
    for i in \
        4 \
        12 \
        32 \
        4096
    do
        assertNotNull "$(uuid4)"
    done
}

test_length() {
    for i in \
        4 \
        12 \
        32 \
        4096
    do
        assertEquals \
            "$(length "$(random "${i}")")" \
            "${i}"
    done
}

test_curry() {
    curry testFunc echo FOOOOOO=BARRRRR
    assertEquals "$(testFunc)" "FOOOOOO=BARRRRR"
}

test_getLeft() {
    assertEquals "$(getLeft "=" "a=1")" "a"
}

test_getRight() {
    assertEquals "$(getRight "=" "a=1")" "1"
}

test_replace() {
    assertEquals \
        "$(replace '1234' '123' '321')" \
        "3214"
}

test_replaceInFile() {
    local file
    file=/tmp/$(random 4).sh
    printf '#!/usr/bin/env bash\nexit 0' > "${file}"
    replaceInFile "${file}" "exit 0" "exit 1"
    assertEquals \
        "$(replace "$(cat ${file} | sed -n 2p ${file})" ":" "")" \
        "exit 1"
    rm "${file}"
}

test_repeat() {
    assertEquals \
        "$(repeat "AB" 3)" \
        "AB AB AB"
}

test_map() {
    assertEquals \
        "$(map "echo" "FOOOOOO BARRRRR BAZZZZZ")" \
        "FOOOOOO BARRRRR BAZZZZZ"
}

test_getEnv() {
    export FOOOOOOOO=baaaaarrrrrrrr
    assertEquals "$(getEnv FOOOOOOOO)" "baaaaarrrrrrrr"
    unset FOOOOOOOO
}

test_defaultEnv() {
    export BARRRRR=baaaaazzzzz

    defaultEnv "BARRRRR,FOO,TEST=12"
    assertEquals "${TEST}" "baaaaazzzzz"
    unset TEST

    defaultEnv "FOO,BARRRRR,TEST=12"
    assertEquals "${TEST}" "baaaaazzzzz"
    unset TEST

    defaultEnv "FOO,BAR,TEST=12"
    assertEquals "${TEST}" "12"
    unset TEST BARRRRR
}

test_searchEnv() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals \
        "$(searchEnv BAR RRRR)" \
        "BARRRRR2=12345 BARRRRR=baaaaazzzzz"
    unset BARRRRR BARRRRR2
}

test_searchEnv_keys() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals \
        "$(searchEnv.keys BAR RRRR)" \
        "BARRRRR2 BARRRRR"
    unset BARRRRR BARRRRR2
}

test_searchEnv_values() {
    export BARRRRR=baaaaazzzzz BARRRRR2=12345
    assertEquals \
        "$(searchEnv.values BAR RRRR)" \
        "12345 baaaaazzzzz"
    unset BARRRRR BARRRRR2
}

test_Threads() {
    local file file1
    file=/tmp/$(random 4).sh
    file1=/tmp/$(random 4).sh
    printf '#!/usr/bin/env bash\nexit 0' > "${file}"
    printf '#!/usr/bin/env bash\nexit 1' > "${file1}"
    runThread "${file}"
    waitThreads &>/dev/null; assertEquals "${?}" "0"
    runThread "${file1}"
    waitThreads &>/dev/null; assertEquals "${?}" "1"
    rm "${file}" "${file1}"
}

source shunit2