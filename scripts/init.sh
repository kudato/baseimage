#!/bin/bash

init_scripts() {
    local result="${INIT}"
    for script in $(env | grep INIT | grep SH | sort)
    do
      local path=$(echo "$script" | sed -r 's/[^=]+//' | sed 's|=||g')
      local result="${path} ${result}"
    done
    echo $result
}

check_file_exist() {
    if [ ! -f "${1}" ]; then
        echo "ERROR! ${1} is defined, but it is not found."
        exit 2
    fi
}

init_exec() {
    check_file_exist ${1}
    chmod +x ${1}
    ${1}
    if [ "$?" -ne "0" ]; then
        echo "${1} exitcode is $?, executed failed"
        exit 1
    fi
}

for i in $(init_scripts)
do
    init_exec $i
done
