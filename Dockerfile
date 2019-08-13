ARG image=alpine:3.9
FROM ${image}

ARG init
ENV TZ=UTC \
    LANG=en_US.UTF-8

COPY scripts/lib.sh \
     scripts/vault.sh \
     scripts/entrypoint.sh \
     scripts/healthcheck.sh \
     scripts/${init} \
     /usr/bin/

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
    && chmod +x /usr/bin/*.sh

HEALTHCHECK \
    --start-period=30s \
    --interval=15s \
    --timeout=10s \
    --retries=3 \
    CMD /usr/bin/healthcheck.sh

ENTRYPOINT [ "tini", "--", "/usr/bin/entrypoint.sh" ]
