#!/bin/bash
set_tz() {
    if [ -f "/etc/localtime" ]; then rm /etc/localtime; fi
    cp "/usr/share/zoneinfo/${1}" /etc/localtime
    echo "${1}" > /etc/timezone
}

set_tz "${TZ}"
