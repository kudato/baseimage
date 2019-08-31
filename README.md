# [baseimage](https://github.com/kudato/baseimage/blob/master/Dockerfile) [![Build Status](https://travis-ci.org/kudato/baseimage.svg?branch=master)](https://travis-ci.org/kudato/baseimage)


```ENTRYPOINT``` with [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec) to run as user, ```INIT_SCRIPT``` for custom init script, some healthchecks types and more.


| Tags                             | FROM             |                              |
| -------------------------------- | ---------------- | -------------------------------- |
| ```latest``` | [```alpine:latest```](https://hub.docker.com/_/alpine) | [![](https://images.microbadger.com/badges/image/kudato/baseimage.svg)](https://microbadger.com/images/kudato/baseimage) |
| ```alpine```, ```alpine3.10``` | [```alpine:3.10```](https://hub.docker.com/_/alpine)  | [![](https://images.microbadger.com/badges/image/kudato/baseimage:alpine.svg)](https://microbadger.com/images/kudato/baseimage:alpine) |
| ```python```, ```python3.7``` | [```pyhton:3.7-alpine```](https://hub.docker.com/_/python) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:python.svg)](https://microbadger.com/images/kudato/baseimage:python) |
| ```python3.6``` | [```pyhton:3.6-alpine```](https://hub.docker.com/_/python) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:python.svg)](https://microbadger.com/images/kudato/baseimage:python3.6) |
| ```php-cli```, ```php7-cli``` | [```php:7-cli-alpine```](https://hub.docker.com/_/php) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:php-cli.svg)](https://microbadger.com/images/kudato/baseimage:php-cli) |
| ```php-fpm```, ```php7-fpm``` | [```php:7-fpm-alpine```](https://hub.docker.com/_/php) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:php-fpm.svg)](https://microbadger.com/images/kudato/baseimage:php-fpm) |
| ```php5-cli``` | [```php:5-cli-alpine```](https://hub.docker.com/_/php) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:php5-cli.svg)](https://microbadger.com/images/kudato/baseimage:php5-cli) |
| ```php5-fpm``` | [```php:5-fpm-alpine```](https://hub.docker.com/_/php) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:php5-fpm.svg)](https://microbadger.com/images/kudato/baseimage:php5-fpm) |
| ```node6``` | [```node:6-alpine```](https://hub.docker.com/_/node/) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:node6.svg)](https://microbadger.com/images/kudato/baseimage:node6) |
| ```node8``` | [```node:8-alpine```](https://hub.docker.com/_/node/) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:node8.svg)](https://microbadger.com/images/kudato/baseimage:node8) |
| ```docker``` | [```docker:latest```](https://hub.docker.com/_/docker) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:docker.svg)](https://microbadger.com/images/kudato/baseimage:docker) |
| ```nginx``` | [```nginx:alpine```](https://hub.docker.com/_/docker) | [![](https://images.microbadger.com/badges/image/kudato/baseimage:nginx.svg)](https://microbadger.com/images/kudato/baseimage:nginx) |
