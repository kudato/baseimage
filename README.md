# baseimage [![Build Status](https://drone.kudato.com/api/badges/kudato/baseimage/status.svg)](https://drone.kudato.com/kudato/baseimage)

This project is a wrapper for other base images that adds some features:

- Runs via [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) as non-root user;
- Loading environment variables from [Vault](https://www.vaultproject.io/docs/secrets/kv/index.html) KV.
- Init scripts with additional functions;
- Customizable healthchecks HTTP, TCP, UDP, Sockets, Pidfiles and via custom scripts;
- Configuring via environment vars.


Is designed to be an lightweight, ready-to-use base for various docker images.


## Supported tags

| Tags                                                         | Based on                    |
| ------------------------------------------------------------ | --------------------------- |
| ```latest```, ```alpine3.9```                                      | ```alpine:3.9```            |
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

To avoid updating the image, you can freeze the version by adding the first 7 characters of commit sha to the tag. For example, an image with a ```python-3.7-cdbfaac``` tag will never be changed.

## Read the docs

Documentation: https://baseimage.readthedocs.io