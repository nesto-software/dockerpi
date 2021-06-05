#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONTAINER_NAME=pi
RPI_OS=2021-05-07-raspios-buster-armhf-lite

if [ ! -f "$SCRIPT_DIR/../raspios/$RPI_OS.zip" ]; then
  curl --output-dir "$SCRIPT_DIR/../raspios" --output "${RPI_OS}.zip" "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/$RPI_OS.zip"

  echo "Could not find .img file. Trying to unzip archive..."
  unzip -d "$SCRIPT_DIR/../raspios" "$SCRIPT_DIR/../raspios/$RPI_OS.zip"

  sudo $SCRIPT_DIR/enable-ssh-for-image.sh $SCRIPT_DIR/../raspios/$RPI_OS.img
fi

docker build --target dockerpi-vm -t nesto/dockerpi "$SCRIPT_DIR/.."
docker run --name=$CONTAINER_NAME -v $SCRIPT_DIR/../raspios/$RPI_OS.img:/sdcard/filesystem.img -it --rm -p 5022:5022 nesto/dockerpi pi2

# attach to logs
$SCRIPT_DIR/logs.sh