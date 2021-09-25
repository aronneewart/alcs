#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="arch-linux-cold-storage"
iso_label="ALCS_$(date +%Y%m)"
iso_publisher="Aron Neewart <https://github.com/aronneewart>"
iso_application="Arch Linux Cold Storage"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/etc/shadow"]="0:0:600"
  ["/etc/gshadow"]="0:0:0600"
  ["/etc/group"]="0:0:0644"
  ["/etc/issue"]="0:0:0644"
  ["/etc/passwd"]="0:0:0644"
  ["/etc/sudoers"]="0:0:0440"
  ["/home/rcs"]="1000:1000:750"
  ["/home/cs"]="1001:1001:750"
)
