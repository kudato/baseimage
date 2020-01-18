# baseimage [![Build Status](https://travis-ci.org/kudato/baseimage.svg?branch=master)](https://travis-ci.org/kudato/baseimage)

[Alpine](https://alpinelinux.org)-based baseimage and ```entrypoint.sh``` script with [tini](https://github.com/krallin/tini) and [su-exec](https://github.com/ncopa/su-exec).

# Usage

```Dockerfile
FROM kudato/baseimage:alpine

RUN apk add ...
COPY myscript.sh .

CMD [ "myscript.sh" ]
```

# Supported tags

See on [Docker Hub page.](https://hub.docker.com/repository/docker/kudato/baseimage)

# Environment variables

 - ```TZ``` - set timezone(default ```UTC```);
 - ```CMD_USER``` - specify user(default ```root```);
 - ```CMD_USER_UID``` - specify user uid;
 - ```USER_SHELL``` - specify user;
 - ```[...]_INIT_SCRIPT=path_to_file``` - run script before main command, to run multiple scripts, create variables with unique names for each.

# Tests

 - Install docker and docker-compose;
 - ```export FROM=alpine:latest``` and ```docker-compose up --build```.
