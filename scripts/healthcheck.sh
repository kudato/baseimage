#!/bin/bash
source ./lib.sh

for type in \
    SCRIPT,"runFile" \
    HTTP,"checkHttpCode" \
    TCP,"checkTCP" \
    UDP,"checkUDP" \
    SOCKET,"checkSocket" \
    PIDFILE,"checkPidfile"
do
    for task in $(searchEnv.Values "HEALTHCHECK" "$(getLeft "," "${type}")")
    do
        bgStart "$(getRight "," "${type}")" "${task}" &>/dev/null
    done
done

bgWait
for code in ${BG_TASKS_EXITCODES}
do
    if [[ "${code}" != "0" ]]
    then
        exit 1
    fi
done
exit 0
