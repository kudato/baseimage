#!/usr/bin/env bash
source /usr/bin/lib.sh
source /usr/bin/checks.sh

for type in \
    _SCRIPT,"runFile" \
    _SOCKET,"checkUnixSocket" \
    _HTTP,"checkHTTPCode" \
    _TCP,"checkTCPPort" \
    _UDP,"checkUDPPort" \
    _TCPSOCKET,"checkTCPSocket" \
    _UDPSOCKET,"checkUDPSocket" \
    _PIDFILE,"checkPidfile"
do
    for task in $(searchEnv.values "HEALTHCHECK" "$(getLeft "," "${type}")")
    do
        runThread "$(getRight "," "${type}")" "${task}"
    done
done

if ! waitThreads
then
    exit 1
fi
exit 0
