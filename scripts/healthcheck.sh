#!/bin/bash

source /usr/bin/lib.sh

EXITCODE=0

checkHealthy() {
    # ------------------------------------------
    # Checks exit codes healthcheck tasks
    # ------------------------------------------
    # $1 - value.
    # ------------------------------------------
    # return - None
    # ------------------------------------------
    if [[ "${1}" != "0" ]]
    then
        export EXITCODE=1
    fi
}

runChecks() {
    # ------------------------------------------
    # Runs all healthchecks in background.
    # ------------------------------------------
    for type in \
        SCRIPT,"runFile" \
        HTTP,"checkHttpCode" \
        TCP,"checkTCP" \
        UDP,"checkUDP" \
        SOCKET,"checkSocket" \
        PIDFILE,"checkPidfile"
    do
        local envName
        envName=$(getLeft "," "${type}")
        for task in $(filterEnvValues "HEALTHCHECK" "${envName}")
        do
            bgStart "$(getRight "," "${type}")" "${task}" &>/dev/null
        done
    done
}

runChecks && bgWait
for code in ${BG_TASKS_EXITCODES}
do
    checkHealthy "${code}"
done
exit "${EXITCODE}"
