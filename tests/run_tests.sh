#!/usr/bin/env bash

# Install this
for i in \
    lib.sh \
    entrypoint.sh \
    healthcheck.sh
do
    if [[ -f "/usr/bin/${i}" ]]
    then sudo rm "/usr/bin/${i}"; fi
    sudo cp "scripts/${i}" "/usr/bin/${i}"
    sudo chmod +x "/usr/bin/${i}"
done

# Test
cd tests || exit
for testf in $(echo ./test_*)
do
    chmod +x "${testf}"
    ${testf}
done
