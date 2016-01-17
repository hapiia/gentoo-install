#!/usr/bin/env bash

devicepath=/dev/vda
ipaddr=
netmask=255.255.254.0
broadcast=
gateway=

# already setted hostname="localhost"
# vim /etc/conf.d/hostname
#echo "config_eth0=\"${ipaddr} netmask ${netmask} brd ${broadcast}\"" > /etc/conf.d/net
#echo "routes_eth0=\"default via ${gateway}\"" >> /etc/conf.d/net

echo "config_eth0=\"dhcp\""

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
