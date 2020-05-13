---
layout: post
categories: jekyll update
title: Installing Arch Linux (November 2019)
---
# Test the old stuff

I was bombarded by buzz words of today, Going from creating OpenStack Queens architectures for Telcos, VMWare+VSan sizing for banks, and educating my partners and customers to Kubernetes platforms such as PKS and OpenShift.

Then I looked back on how is the old stuff going on, when I started my journey in systems administration, I was facinated in installing Arch Linux, it was a great challenge back then on how to install it and tried to do it again today.

## Installing Arch Linux in KVM

This is the VM requirements:

Resource | Needed
--- | ---
vCPU | 1
Ram | 2 GiB
Disk | 10 GiB

First step is to boot the ISO of Arch

upon booting please choose `Boot Arch Linux (x86_64)`

Then try if you can reach the internet since Arch needs to have internet later

```
root@archiso ~ # ping ajohnsc.github.io -c 4
```

Then partition your disk with this scheme:

Disk partition | Mount Point | Size (in GiB)
--- | --- | ---
/dev/vda1 | / | 8
/dev/vda2 | /boot | 1
/dev/vda3 | swap | 1

Then format them to their appropriate file system
```
root@archiso ~ # mkfs.ext4 /dev/vda1
root@archiso ~ # mkfs.ext2 /dev/vda2
root@archiso ~ # mkswap /dev/vda3
```

After that mount it to `/mnt` as `/` if the directory is not available create it

```
root@archiso ~ # mount /dev/vda1 /mnt
root@archiso ~ # mkdir -p /mnt/boot
root@archiso ~ # mount /dev/vda2 /mnt/boot
root@archiso ~ # swapon /dev/vda3
```

Next is to install the base OS in `/mnt`
```
root@archiso ~ # pacstrap -i /mnt base base-devel
```

It will take some time

After the base installation we need to generate the fstab
```
root@archiso ~ # genfstab -U /mnt >> /mnt/etc/fstab
```

Then change root to `/mnt`
```
root@archiso ~ # arch-chroot /mnt
```

Adjust your time zone
```
[root@archiso /]#  ln -sf /usr/share/zoneinfo/Asia/Manila /etc/localtime
```

Sync your time
```
[root@archiso /]# hwclock --systohc
```

Edit `/etc/locale.gen` to uncomment `en_US.UTF-8` in my case for your locale then sync your locale
```
[root@archiso /]# vim /etc/locale.gen
[root@archiso /]# locale-gen
```

For best practice the kernel needs to have `LANG` variable and set it in your locale
```
[root@archiso /]# echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

Change your root password
```
[root@archiso /]# passwd
```

Add the hostname
```
[root@archiso /]# echo "ArchLinux" >> /etc/hostname
```

Install the Linux Kernel
```
[root@archiso /]# pacman -Sy linux
```

The install grub to `/dev/vda`
```
[root@archiso /]# pacman -S grub
[root@archiso /]# grub-install /dev/vda
[root@archiso /]# grub-mkconfig -o /boot/grub/grub.cfg
```

For us to configure the interface
```
#Check your interface
[root@archiso /]#  ip link
[root@archiso /]# vim /etc/systemd/network/enp1s0.network

[Match]
name=en*
[Network]
DHCP=yes
```
Save and exit vim

Restart and enable the systemd-netwokd
```
[root@archiso /]#  systemctl restart systemd-networkd
[root@archiso /]#  systemctl enable systemd-networkd
```

Then reboot the system
```
[root@archiso /]#  exit
root@archiso ~ # reboot
```

## You have successfully installed Arch in KVM
