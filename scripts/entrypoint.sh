#!/usr/bin/env bash
source /usr/bin/environment.sh

for i in \
    TIME_ZONE,TIMEZONE,TZ=UTC \
    _TZ_LINUX_CONFIG_FILE=/etc/timezone \
    _TZ_CONFIG_FILE=/etc/localtime \
    _TZ_DATA_FILES=/usr/share/zoneinfo \
    _USER_DEFAULT_SHELL=/bin/bash \
    _LASTUID=1001
do
    defaultEnv "${i}"
done

if [[ -f "${_TZ_CONFIG_FILE}" ]]; then rm "${_TZ_CONFIG_FILE}"; fi
cp "${_TZ_DATA_FILES}/${TZ}" "${_TZ_CONFIG_FILE}"
echo "${TZ}" > "${_TZ_LINUX_CONFIG_FILE}"

if [[ -n "${CMD_USER}" ]]
then
	createUser "${CMD_USER}" "${CMD_USER_UID}"
	set -- su-exec "${CMD_USER}" "$@"
fi

# -------------------------------------------------------------

if [[ -n "${IMAGE_INIT}" ]] \
&& [[ -n "${IMAGE_CMD}" ]] \
&& [[ -z "${1}" ]]
then
	runThread "${IMAGE_INIT}"
	set -- "$@" "${IMAGE_CMD}"
fi

if [[ -n "${INIT_SCRIPT}" ]]; then runThread "${INIT_SCRIPT}"; fi
for i in $(searchEnv.values SCRIPT _INIT); do runThread "${i}"; done

if ! waitThreads
then
	echo "Init scripts failed"
	exit 1
fi

exec "$@"