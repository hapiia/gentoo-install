#!/usr/bin/env bash

devicepath=/dev/vda

mount ${devicepath}4 /mnt/gentoo

mkdir /mnt/gentoo/boot
mount ${devicepath}2 /mnt/gentoo/boot

mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
