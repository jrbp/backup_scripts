#!/bin/bash

# system will not be bootable if there has been a kernel update, need to run pacstrap on top of the system to be able to boot
# I'd like to know what pacstrap does specifically to make things work so I can add it here (don't want to run all of pacstrap here)

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

#should add some check that this is only run from LINUX0
mkdir /mnt/LINUX1
mount /dev/nvme0n1p6 /mnt/LINUX1
#rsync -aHAXS --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} / /mnt/LINUX1
rsync -aHAXSv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} / /mnt/LINUX1
cat <<EOF > /mnt/LINUX1/etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system>	<dir>	<type>	<options>	<dump>	<pass>
# /dev/nvme0n1p6 UUID=c31b27bf-7b61-43b7-a3fd-1870708b07ba
LABEL=LINUX1        	/         	ext4      	rw,relatime,data=ordered	0 1

# /dev/nvme0n1p8 UUID=73cfc5dc-59b6-408a-9d98-6755797c2ff4
LABEL=HOME          	/home     	ext4      	rw,relatime,data=ordered	0 2

EOF
umount /mnt/LINUX1
rm -r /mnt/LINUX1
