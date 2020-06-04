---
layout: post
title: Arch Linux as your Day-to-day Desktop (2020)
categories: jekyll update
---

# Linux Distribution Hunt

I'm using Linux distribution for my day to day life, I started to use Linux distribution fully as my primary and only OS in 2017 at work, it was hard to migrate from Windows though I have been using Linux in VMs I never thoughy using it as my Daily driver.

To be honest it was a fun switch and exciting adventure, I started to use Fedora 28, back it was smooth and encourage everyone on my team to try it. only 3 out of 20 is using Linux distributions today sad to say.

So I started Fedora 28 upgraded to Fedora 29 and Fedora 30, but when I had to use a new laptop that's where things got messy I have now a Lenovo Legion Y540, Intel Core i7-9750H, 32GB of Ram, and 1x 2.5" Samsung EVO SSD 1TB, 1x m.2 nvme Lenovo ssd (stock), and a NVIDIA GeForce GTX 1650 Mobile as GPU,

When I installed Fedora 30 back then it was smooth an installed also the proprietary driver for NVIDIA, when I updated in Fedora 31 and had a new kernel that's where the things break, I realized there is no seamless upgrade in Fedora that involves a Proprietary driver thus it broke easily, thus I needed to change from Fedora 31 to Ubuntu 18.04 LTS.

Ubuntu 18.04 is good, it great as a distribution that "just works", upgraded to Ubuntu 20.04 with the NVIDIA driver installed was way smooth than my experience with Fedora, then the crazy happens when I was trying to learn Ansible and Containers, Cri-o was a mess in Ubuntu, it keeps on shutting off my containers if not in used as if it is a serverless platform, it turns out Cri-O works best in Red Hat distributions (Centos/Fedora) when I tried it in a VM it worked well.

Then it was time to shift again from Ubuntu 18.04 to Fedora 32 it went well until the horror happened when upgrading 5.6.11 the kernel broke again due to the NVIDIA driver, I thought that they already sorted it out bacause Lenovo already has a Fedora OEM, but it seams there is still a gap.

Thus a Distribution hunt is on it's way.

I need to have a distribution that doesn't break while upgrading using the NVIDIA drivers like Ubuntu, But let me use Cri-O and other container technologies freely like Fedora thus concluded I have 2 options.

1. Linux from scratch
1. Arch Linux

Linux from scratch is not a Linux distribution but I could have all the freedom that I could, however it really takes a long time, thus I went to Arch Linux.

As it reputation Arch is sought as a "hard" distribution and wanted to check if it is really a challenge, and I succeded.

![arch-linux-as-your-day-to-day-desktop-\(2020\)blog1](/assets/2020-05-13-arch-linux-as-your-day-to-day-desktop-(2020)/blog1.png)

## Installation of Arch Linux in a Laptop

To install I had to consider these things:

1. My laptop boots on UEFI i needed to install it in EFI mode.
1. I have 2 disks I need to be carefull in my partitioning.
1. I need to install it via wifi since I don't have an ethernet cable.
1. Install it with GUI since this will be my day-to-day driver.
1. NVIDIA GPU, I needed to install the NVIDIA Driver.

### Booting it up

Booting the Arch Linux is simply using `dd` the iso to my USB flash drive.
(Note: I was still using Fedora this time)
```
[aj@fedoralaptop] dd bs=1M if=archlinux-2020.05.01-x86_64.iso of=/dev/sdb status=progress
```
Plug the Flash drive and booted in the Arch Linux ISO.

upon booting use your arrow keys to choose `Arch Linux archiso x86_64 UEFI CD`

the Live CD will automatically login as `root` and you will have `zsh` shell to use.

```
root@archiso ~ #
```

### Partitioning

I have 2 disks `/dev/sda` and `/dev/nvme0n1` and I will parition it like this:

| Disk         | Parition       | Mount Point | Size    |
|--------------|----------------|-------------|---------|
| /dev/sda     | /dev/sda1      | /home       | 931.5 G |
| /dev/nvme0n1 | /dev/nvme0n1p1 | /boot/efi   | 300 M   |
|              | /dev/nvme0n1p2 | swap        | 32G     |
|              | /dev/nvme0n1p2 | /           | 444.7G  |

I use `parted` command for ease of use to accomplish this table

For `/dev/sda`

```
root@archiso ~ # parted -s /dev/sda \
mkalabel gpt \
mkpart primary ext4 0% 100%
```

For `/dev/nvme0n1`
```
root@archiso ~ # parted -s /dev/nvme0n1 \
mkalabel gpt \
mkpart primary fat32 0% 300MiB \
set 1 esp on \
mkpart primary linux-swap 300MiB 32GiB \
mkpart primary ext4 32GiB 100%
```
to check if we succeeded:
```
root@archiso ~ # lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 931.5G  0 disk 
└─sda1        8:1    0 931.5G  0 part
nvme0n1     259:0    0   477G  0 disk 
├─nvme0n1p1 259:1    0   300M  0 part 
├─nvme0n1p2 259:2    0    32G  0 part
└─nvme0n1p3 259:3    0 444.7G  0 part
```

Then formating the partitions
```
root@archiso ~ # mkfs.fat -F32 /dev/nvme0n1p1
root@archiso ~ # mkswap /dev/nvme0n1p2
root@archiso ~ # mkfs.ext4 /dev/nvme0n1p3
root@archiso ~ # mkfs.ext4 /dev/sda1
```

### Use wifi in the installation

To install Arch you need a stable internet connection, since I don't have an ethernet cable, logic dictates me to use Wifi instead.

To enable wifi, first remove any `rfkill` blockers
```
root@archiso ~ # rfkill unblock all
```

then set the wireless lan to up
```
root@archiso ~ # ip link set dev wlan0 up
```

try to do a scan
```
root@archiso ~ # iwlist wlan0 scan
```

if there is an output of ESSIDs then you succeded, turn your wireless lan interface off
```
root@archiso ~ # ip link set dev wlan0 up
```

Now to configure the ssid use `wifi-menu`
```
root@archiso ~ # wifi-menu
```

After you choose an SSID and put a password you will be connected.
(Note: The password might be in plain text be aware in your surroundings)

try to ping a cool website
```
root@archiso ~ # ping -c 4 ajohnsc.com
```

If you have connected it is a success then.

### Install Arch with GUI

mount the `/` and `swap` partitions first
```
root@archiso ~ # mount /dev/nvme0n1p3 /mnt
root@archiso ~ # swapon /dev/nvme0n1p2
```

Start the base installation using `pacstrap`
```
root@archiso ~ # pacstrap /mnt base base-devel linux linux-firmware vim
```

It will take sometime depending on your internet connection.

now mount the `/home` partition since everything is installed and inplaced
```
root@archiso ~ # mount /dev/sda1 /mnt/home
```

Then generate your `fstab` file.
```
root@archiso ~ # genfstab -U -p /mnt >> /mnt/etc/fstab
root@archiso ~ # cat /mnt/etc/fstab
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
# /dev/nvme0n1p3
UUID=82d9b252-e602-4c71-a3f1-0f91069027d4	/         	ext4      	rw,relatime	0 1

# /dev/sda1
UUID=46ed0850-0343-49db-96c1-345ef43de826	/home     	ext4      	rw,relatime	0 2

# /dev/nvme0n1p2
UUID=0a5d8118-e51f-46a0-a03f-6698ad00bd82	none      	swap      	defaults  	0 0
```

To configure the new installation we need to `chroot` in `/mnt`, use `arch-chroot` to do that.
```
root@archiso ~ # arch-chroot /mnt
[root@archiso]#
```

Add your hostname in `/etc/hostname`
```
[root@archiso]# echo "AJCanlas-PC" > /etc/hostname
```

Configure the system language by editing `/etc/locale.gen`,use "en_US.UTF-8 UTF-8" and "en_US ISO-8859-1" for english.

```
[root@archiso]# sed -i s/"#en_US.UTF-8 UTF-8"/"en_US.UTF-8 UTF-8" /etc/locale.gen
[root@archiso]# sed -i s/"#en_US ISO-8859-1"/"en_US ISO-8859-1" /etc/locale.gen
```

Generate the system language layout.
```
[root@archiso]# locale-gen
```

Configure persistently your system language and use it.
```
[root@archiso]# echo LANG=en_US.UTF-8 > /etc/locale.conf
[root@archiso]# export LANG=en_US.UTF-8
```

Configure your local time, for my case I use "Asia/Manila", and set the hardware clock to UTC.
```
[root@archiso]# ln -s /usr/share/zoneinfo/Asia/Manila /etc/localtime
[root@archiso]# hwclock --systohc --utc
```

Then create your user for your new system, and root password
```
[root@archiso]# passwd
[root@archiso]# useradd -G wheel,storage,power -s /bin/bash -c "Aaron John S. Canlas" aj
[root@archiso]# passwd aj
```

Configure sudoers
```
[root@archiso]# pacman -S sudo vim
[root@archiso]# visudo -f /etc/sudoers
```

edit this line from:
```
#%wheel ALL=(ALL) ALL
```
to:
```
%wheel ALL=(ALL) ALL
```
then save

Next is to install my ddesktop environment,

first install NetworkManager and all wireless utilities.
```
[root@archiso]# pacman -S wireless_tools iw wpa_supplicant iwd
[root@archiso]# pacman -S networkmanager
```

enable network manager for reboot
```
[root@archiso]# systemctl enable NetworkManager
```

Install X Windows System
```
[root@archiso]# pacman -S xorg xorg-server
```

then install Gnome desktop environment
```
[root@archiso]# pacman -S gnome
```

Then enable gnome dekstop manager
```
[root@archiso]# systemctl start gdm
```

Last is to install the Boot loader, to install GRUB with UEFI capabilities you need the following packages
```
[root@archiso]# pacman -S grub efibootmgr dosfstools os-prober mtools
```

then create a `/boot/EFI` directory and mount your EFI parition there
```
[root@archiso]# mkdir /boot/EFI
[root@archiso]# mount /dev/nvme0n1p1 /boot/EFI
```

Then install grub with uefi.
```
[root@archiso]# grub-install --target=x86_64-efi  --bootloader-id=grub_uefi --recheck 
```

Then create the grub configuraiton file
```
[root@archiso]# grub-mkconfig -o /boot/grub/grub.cfg
```

### Install the NVIDIA Driver

Arch suprised me since they have the simplest way to install their NVIDIA Driver, to install It:
```
[root@archiso]# pacman -S nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia
```

Then blacklist the nouveau driver in modprobe
```
[root@archiso]#  echo "blacklist nouveau" > /usr/lib/modprobe.d/nvidia.conf
```

### Finishing it

All is setup the only thing left is reboot
```
[root@archiso]# exit
root@archiso ~ # umount -a
root@archiso ~ # telinit 6
```

Remove your flash drive and you have your new Arch Linux in Gnome Desktop.
