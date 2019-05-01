# baseimage

Image ```kudato/baseimage:latest``` is designed to be an lightweight, ready-to-use base for various docker images.

## Features

- This is a regular alpine image with Installed: ```bash```, ```tzdata```, ```jq ```  and ```curl```;
- ```ENTRYPOINT``` runs ```CMD``` via [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) as ```${CMD_USER}```, if not set ```CMD_USER```  ```CMD``` run as ```root```;
- Configuring via variable environments;
- Optionally run initialization script;
- Optionally receive env-vars from [Vault KV Version 1/2](https://www.vaultproject.io/docs/secrets/kv/index.html).

## Use

Minimal Dockerfile example:
```dockerfile
FROM kudato/baseimage:latest
CMD [ "tail", "-f", "/dev/null" ]
```

### Set up:
- ```TZ``` - set timezone, default is ```UTC```;
- ```INIT``` - path to shell-script executed before running cmd;
- ```CMD_USER``` - ```CMD``` owner, will be created if it does not exist, default root;
- ```USER_UID``` - ```CMD_USER``` uid, default ```1001```

-----

Receive env-vars from [Vault KV Version 1/2](https://www.vaultproject.io/docs/secrets/kv/index.html).
Set ```VAULT_ENABLED``` to ```True``` for enable.
Required config:

- ```VAULT_KV_VERSION``` - ```1``` or ```2```;
- ```VAULT_TOKEN``` - your read-only token;
- ```VAULT_ADDR``` - example: ```http://127.0.0.1:8200```;
- ```VAULT_PATH``` - example: ```secret/project```.
