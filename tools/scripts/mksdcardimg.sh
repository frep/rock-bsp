#!/bin/sh

IMG="${1}_sdcard.img"

. ${TOP_DIR}/.config

${TOOLS_DIR}/bin/rkcrc -p parameter parameter.img

# default size of sd_image is 1950, but can be overwritten by SD_IMG_SIZE_MB variable
IMG_SIZE_MB=${SD_IMG_SIZE_MB:-1950}
rm -rf $IMG
dd if=/dev/zero of=$IMG bs=1M count=${IMG_SIZE_MB}

export ROOTFS_SECTOR=65536
sudo fdisk $IMG  << EOF
n
p
1
$ROOTFS_SECTOR

w
EOF

#sudo dd if=u-boot-sd.img of=$IMG conv=notrunc,sync seek=64
sudo dd if=rk_loader/${SDBOOT_IMG} of=$IMG skip=1 seek=1
sudo dd if=parameter.img of=$IMG conv=notrunc,sync seek=$((0x2000))
sudo dd if=boot/boot-linux.img of=$IMG conv=notrunc,sync seek=$((0x2000+0x2000))
sudo dd if=rootfs.img of=$IMG conv=notrunc,sync seek=$ROOTFS_SECTOR
echo -e "Image is at \033[1;36m$(pwd)/${IMG}\033[00m"
