#!/bin/bash

set -e

RELEASE=5.10.68 # LTS
FILE_CONFIG='./config'
MAKE_JOBS=1
PATCHES=(
  0001-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
  0002-gcc-plugins-modern-gcc-plugin-infrastructure-requres.patch
)

err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

while [[ $# -gt 0 ]]
do
  key="$1"
  
  case $key in
      -c|--config)
      FILE_CONFIG="${2}"
      shift # past argument
      shift # past argument
      ;;
      -j|--jobs)
      MAKE_JOBS="${2}"
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

-c,   --config          Kernel config file path (default: ./config)
-j,   --jobs            Makefile 'jobs' parameter for parallelization
-h,   --help            This window
"
  exit 0
fi

FILE_CONFIG="$(readlink -f ${FILE_CONFIG})"

echo "RELEASE ${RELEASE}"
echo "FILE_CONFIG ${FILE_CONFIG}"
echo "MAKE_JOBS ${MAKE_JOBS}"
echo "PATCHES ${PATCHES[@]}"
echo ""

# Checking parameters
# -------------------
echo "Checking parameters ..."

# Kernel config file
if [[ ! -f "${FILE_CONFIG}" ]]
then
  echo "Kernel config file '${FILE_CONFIG}' does not exist!"
  exit -1
fi

# Let's start!
# -------------------

# Download kernel 
if [[ ! -f "linux-${RELEASE}.tar.xz" ]]
then
  echo "Downloading kernel source..."
  curl https://cdn.kernel.org/pub/linux/kernel/v$(echo $RELEASE | cut -d '.' -f 1).x/linux-${RELEASE}.tar.xz -o "linux-${RELEASE}.tar.xz" 
  # TODO add checksum sha256
else
  echo "Skipping downloading kernel source, already exists..."
fi

if [[ ! -f "linux-${RELEASE}.tar.sign" ]]
then
  echo "Downloading kernel signature..."
  curl https://cdn.kernel.org/pub/linux/kernel/v$(echo $RELEASE | cut -d '.' -f 1).x/linux-${RELEASE}.tar.sign -o "linux-${RELEASE}.tar.sign" 
  # TODO add checksum sha256
else
  echo "Skipping downloading kernel signature, already exists..."
fi

# Extract xz 
if [[ ! -f "linux-${RELEASE}.tar" ]]
then
  echo "Extracting linux-${RELEASE}.tar.xz..."
  unxz -k linux-${RELEASE}.tar.xz
else 
  echo "Skipping extraction, linux-${RELEASE}.tar already exists..."
fi

# Verify file
echo "Verifying signature..."
KEY_ID=$(gpg --list-packets linux-${RELEASE}.tar.sign | grep keyid | cut -d ' ' -f 6)
gpg --recv-keys ${KEY_ID}

if ! $(gpg --verify linux-${RELEASE}.tar.sign linux-${RELEASE}.tar)
then
  echo "Invalid gpg signature for 'linux-${RELEASE}.tar'"
  exit -1
fi

# Extract tar
if [[ -d "linux-${RELEASE}" ]]
then
  echo "Removing old linux-${RELEASE} dir..."
  rm -rf "linux-${RELEASE}"
fi

echo "Extracting linux-${RELEASE}.tar..."
tar -xvf linux-${RELEASE}.tar

echo "Changing dir to linux-${RELEASE}..."
cd linux-${RELEASE}

# Clean
echo "Cleaning kernel source..."
make mrproper

# Patching
echo "Patching kernel..."
for patch in "${PATCHES[@]}"; do
  patch="${patch%%::*}"
  patch="${patch##*/}"
  [[ $patch = *.patch ]] || continue
  echo "Applying patch $patch..."
  patch -Np1 < "../$patch"
done

# Kernel config 
# Generate this file by running 'make ARCH=x86_64 nconfig'
echo "Copying kernel config file..."
cp "${FILE_CONFIG}" .config

echo "Getting kernel local version..."
LOCALVERSION=$(cat .config | grep CONFIG_LOCALVERSION= | cut -d '"' -f 2)
echo "Kernel local version ${LOCALVERSION}..."

# Compile kernel
echo "Compiling kernel..."
make ARCH=x86_64 -j${MAKE_JOBS}

echo "Copying kernel to archiso airootfs/boot dir..."
cp arch/x86_64/boot/bzImage "../../archiso/source/baseline/airootfs/boot/vmlinuz-linux"

# Build modules
echo "Building kernel modules..."
make ARCH=x86_64 INSTALL_MOD_PATH=../../archiso/source/baseline/airootfs/usr modules

echo "Installing kernel modules..."
make ARCH=x86_64 INSTALL_MOD_PATH=../../archiso/source/baseline/airootfs/usr modules_install

# Creates the initramfs img
# NOTE: Archiso does this action on its own
# echo "Creating initramfs image..."
# mkinitcpio -k "${RELEASE}${LOCALVERSION}" -g "../../archiso/source/baseline/airootfs/boot/initramfs-linux.img" -r ../../archiso/source/baseline/airootfs/usr
