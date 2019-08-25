ARG image
FROM ${image}

ARG cmd
ARG init=entrypoint.sh
ENV IMAGE_CMD=${cmd} \
    IMAGE_INIT=${init} \
    LANG=en_US.UTF-8 \
    TZ=UTC


COPY scripts/entrypoint.sh \
     scripts/environment.sh \
     scripts/healthcheck.sh \
     scripts/${init} \
     scripts/lib.sh \
     /usr/bin/

RUN \
    delgroup ping \
    && addgroup -g 998 ping \
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

