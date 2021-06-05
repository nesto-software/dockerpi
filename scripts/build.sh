#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

FILESYSTEM_IMAGE_CHECKSUM=0598c22d77eb319398ec99aa8d5229366266f79616b8b7ad17277d9a28feb23f
FILESYSTEM_IMAGE_URL=https://github.com/nesto-software/dockerpi/releases/download/2021-05-07/2021-05-07-raspios-buster-armhf-lite.zip

docker build \
    --build-arg FILESYSTEM_IMAGE_CHECKSUM=$FILESYSTEM_IMAGE_CHECKSUM \
    --build-arg FILESYSTEM_IMAGE_URL=$FILESYSTEM_IMAGE_URL \
    -t nesto/dockerpi \
    "$SCRIPT_DIR/.."
