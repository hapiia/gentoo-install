#!/usr/bin/env bash

devicepath=/dev/sda
ipaddr=
netmask=255.255.254.0
broadcast=
gateway=

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

echo "CONFIG_VMWARE_VMCI=y" >> /usr/src/linux/.config
echo "CONFIG_HYPERVISOR_GUEST=y" >> /usr/src/linux/.config
echo "CONFIG_VSOCKETS=y" >> /usr/src/linux/.config
echo "CONFIG_VMESRE_VMCI_VSOCKETS=y" >> /usr/src/linux/.config
echo "CONFIG_VMWARE_BALLOON=y" >> /usr/src/linux/.config
echo "CONFIG_SCSI_LOWLEVEL=y" >> /usr/src/linux/.config
echo "CONFIG_VMWARE_PVSCSI=y" >> /usr/src/linux/.config
echo "CONFIG_FUSION=y" >> /usr/src/linux/.config
echo "CONFIG_FUSION_SPI=y" >> /usr/src/linux/.config
echo "CONFIG_FUSION_MAX_SGE=128" >> /usr/src/linux/.config

echo "CONFIG_VMXNET3=y" >> /usr/src/linux/.config
echo "CONFIG_I2C_PIIX4=y" >> /usr/src/linux/.config
echo "CONFIG_DRM_TTM=y" >> /usr/src/linux/.config
echo "CONFIG_DRM_VMWGFX=y" >> /usr/src/linux/.config
echo "CONFIG_FB_DEPERRED_IO=y" >> /usr/src/linux/.config

make && make modules_install
make install

cd /
emerge vim
emerge dev-python/pip

pip install ansible
ansible-playbook fstab.yml --connection=local
#ansible-playbook -i servers main.yml
# fstab

# already setted hostname="localhost"
# vim /etc/conf.d/hostname
#echo "config_eth0=\"${ipaddr} netmask ${netmask} brd ${broadcast}\"" > /etc/conf.d/net
#echo "routes_eth0=\"default via ${gateway}\"" >> /etc/conf.d/net

echo "config_eth0=\"dhcp\"" > /etc/conf.d/net

cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

# /etc/hosts
# default

# setting rootpassword
passwd
emerge app-admin/sysklogd
rc-update add sysklogd default
rc-update add sshd default

emerge sys-boot/grub

grub2-install ${devicepath}

grub2-mkconfig -o /boot/grub/grub.cfg
