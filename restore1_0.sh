#!/bin/bash

# system will not be bootable if there has been a kernel update, need to run pacstrap on top of the system to be able to boot
# I'd like to know what pacstrap does specifically to make things work so I can add it here (don't want to run all of pacstrap here)

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

#should add some check that this is only run from LINUX1
mkdir /mnt/LINUX0
mount /dev/nvme0n1p5 /mnt/LINUX0
rsync -aHAXSv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} / /mnt/LINUX0
cat <<EOF > /mnt/LINUX0/etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system>	<dir>	<type>	<options>	<dump>	<pass>
# /dev/nvme0n1p5 UUID=a4c3aabd-20bd-4186-9bcd-abfc27045d85
LABEL=LINUX0        	/         	ext4      	rw,relatime,data=ordered	0 1

# /dev/nvme0n1p8 UUID=73cfc5dc-59b6-408a-9d98-6755797c2ff4
LABEL=HOME          	/home     	ext4      	rw,relatime,data=ordered	0 2

EOF
arch-chroot /mnt/LINUX0 pacman -U /var/cache/pacman/pkg/linux-$(pacman -Qii linux | grep Version | awk '{print $3}')-x86_64.pkg.tar.xz
umount /mnt/LINUX0
rm -r /mnt/LINUX0
