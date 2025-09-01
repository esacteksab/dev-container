#!/bin/bash

export DATE
# abbreviated git tag
export TAG
TAG="$(git describe --tags --abbrev=0)"
DATE="$(date +'%Y-%m-%d')"
# containerize that shit
docker build -t esacteksab/dev-container:"${DATE}" .
docker tag esacteksab/dev-container:"${DATE}" esacteksab/dev-container:"${TAG}"

docker push esacteksab/dev-container:"${DATE}"
