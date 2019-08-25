#!/usr/bin/env bash
source /usr/bin/lib.sh

NGINX_HEALTHCHECK=/healthcheck/nginx.sh
NGINX_CONFIG=/etc/nginx/nginx.conf

for i in \
    NGINX_GZIP=off \
    NGINX_SENDFILE=on \
    NGINX_TCP_NOPUSH=on \
    NGINX_TCP_NODELAY=on \
    NGINX_SERVER_TOKENS=off \
    NGINX_WORKER_PROCESSES=auto \
    NGINX_WORKER_CONNECTIONS=1024 \
    NGINX_DEFAULT_TYPE=application/octet-stream \
    NGINX_CLIENT_MAX_BODY_SIZE=64M \
    NGINX_KEEPALIVE_TIMEOUT=100 \
    NGINX_RESOLVER='1.1.1.1 ' \
    NGINX_RESOLVER_VALID=300s \
    NGINX_RESOLVER_TIMEOUT=60s \
    NGINX_PIDFILE=/var/run/nginx.pid \
    NGINX_CONF_DIR=/conf.d
do
    defaultEnv "${i}"
done

cat <<EOF > ${NGINX_CONFIG}
daemon off;
user nginx;
worker_processes  ${NGINX_WORKER_PROCESSES};
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  ${NGINX_WORKER_CONNECTIONS};
}

http {
	sendfile ${NGINX_SENDFILE};
	tcp_nopush ${NGINX_TCP_NOPUSH};
	tcp_nodelay ${NGINX_TCP_NODELAY};
	server_tokens ${NGINX_SERVER_TOKENS};
	default_type ${NGINX_DEFAULT_TYPE};
	include /etc/nginx/mime.types;
	log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

	gzip  ${NGINX_GZIP};
	keepalive_timeout ${NGINX_KEEPALIVE_TIMEOUT};
	client_max_body_size ${NGINX_CLIENT_MAX_BODY_SIZE};

	resolver ${NGINX_RESOLVER} valid=${NGINX_RESOLVER_VALID};
	resolver_timeout ${NGINX_RESOLVER_TIMEOUT};

	include ${NGINX_CONF_DIR}/*.conf;
}
EOF

if ! [[ -d /conf.d ]]
then
    mkdir /conf.d
fi

if  ! [[ -d /healthcheck ]]
then
    mkdir /healthcheck
fi

cat <<EOF > ${NGINX_HEALTHCHECK}
#!/usr/bin/env bash
source /usr/bin/lib.sh
source /usr/bin/checks.sh

if ! checkPidfile ${NGINX_PIDFILE}
then
    exit 1
fi
exit 0
EOF

chmod +x "${NGINX_HEALTHCHECK}"
exit 0
