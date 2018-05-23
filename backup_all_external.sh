#!/bin/bash

#check if root, if not restart with sudo
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

mkdir /mnt/bakdrv
mount /dev/disk/by-label/linux_backups /mnt/bakdrv

# Config
HOMEOPT="-aAP --delete"
HOMELINK="--link-dest=/mnt/bakdrv/snapshots/home/last/" 
HOMESRC="/home/"
HOMESNAP="/mnt/bakdrv/snapshots/home/"
HOMELAST="/mnt/bakdrv/snapshots/home/last"

ROOTOPT="-aHAXSP --delete"
ROOTLINK="--link-dest=/mnt/bakdrv/snapshots/root/last/" 
ROOTSRC="/"
ROOTSNAP="/mnt/bakdrv/snapshots/root/"
ROOTLAST="/mnt/bakdrv/snapshots/root/last"
date=`date "+%Y-%b-%d:_%T"`

# Run rsync to create snapshot
rsync $HOMEOPT --exclude={"lost+found", "mnt"} $HOMELINK $HOMESRC ${HOMESNAP}$date
# Remove symlink to previous snapshot
rm -f $HOMELAST
# Create new symlink to latest snapshot for the next backup to hardlink
ln -s ${HOMESNAP}$date $HOMELAST

# Run rsync to create snapshot
rsync $ROOTOPT --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/home/*"} $ROOTLINK $ROOTSRC ${ROOTSNAP}$date

# Remove symlink to previous snapshot
rm -f $ROOTLAST

# Create new symlink to latest snapshot for the next backup to hardlink
ln -s ${ROOTSNAP}$date $ROOTLAST

umount /mnt/bakdrv
rm -r /mnt/bakdrv
