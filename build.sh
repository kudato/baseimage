#!/usr/bin/env bash
# Required vars:
#   Name=Default
#   DOCKER_HUB_IMAGE=
#   TAGS
#   SOURCE
#   IMAGE
#   COMMIT_SHA
#

source scripts/lib.sh

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

build_and_push() {
    local name
    defaultEnv TRAVIS_COMMIT=dev
    defaultEnv IMAGE_INIT=entrypoint.sh
    name=$(replace "${SOURCE}" ":" "-")
    if [[ -n "${IMAGE_CMD}" ]] \
    && [[ -n "${IMAGE_INIT}" ]]
    then
        docker build -t "${name}" \
            --build-arg image="${SOURCE}" \
            --build-arg cmd="${IMAGE_CMD}" \
            --build-arg init="${IMAGE_INIT}" .

    else
        docker build -t "${name}" \
            --build-arg image="${SOURCE}" .
    fi

    if [[ "${?}" != "0" ]]
    then
        echo "Build failed"
        exit 1
    fi
    if [[ -n "${DOCKER_HUB_IMAGE}" ]]
    then
        for i in $(set_tags "${name}")
        do
            docker push "${DOCKER_HUB_IMAGE}:${i}"
            docker push "${DOCKER_HUB_IMAGE}:${i}-${TRAVIS_COMMIT:0:7}"
        done
    fi
}

echo "Building.."
build_and_push
echo "Build complete"
exit 0