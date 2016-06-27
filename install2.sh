#!/usr/bin/env bash

devicepath=/dev/sda

if [ $# -eq 1 ]; then
 devicepath="$1"
fi

ipaddr=
netmask=255.255.254.0
broadcast=
gateway=

source /etc/profile && export PS1="(chroot) $PS1"

emerge-webrsync

#eselect profile set 2

echo "Japan" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

# eselect locale list
eselect locale set 1

env-update && source /etc/profile

echo GRUB_PLATFORMS="efi-64" >> /etc/portage/make.conf

emerge sys-kernel/gentoo-sources sys-apps/pciutils vim dev-python/pip app-admin/sysklogd firewalld sys-boot/grub:2 net-misc/dhcpcd

pip install ansible


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

make && make modules_install && make install

#echo "config_eth0=\"${ipaddr} netmask ${netmask} brd ${broadcast}\"" > /etc/conf.d/net
#echo "routes_eth0=\"default via ${gateway}\"" >> /etc/conf.d/net

echo "config_eth0=\"dhcp\"" > /etc/conf.d/net
cd /etc/init.d && ln -s net.lo net.eth0

ansible-playbook service.yml --connection=local
ansible-playbook hostname.yml --connection=local
ansible-playbook fstab.yml --extra-vars "two=${devicepath}2 three=${devicepath}3 four=${devicepath}4" --connection=local

# grub2-install ${devicepath}
grub2-install --target=x86_64-efi --efi-directory=/boot
grub2-mkconfig -o /boot/grub/grub.cfg

# setting rootpassword
passwd
