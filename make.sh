#!/bin/bash

set -e

DRONE_CONFIG=.drone.yml
SOURCE_FILE=Dockerfile
VERSION=$(head -n 1 ${SOURCE_FILE} | cut -c13-15)


indent() {
    for (( i=1; i <= 2; i++ )); do
      echo "" >> ${DRONE_CONFIG}
    done
}

init() {
  local header=$(cat <<EOF
kind: pipeline
name: Publish to Docker Hub

steps:
- name: Make
  image: alpine:3.9
  commands:
  - apk add --no-cache bash
  - chmod +x make.sh && ./make.sh
  when:
    branch:
    - master

EOF
)
  echo "${header}" > ${DRONE_CONFIG}
  indent
}

create_pipeline() {
    local body=$(cat <<EOF
- name: $1
  image: plugins/docker
  when:
    branch:
    - master
  settings:
    repo: kudato/baseimage
    dockerfile: ${1}
    username:
      from_secret: docker_username
    password:
      from_secret: docker_password
    tags:

EOF
)
    echo "${body}" >> ${DRONE_CONFIG}
    for tag in $(echo $2); do
      echo "      - ${tag}" >> ${DRONE_CONFIG}
    done
  indent
}

create_dockerfile() {
    local file=${1}/${2}/Dockerfile
    echo $file
    if [ -f "${file}" ]; then return; fi
    if [ ! -d "$1/$2" ]; then mkdir -p $1/$2; fi
    cp ${SOURCE_FILE} $1/$2/Dockerfile
}

make_dockerfiles() {
    for v in $(echo $2)
    do
        case $1 in
             python)
                local tag=${v}-alpine${VERSION}
                local file=$(create_dockerfile $1 ${v})
                sed -i "s|FROM alpine:${VERSION}|FROM $1:${tag}|g" $file
                create_pipeline $file ${1}-${v}
                ;;
             php)
                # cli
                local clitag="${v}-cli-alpine${VERSION}"
                local clifile=$(create_dockerfile $1 ${v}-cli)
                sed -i "s|FROM alpine:${VERSION}|FROM php:${clitag}|g" $clifile
                create_pipeline $clifile ${1}-${v}-cli
                # fpm
                local fpmtag="${v}-fpm-alpine${VERSION}"
                local fpmfile=$(create_dockerfile $1 ${v}-fpm)
                sed -i "s|FROM alpine:${VERSION}|FROM php:${fpmtag}|g" $fpmfile
                create_pipeline $fpmfile ${1}-${v}-fpm
                ;;
        esac
    done
}

init
create_pipeline Dockerfile "latest 3.9"
make_dockerfiles python "3.7 3.6"
make_dockerfiles php "7.3 7.2"
