ARG image
FROM ${image}

ENV LANG=en_US.UTF-8 \
    TZ=UTC

RUN delgroup ping \
    && addgroup -g 998 ping \
    && apk add --no-cache \
        bash \
        tzdata \
        jq \
        curl \
        ca-certificates \
        su-exec \
        tini

# --
# Add shunit2
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" \
        >> /etc/apk/repositories \
    && apk add --no-cache shunit2

WORKDIR /usr/bin
COPY entrypoint.sh tests/tests.sh ./
RUN chmod +x /usr/bin/*.sh

ENTRYPOINT [ "tini", "--" ]