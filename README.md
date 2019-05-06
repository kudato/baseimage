# baseimage [![Build Status](https://drone.kudato.com/api/badges/kudato/baseimage/status.svg)](https://drone.kudato.com/kudato/baseimage)

Is designed to be an lightweight, ready-to-use base for various docker images.



## Features

```ENTRYPOINT``` runs ```CMD``` via [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) as ```CMD_USER```, if not set in env runs as ```root```.

- Official images with a few changes;
- Configuring via environment variables;
- Optionally, get environment variables from [Vault KV Version 1/2](https://www.vaultproject.io/docs/secrets/kv/index.html).
- Optionally, run the initialization script by set path for it in the ```INIT``` variable;



### Available tags

```latest```, ```3.9``` - based on ```alpine:3.9```, all other images are different only one instruction:

- ```python```, ```python-3.7```, ```python-3.7-alpine3.9``` - ```FROM pyhton:3.7-alpine3.9```;
- ```python-3.6```, ```python-3.6-alpine3.9``` - ```FROM pyhton:3.6-alpine3.9```;

- ```php-cli```, ```php-cli-7.3```, ```php-cli-7.3-alpine3.9``` - ```FROM php:7.3-cli-alpine3.9```;

- ```php-fpm```, ```php-fpm-7.3```, ```php-fpm-7.3-alpine3.9``` - ```FROM php:7.3-fpm-alpine3.9```;

- ```php-cli-7.2```, ```php-cli-7.2-alpine3.9``` - ```FROM php:7.2-cli-alpine3.9```;

- ```php-fpm-7.2```, ```php-fpm-7.2-alpine3.9``` - ```FROM php:7.2-fpm-alpine3.9```.

- ```node-6.17```, ```node-6.17-alpine3.9``` - ```FROM node:6.17-alpine```;

- ```node-8.16```, ```node-8.16-alpine3.9``` - ```FROM node:8.16-alpine```;

- ```node-10.15```, ```node-10.15-alpine3.9``` - ```FROM node:10.15-alpine```;

- ```node-11.15```, ```node-11.15-alpine3.9``` - ```FROM node:11.15-alpine```;

- ```node-12.1```, ```node-12.1-alpine3.9``` - ```FROM node:12.1-alpine```;

_For create Dockerfile's, run ```python3 make.py``` (python version >= 3.6.8)_



### Usage

Minimal child Dockerfile example:

```dockerfile
FROM kudato/baseimage:latest
CMD [ "tail", "-f", "/dev/null" ]
```

#### Setup

```ENV NAME=value``` in Dockerfile or ```-e NAME=value``` when command line using.

- ```TZ``` - set up timezone, default set is ```UTC```;
- ```INIT``` - path to shell-script run before ```CMD```;
- ```CMD_USER``` - ```CMD``` owner, will be created if it does not exist, default root;
- ```USER_UID``` - ```CMD_USER``` uid, default ```1001```

##### Vault
For enable, set ```VAULT_ENABLED``` to ```True``` and set:

- ```VAULT_KV_VERSION``` to ```1``` or ```2```;
- ```VAULT_TOKEN``` - access token;
- ```VAULT_ADDR``` - address with scheme and port, for example - ```http://127.0.0.1:8200```;
- ```VAULT_PATH``` - path to secrets in *Vault*, for example - ```service/production```.

Runs on container starting. All received keys and values ​​will be exported to environment variables before running the ```INIT``` script and ```CMD```.
