FROM node:6.17-alpine

ENV \
    TZ=UTC \
    LANG=en_US.UTF-8

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
    && chmod +x \
            /usr/bin/entrypoint.sh \
            /usr/bin/healthcheck.sh

HEALTHCHECK \
    --start-period=5s \
    --interval=10s \
    --timeout=10s \
    --retries=3 \
    CMD /usr/bin/healthcheck.sh

ENTRYPOINT [ "tini", "--", "/usr/bin/entrypoint.sh" ]
