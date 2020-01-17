#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2181

# Script for build docker image.
# Envs:
#   DOCKER_HUB_IMAGE
#   TRAVIS_COMMIT
#   TAGS
#   FROM

source ./entrypoint.sh --import

build_image() {
    local name; name="${FROM//":"/"-"}"
    docker build -t "${name}" --build-arg image="${FROM}" .

    if [[ "${?}" != "0" ]]
    then
        echo "Build failed"
        exit 1
    fi
    echo "Build complete"
}

set_tags() {
    declare -a tags
    OLDIFS=${IFS}; IFS=","
    read -ra tags <<< "$(getRight "=" "$(getEnv TAGS)")"
    IFS=${OLDIFS}
    for tag in "${tags[@]}"
    do
        docker tag "${1}" "${DOCKER_HUB_IMAGE}:${tag}"
        docker tag "${1}" "${DOCKER_HUB_IMAGE}:${tag}-${TRAVIS_COMMIT:0:7}"
    done
    echo "${tags[@]}"
    unset tags
}

push_image() {
    for i in $(set_tags "${FROM//":"/"-"}")
    do
        docker push "${DOCKER_HUB_IMAGE}:${tag}-${TRAVIS_COMMIT:0:7}"
        docker push "${DOCKER_HUB_IMAGE}:${i}"
    done
}

defaultEnv TRAVIS_COMMIT=dev; build_image
if [[ "${TRAVIS_BRANCH}" == "master" ]]
then
    push_image
fi
