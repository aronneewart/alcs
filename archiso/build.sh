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
  echo "$0 [ -h ]

-h,   --help            This window
"
  exit 0
fi

# Checking parameters
# -------------------
echo "Checking parameters ..."

# Let's start!
# -------------------

echo "Moving old build dir..."
sudo mv build build_old

echo "Deleting old build dir..."
sudo rm -rf build_old &

echo "Building ISO..."
sudo mkarchiso -v -w build -o iso source/baseline

