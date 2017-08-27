#!/bin/bash

#check if root, if not restart with sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

mkdir /mnt/bakdrv
mount /dev/disk/by-label/linux_backups /mnt/bakdrv

# Config
OPT="-aAP --delete"
LINK="--link-dest=/mnt/bakdrv/snapshots/home/last/" 
SRC="/home/"
SNAP="/mnt/bakdrv/snapshots/home/"
LAST="/mnt/bakdrv/snapshots/home/last"
date=`date "+%Y-%b-%d:_%T"`

# Run rsync to create snapshot
rsync $OPT --exclude="lost+found" $LINK $SRC ${SNAP}$date

# Remove symlink to previous snapshot
rm -f $LAST

# Create new symlink to latest snapshot for the next backup to hardlink
ln -s ${SNAP}$date $LAST

umount /mnt/bakdrv
rm -r /mnt/bakdrv
