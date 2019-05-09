#!/bin/bash

# checking if exist script
if [ ! -f "${INIT}" ]; then
    echo "ERROR! You have defined init script, but it is not found."
    exit 2
fi

# run init script
chmod +x "${INIT}"
${INIT_SH}

# checking the exit code of the init script
if [ "$?" -ne "0" ]; then
  echo "${INIT} failed"
  exit 1
fi