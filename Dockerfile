FROM alpine:3.9

ENV \
    DOCKER_GID=999      \
    TZ=UTC

COPY entrypoint.sh /usr/bin/
COPY scripts /usr/bin/

RUN \
    # re-creating the ping group with a different id
    # since on the host this identifier may belong to the docker user
    delgroup ping \
    && addgroup -g 998 ping \
    #
    && apk add --no-cache \
        bash \
        tzdata \
        jq \
        curl \
        ca-certificates \
        su-exec \
        tini \
    && chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT [ "tini", "--", "/usr/bin/entrypoint.sh" ]
