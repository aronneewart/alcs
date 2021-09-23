#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="arch-linux-cold-storage"
iso_label="ALCS_$(date +%Y%m)"
iso_publisher="Aron Neewart <https://github.com/aronneewart>"
iso_application="Arch Linux Cold Storage"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'uefi-x64.systemd-boot.esp')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:0400"
  ["/etc/group"]="0:0:0400"
  ["/etc/issue"]="0:0:0400"
  ["/etc/passwd"]="0:0:0400"
  ["/etc/sudoers"]="0:0:0400"
  ["/home/rcs"]="1000:1000:750"
  ["/home/rcs/.bashrc"]="1000:1000:750"
  ["/home/cs"]="1001:1001:750"
  ["/home/cs/.bashrc"]="1001:1001:750"
)
