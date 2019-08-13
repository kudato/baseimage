#!/usr/bin/env bash
source scripts/lib.sh

# Required vars:
# _INIT_SCRIPT
# DOCKER_HUB_IMAGE
# TAGS
# SOURCE
# IMAGE
# COMMIT_SHA

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
    local name tag tags
    name=$(replace "${SOURCE}" ":" "-")
    docker build -t "${name}" \
         --build-arg IMAGE="${SOURCE} " .

    # push
    for i in $(set_tags "${name}:latest")
    do
        docker push "${DOCKER_HUB_IMAGE}:${i}"
        docker push "${DOCKER_HUB_IMAGE}:${i}-${TRAVIS_COMMIT:0:7}"
    done
}

echo "Building.."
build_and_push
if [[ "${?}" != "0" ]]
then
    echo "Build failing"
    exit 1
fi
echo "Build complete"
exit 0