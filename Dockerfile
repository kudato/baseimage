FROM alpine:3.9

ENV \
    TERM=xterm-color \
    TZ=UTC    \
    APP_USER=app     \
    APP_UID=1001     \
    RUN_AS=app  \
    DOCKER_GID=999

COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY scripts/vault.sh /usr/bin/vault.sh
COPY scripts/init.sh /usr/bin/init.sh

RUN \
    chmod +x /usr/bin/entrypoint.sh \
    && apk add --no-cache \
        bash \
        tzdata \
        jq \
        curl \
        ca-certificates \
        su-exec \
        tini \
    # adding app user
    && mkdir -p /home/${APP_USER} \
    && adduser -s /bin/bash -D -u ${APP_UID} ${APP_USER} \
    && chown -R ${APP_USER}:${APP_USER} /home/${APP_USER} \
    # re-creating the ping group with a different id
    # since on the host this identifier may belong to the docker user
    && delgroup ping && addgroup -g 998 ping \
    # creating docker group and adding an APP_USER to it
    && addgroup -g ${DOCKER_GID} docker && addgroup ${APP_USER} docker \
    # creating additional dir's
    && mkdir -p /srv && chown -R ${APP_USER}:${APP_USER} /srv

WORKDIR /srv
ENTRYPOINT [ "/sbin/tini", "--", "/usr/bin/entrypoint.sh" ]
