#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2181
#zset -x
#      SOURCE
#      TAGS

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

echo "Building.."
defaultEnv TRAVIS_COMMIT=dev

name=$(replace "${SOURCE}" ":" "-")
file_name="$(getRight "," "${TAGS}").sh"
path_file="scripts/${file_name}"
if [[ -f "${path_file}" ]]
then
    export IMAGE_INIT="${file_name}"
else
    defaultEnv IMAGE_INIT=entrypoint.sh
fi

docker build -t "${name}" \
    --build-arg image="${SOURCE}" \
    --build-arg image_init="${IMAGE_INIT}" .

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
        docker push "${DOCKER_HUB_IMAGE}:${tag}-${TRAVIS_COMMIT:0:7}"
        docker push "${DOCKER_HUB_IMAGE}:${i}"
        echo "Push ${DOCKER_HUB_IMAGE}:${i} complete"
    done
fi
exit 0