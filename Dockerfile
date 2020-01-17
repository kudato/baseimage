ARG image
FROM ${image}

ENV LANG=en_US.UTF-8 \
    TZ=UTC

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh \
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

WORKDIR /src
ENTRYPOINT [ "tini", "--", "/usr/bin/entrypoint.sh" ]