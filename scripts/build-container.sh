#!/bin/bash

export DOCKER_BUILDKIT=1
export DATE
# abbreviated git tag
export TAG
TAG="$(git rev-parse --short HEAD)"
DATE="$(date +'%Y-%m-%d-%H-%M')"
# containerize that shit
docker build -t esacteksab/dev-container:"${DATE}" .
docker tag esacteksab/dev-container:"${DATE}" esacteksab/dev-container:"${TAG}"

# docker push esacteksab/dev-container:"${DATE}"
