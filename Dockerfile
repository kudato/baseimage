ARG image
FROM ${image}

ARG image_init
ENV IMAGE_INIT=${image_init} \
    LANG=en_US.UTF-8 \
    TZ=UTC

COPY \
    scripts/${IMAGE_INIT} \
    scripts/entrypoint.sh \
    scripts/environment.sh \
    scripts/healthcheck.sh \
    scripts/lib.sh \
    /usr/bin/

RUN chmod +x /usr/bin/*.sh \
    && delgroup ping \
    && addgroup -g 998 ping \
    && apk add --no-cache \
        bash \
        tzdata \
        jq \
        curl \
        ca-certificates \
        su-exec \
        tini

HEALTHCHECK \
    --start-period=25s \
    --interval=10s \
    --timeout=10s \
    --retries=2 \
    CMD /usr/bin/healthcheck.sh

ENTRYPOINT [ "tini", "--", "/usr/bin/entrypoint.sh" ]