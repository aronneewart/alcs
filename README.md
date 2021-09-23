# ALCS
Arch Linux Cold Storage

## Kernel

Linux LTS 5.10.68
Config file + patches from 
https://github.com/archlinux/svntogit-packages/tree/packages/linux-lts/trunk

## Build ISO

cd archiso
sudo mkarchiso -v -w build -o iso source
sudo rm -rf build &
