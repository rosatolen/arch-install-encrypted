#!/bin/zsh
## zsh is the default shell in the Archlinux install media

#######################################################################
## OPTIONAL: Delete previous LUKS key
## If the previous installation on this disk used a LUKS encrypted
## hard drive, and you wish to make sure the key used to decrypt it
## was deleted, uncomment set OLD_LUKS_PARTITION and run the following dd
## command.
#######################################################################
# OLD_LUKS_PARTITION=/dev/sda1
# dd if=/dev/urandom of="$OLD_LUKS_PARTITION" bs=512 count=20480

#######################################################################
## STEP 1
## The next 4 variables the bare minimum required to create a partition
## structure for an encrypted hard drive: 1 boot drive and 1 drive
## containing everything else. Both partitions are assumed to be on the
## same physical drive. The boot drive is not encrypted.
## If you wish to change these variables for your system, please read
## through the rest of the commands and ensure they make sense with your
## settings.
#######################################################################
BOOT_DRIVE=/dev/sda
BOOT_PARTITION=/dev/sda1
MAIN_DRIVE=/dev/sda
MAIN_ENCRYPTED_PARTITION=/dev/sda2

#######################################################################
## STEP 2
## Configure the Boot partition
## This assumes we are using a legacy (non UEFI) boot system
#######################################################################
parted "$BOOT_DRIVE" mklabel msdos
parted "$BOOT_DRIVE" mkpart primary ext3 1MiB 1GiB
parted "$BOOT_DRIVE" set 1 boot on

#######################################################################
## STEP 3
## Configure and encrypt the Main partition
#######################################################################
## OPTIONAL SUB-STEP: Label partition for separate device
## Only uncomment the next mklabel command if the boot drive is
## different from the main drive.
#######################################################################
# parted $MAIN_DRIVE mklabel msdos
#######################################################################

parted "$MAIN_DRIVE" mkpart primary ext3 100MiB 100%

#######################################################################
## The word "base" below is the default name I use for the unencrypted
## drive. You can use a different name but you have to make sure you
## setup your grub file to open the hard drive with this name.
#######################################################################
cryptsetup luksFormat "$MAIN_ENCRYPTED_PARTITION"
cryptsetup open "$MAIN_ENCRYPTED_PARTITION" base

mkfs.ext4 /dev/mapper/base
mount /dev/mapper/base /mnt
mkdir /mnt/boot
mount "$BOOT_PARTITION" /mnt/boot

#######################################################################
## STEP 4
## Install the base Archlinux system to the main partition and
## generate your new fstab file
#######################################################################
pacstrap -K /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab

###################################################################
## [MANUAL SUBSTEP]
## Check the newly created fstab file for correctness /mnt/etc/fstab
###################################################################

###################################################################
## STEP 5
## Enter /mnt with a bash chroot
###################################################################
arch-chroot /mnt /bin/bash

###################################################################
## STEP 6
## Configure your language settings. Uncomment the next 3 commands
## to use english settings.
###################################################################
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

###################################################################
## STEP 7
## Setup your local time Choose another file under
## /usr/share/zoneinfo to setup a different timezone.
###################################################################
ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc --utc

# Setup your hostname
# echo 'myhostname' > /etc/hostname

###################################################################
## STEP 8
## Configure grub as the bootloader
###################################################################
pacman -S grub os-prober

###################################################################
## [MANUAL STEP]
## Edit the file /etc/default/grub and add:
## cryptdevice=/dev/sda2:base root=/dev/mapper/base resume=/dev/mapper/base
## to the end of the variable GRUB_CMDLINE_LINUX_DEFAULT="..."
## NOTE: If you used a different name than "base", replace base in
## in the command above with your new name.
###################################################################
vi /etc/default/grub

grub-install --recheck "$BOOT_DRIVE"
grub-mkconfig -o /boot/grub/grub.cfg

###################################################################
## STEP 9
## Create the initial ramdisk environment with mkinitcpio. You must
## add the word 'encrypt' to the HOOKS variable in the mkinitcpio
## configuration file. It should look something like this:
## HOOKS="base udev autodetect modconf block encrypt filesystems keyboard fsck"
###################################################################
vi etc/mkinitcpio.conf

mkinitcpio -P

passwd

##########################################################################
## STEP 10
## Add your user to the system. Change the username to one that suits you.
## Change the useradd command to fit your needs.
##########################################################################
USERNAME=username
useradd -m "$USERNAME"
passwd "$USERNAME"
