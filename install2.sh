#!/usr/bin/env bash

devicepath=/dev/vda

source /etc/profile
export PS1="(chroot) $PS1"

emerge-webrsync

#eselect profile set 2

echo "Japan" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

locale-gen

# eselect locale list
eselect locale set 1

env-update && source /etc/profile

emerge sys-kernel/gentoo-sources sys-apps/pciutils

cd /usr/src/linux

make defconfig

echo "CONFIG_VIRTIO_BLK=y" >> /usr/src/linux/.config
echo "CONFIG_VIRTIO_PCI=y" >> /usr/src/linux/.config
echo "CONFIG_VIRTIO_NET=y" >> /usr/src/linux/.config
echo "CONFIG_PARAVIRT=y" >> /usr/src/linux/.config
echo "CONFIG_KVM_GUEST=y" >> /usr/src/linux/.config

make && make modules_install
make install

emerge vim
emerge dev-python/pip

pip install ansible
ansible-playbook fstab.yml --connection=local
#ansible-playbook -i servers main.yml
# fstab
