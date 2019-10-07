#!/usr/bin/env bash
source /usr/bin/lib.sh

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
    for check in $(searchEnv.values "HEALTHCHECK" "$(getLeft "," "${type}")")
    do
        runThread "$(getRight "," "${type}")" "${check}"
    done
done

if [[ -d /healthcheck ]]; then
    for i in /healthcheck/*.sh; do
        runThread "${i}"
    done
fi

if ! waitThreads
then
    exit 1
fi
exit 0
