#!/usr/bin/env bash
source /usr/bin/lib.sh

if [[ -n "${VAULT_TOKEN}" ]] \
&& [[ -z "${VAULT_DISABLED}" ]]
then
	source /usr/bin/vault.sh
fi

for i in \
    TZ=UTC \
    _TZ_LINUX_CONFIG_FILE=/etc/timezone \
    _TZ_CONFIG_FILE=/etc/localtime \
    _TZ_DATA_FILES=/usr/share/zoneinfo \
    _USER_DEFAULT_SHELL=/bin/bash \
    _LASTUID=1001
do
    defaultEnv "${i}"
done

if [[ -f "${_TZ_CONFIG_FILE}" ]]
then rm "${_TZ_CONFIG_FILE}"; fi

echo "${TZ}" > "${_TZ_LINUX_CONFIG_FILE}"
cp "${_TZ_DATA_FILES}/${TZ}" "${_TZ_CONFIG_FILE}"

# $1 - name (required);
# $2 - uid;
# $3 - user shell.
createUser() {
    local home=/home/${1}
    local uid=${2}
    local shell=${3}

    _userUidSeq() {
        local new_uid
        new_uid=${_LASTUID}
        ((new_uid+=1))
        export _LASTUID=${new_uid}
        echo "${new_uid}"
    }

    if ! grep "${1}" "/etc/passwd"
    then
        if [[ ! -d "${home}" ]]; then mkdir -p "${home}"; fi
        if [[ -z "$2" ]]; then uid=$(_userUidSeq); fi
        if [[ -z "$3" ]]; then shell=${_USER_DEFAULT_SHELL}; fi

        adduser -s "${shell}" -D -u "${uid}" "${1}" \
        && chown -R "${1}":"${1}" "${home}"
        if [[ "${PWD}" != "/" ]]
        then
            chown -R "${1}":"${1}" "${PWD}"
        fi
    fi
}

if [[ -n "${CMD_USER}" ]]
then
	createUser "${CMD_USER}" "${CMD_USER_UID}"
	set -- su-exec "${CMD_USER}" "$@"
fi

for i in $(searchEnv.values INIT_ SCRIPT)
do
    runThread "${i}"
done

if ! waitThreads
then
	echo "Init script failed"
	exit 1
fi

exec "$@"
