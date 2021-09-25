#!/bin/bash

set -e

err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

while [[ $# -gt 0 ]]
do
  key="$1"
  
  case $key in
      -i|--iso)
      FILE_ISO="${2}"
      shift # past argument
      shift # past argument
      ;;
      -d|--device)
      DEVICE="${2}"
      shift # past argument
      shift # past argument
      ;;
      -h|--help)
      PARAM_HELP=YES
      shift # past argument
      ;;
      *)    # unknown option
      PARAM_HELP=YES
      shift # past argument
      ;;
  esac
done

if [[ -v PARAM_HELP ]]; then 
  echo "$0 [ -c ] [ -h ]

-i,   --iso             ISO file
-d,   --device          USB device where to extract the ISO (e.g. /dev/sdb) 
-h,   --help            This window
"
  exit 0
fi

# Checking parameters
# -------------------
echo "Checking parameters ..."

# ISO file 
if [[ -z ${FILE_ISO} ]] 
then
  echo "ISO file parameter not set!"
  exit -1
elif [[ ! -f "${FILE_ISO}" ]]
then
  echo "ISO file '${FILE_ISO}' does not exist!"
  exit -1
fi

# USB device 
if [[ -z ${DEVICE} ]] 
then
  echo "USB device parameter not set!"
  exit -1
elif [[ ! -e "${DEVICE}" ]]
then
  echo "USB device '${DEVICE}' does not exist!"
  exit -1
elif $(cat /proc/mounts | grep -q "${DEVICE}")
then
  echo "USB device '${DEVICE}' is mounted! Please unmount it and try again."
  exit -1
fi

# Let's start!
# -------------------

echo "Copying to USB..."
sudo dd if=${FILE_ISO} of=${DEVICE} bs=4M && sync

