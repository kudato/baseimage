#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2181

# Build docker image from ./Dockerfile
# set DOCKER_HUB_IMAGE for push image to docker hub

# Variables:
#   required:
#      SOURCE
#      TAGS
#   optional:
#      IMAGE_INIT
#      IMAGE_CMD

source scripts/lib.sh

#   DOCKER_HUB_IMAGE
#   TRAVIS_COMMIT
#   TAGS
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

defaultEnv TRAVIS_COMMIT=dev
defaultEnv IMAGE_INIT=entrypoint.sh
defaultEnv IMAGE_CMD="/bin/bash"
name=$(replace "${SOURCE}" ":" "-")

echo "Building.."
docker build -t "${name}" \
    --build-arg image="${SOURCE}" \
    --build-arg cmd="${IMAGE_CMD}" \
    --build-arg init="${IMAGE_INIT}" .

if [[ "${?}" != "0" ]]
then
    echo "Build failed"
    exit 1
fi
echo "Build complete"

if [[ -n "${DOCKER_HUB_IMAGE}" ]]
then
    for i in $(set_tags "${name}")
    do
        docker push "${DOCKER_HUB_IMAGE}:${i}"
        docker push "${DOCKER_HUB_IMAGE}:${TRAVIS_COMMIT:0:7}-${i}"
    done
fi

exit 0

