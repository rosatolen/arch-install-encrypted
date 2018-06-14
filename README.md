# Archlinux Encrypted HD Script

This is an effort to create scripts for installing Archlinux with an encrypted
hard drive.

### WARNING:

This is still in development.  Please read through the script thoroughly
before running it or using the commands. Change them according to your
preferences. The commands are short and based upon the Arch wiki and the
ArchLinux Beginner's Guide.

## What this doesn't do

* Handle configuration of a UEFI boot partition. Legacy boot is expected in the
  script
* Teach you how to set up swap partitions or configure a fancier partition
  system

## How To Use

1. Boot into an Arch Linux Installation Medium (USB Arch Install, etc.)
2. Clone https://github.com/rosatolen/arch_install_enc_hd
3. Navigate into the repo and read through `setup.sh`
4. Run each command in `setup.sh` separately. After you use the arch-chroot
   command you may want to open it on a separate computer or copy it somewhere
   into /mnt for reference while in the chroot. This is recommended because,
   several important steps are still manual.

## Future Features

* Remove manual steps
* Configure a USB drive as the boot partition
* Install all archlinux packages from a given list (maybe)
* More security defaults
