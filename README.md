# baseimage

The ```kudato/baseimage:latest``` image is designed to be an lightweight, ready-to-production base for creating images of various services.

## Features

- This is a regular alpine image with Installed: ```bash```, ```tzdata```, ```jq ```  and ```curl```;
- Specific ```ENTRYPOINT``` with a wrapper script runs ```CMD``` via [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) as ```app``` user by default;
- To change the user that will run, set the ```RUN_AS``` variable;
- If necessary, runs the initialization script(always run as root) defined via ```INIT_SH``` variable;
- By default, the time zone is set to UTC, override the ```TZ``` variable to set a different value at startup;
- Optionally possible set values to environment variables from [Vault KV Version 1/2](https://www.vaultproject.io/docs/secrets/kv/index.html).

## Example Dockerfile

```dockerfile
FROM kudato/baseimage:latest

ENV TZ="Europe/Amsterdam"
ENV INIT_SH="/srv/configure-nginx.sh"
ENV RUN_AS=root

# If enabled it then all vars required
ENV VAULT_ENABLED=True
ENV VAULT_KV_VERSION=2
ENV VAULT_TOKEN="you vault token"
ENV VAULT_ADDR="http://127.0.0.1:8200"
ENV VAULT_PATH="your/project/secrets"

# Install and configure your apps
RUN apk add --no-cache nginx
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
```

