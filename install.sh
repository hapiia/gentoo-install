#!/usr/bin/env bash

devicepath=/dev/sda

if [ $# -eq 1 ]; then
 devicepath="$1"
fi

parted -s -a optimal ${devicepath} -- mklabel gpt \
unit mib \
mkpart primary 1 3 \
name 1 grub \
set 1 bios_grub on \
mkpart primary 3 131 \
name 2 boot \
mkpart primary 131 643 \
name 3 swap \
mkpart primary 643 -1 \
name 4 rootfs

mkfs.ext2 ${devicepath}2
mkfs.ext4 ${devicepath}4

mkswap ${devicepath}3
swapon ${devicepath}3

mount ${devicepath}4 /mnt/gentoo

mkdir /mnt/gentoo/boot
mount ${devicepath}2 /mnt/gentoo/boot

cd /mnt/gentoo

wget --no-check-certificate https://github.com/hapiia/gentoo-install/blob/master/install2.sh
chmod 755 install2.sh

mydate=`date '+%Y%m'`
wget -nc ftp://ftp.iij.ad.jp/pub/linux/gentoo/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-${mydate}*.tar.bz2

tar xvjpf stage3-*.tar.bz2 --xattrs

#nano -w /mnt/gentoo/etc/portage/make.conf

cp -L /etc/resolv.conf /mnt/gentoo/etc/

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
