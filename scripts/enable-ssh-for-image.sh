#!/bin/bash
# Andrew Oakley aoakley.com Public Domain 2016
# Check out cotswoldjam.org for RPi events in Gloucestershire
# I recommend you place this script in /usr/local/sbin

# Help
if [[ "$1" == "-h" || "$1" == "/?" || "$1" == "--help" ]]; then
  echo "Enables SSH on a Raspbian image from Nov 2016 or later"
  echo "Usage:"
  echo "  sudo `basename $0` [imagename]"
  echo "If imagename is not supplied, downloads the latest version of Raspbian Jessie Lite."
  exit
fi

# Need to be root - we'll be mounting loopback device
if [ "$(id -u)" != 0 ]; then
  echo "You must be root to run this. Try:"
  echo "  sudo `basename $0` $*"
  echo "or"
  echo "  `basename $0` -h"
  echo "for help"
  exit
fi

# Clear up from previous aborted run?
if [[ -e rpi-boot ]]; then
  echo "Please remove 'rpi-boot'"
  exit
fi

if [[ -z "$1" ]]; then
  # No filename? Download latest Jessie Lite.

  # Clear up from previous aborted run, part 2
  if [[ -e rpi-work ]]; then
    echo "Please remove 'rpi-work'"
    exit
  fi

  # Make a working directory and download
  mkdir rpi-work
  cd rpi-work
  curl -L "https://downloads.raspberrypi.org/raspbian_lite_latest" -o raspbian_lite_latest.zip
  unzip raspbian_lite_latest.zip

  # Did we get what we were expecting?
  if [[ `ls -1 *-raspbian-jessie-lite.img | wc -l` -ne 1 ]]; then
    echo "Can't find \"*-raspbian-jessie-lite.img\" in raspbian_lite_latest"
    exit
  fi
  rm raspbian_lite_latest.zip

  # If run with sudo , change ownership to real user
  FILEPATH=`ls -1 *-raspbian-jessie-lite.img`
  CALLER=`who am i | awk '{print $1}'`
  if [ "$CALLER" != "root" ]; then
    chown $CALLER.`groups $CALLER | awk '{print $1}'` "$FILEPATH" 2>/dev/null
  fi
else
  # Filename supplied, check it exists
  FILEPATH="$1"
  if [[ ! -f "$FILEPATH" ]]; then
    echo "Can't find \"$FILEPATH\" (or it isn't a normal file)"
    exit
  fi
fi

# Find the first, DOS partition and mount it
BOOTSTART=`fdisk -l "$FILEPATH" | sed -nr "s/^\S+1\s+([0-9]+).*  c W95 FAT32 \(LBA\)$/\1/p"`
if [[ -z "$BOOTSTART" ]]; then
  echo "Can't find FAT32 first partition in image \"$FILEPATH\""
  exit
fi
losetup /dev/loop10 "$FILEPATH" -o $((BOOTSTART*512))
mkdir rpi-boot
mount /dev/loop10 rpi-boot

# Make the change
if [[ -e "rpi-boot/ssh" ]]; then
  echo "\"`basename "$FILEPATH"`\" ALREADY had boot/ssh set."
else
  touch rpi-boot/ssh
  echo "\"`basename "$FILEPATH"`\" now has boot/ssh set."
fi

# Unmount and clear up
umount rpi-boot
rmdir rpi-boot
losetup -d /dev/loop0

# Back out of second working dir if we did a download
if [[ -z "$1" ]]; then
  mv -i "$FILEPATH" ..
  cd ..
  rmdir rpi-work
fi
