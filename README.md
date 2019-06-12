# baseimage [![Build Status](https://drone.kudato.com/api/badges/kudato/baseimage/status.svg)](https://drone.kudato.com/kudato/baseimage)

Is designed to be an lightweight, ready-to-use base for various docker images.

## Features

- Runs ```CMD``` via [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) as ```CMD_USER```, if not set in env runs as ```root```.

- Official images with a few changes;
- Configuring via environment variables;
- Optionally, run the init script by set path for it in the ```INIT``` variable;
- Optionally, get environment variables from [Vault KV Version 1/2](https://www.vaultproject.io/docs/secrets/kv/index.html).

## Usage

### Getting started

The image is called ```kudato/baseimage```, and is available on the Docker registry.

Minimal Dockerfile example:

```dockerfile
FROM kudato/baseimage:latest
CMD [ "tail", "-f", "/dev/null" ]
```

There are several images that differ in the main image and are available by tags:

| Tags                                                         | Based on                    |
| ------------------------------------------------------------ | --------------------------- |
| ```latest```, ```3.9```                                      | ```alpine:3.9```            |
| ```python```, ```python-3.7```, ```python-3.7-alpine3.9```   | ```pyhton:3.7-alpine3.9```  |
| ```python-3.6```, ```python-3.6-alpine3.9```                 | ```pyhton:3.6-alpine3.9```  |
| ```php-cli```, ```php-cli-7.3```, ```php-cli-7.3-alpine3.9``` | ```php:7.3-cli-alpine3.9``` |
| ```php-fpm```, ```php-fpm-7.3```, ```php-fpm-7.3-alpine3.9``` | ```php:7.3-fpm-alpine3.9``` |
| ```php-cli-7.2```, ```php-cli-7.2-alpine3.9```               | ```php:7.2-cli-alpine3.9``` |
| ```php-fpm-7.2```, ```php-fpm-7.2-alpine3.9```               | ```php:7.2-fpm-alpine3.9``` |
| ```node-6.17```, ```node-6.17-alpine3.9```                   | ```node:6.17-alpine```      |
| ```node-8.16```, ```node-8.16-alpine3.9```                   | ```node:8.16-alpine```      |
| ```node-10.15```, ```node-10.15-alpine3.9```                 | ```node:10.15-alpine```     |
| ```node-11.15```, ```node-11.15-alpine3.9```                 | ```node:11.15-alpine```     |
| ```node-12.1```, ```node-12.1-alpine3.9```                   | ```node:12.1-alpine```      |
| ```docker-18.09```, ```docker-18.09-alpine3.9```                   | ```docker:18.09```      |


### Environment variables

```ENV NAME=value``` in Dockerfile or ```-e NAME=value``` when command line using.

#### Base settings

- ```TZ``` - set up timezone, default set is ```UTC```;
- ```CMD_USER``` - ```CMD``` owner, will be created if it does not exist, default root;
- ```USER_UID``` - ```CMD_USER``` uid, default ```1001```

#### Initialization

To add an initialization script, specify the path to it in the ```INIT``` variable. For additional script, declare a variable with the string ```INIT_SH``` in the name. 

#### Healthchecks

As in the case of the ```INIT``` to add a health check you need to declare the variable ```HEALTHCHECK``` and for additional check add ```HEALTHCHECK_SH``` containing variable. 

In addition or instead of the script, you can also add:

- ```HEALTHCHECK_PIDFILE=/path/to/pidfile``` - check process with ```kill -0 ```
- ```HEALTHCHECK_SOCKET=/path/to/sockfile``` - check socket availability

- ```HEALTHCHECK_HTTP=url,response_code``` - checks the response code with curl;
- ```HEALTHCHECK_TCP=host:port``` - check TCP-connectivity with netcat;
- ```HEALTHCHECK_UDP=host:port``` - check UDP-connectivity with netcat.

All checks run in parallel, and the script ends with code 1 if at least one of them fails. Runs every 10 seconds, the total timeout for all checks is also 10 seconds.

#### Vault

All values from VAULT_URL will be imported into environment variables if the following variables are defined:

- ```VAULT_KV_VERSION``` to ```1``` or ```2```, default set is ```1```;
- ```VAULT_ADDR``` - Vault server address;
- ```VAULT_TOKEN``` - access token;
- ```VAULT_PATH``` - path to secrets in *Vault*.

if ```ENVIRONMENT``` is defined, its value is added to the end of ```VAULT_PATH```.

Runs on container starting. All received keys and values ​​will be exported to environment variables before running the ```INIT``` script and ```CMD```.
