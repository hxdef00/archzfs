#!/bin/bash 

# root fs
zfs create -o canmount=off -o mountpoint=none rpool_$INST_UUID/$INST_ID

# data fs
zfs create -o canmount=off -o mountpoint=none bpool_$INST_UUID/$INST_ID
zfs create -o canmount=off -o mountpoint=none bpool_$INST_UUID/$INST_ID/BOOT
zfs create -o canmount=off -o mountpoint=none rpool_$INST_UUID/$INST_ID/ROOT
zfs create -o canmount=off -o mountpoint=none rpool_$INST_UUID/$INST_ID/DATA
zfs create -o mountpoint=/boot -o canmount=noauto bpool_$INST_UUID/$INST_ID/BOOT/default
zfs create -o mountpoint=/ -o canmount=off    rpool_$INST_UUID/$INST_ID/DATA/default
zfs create -o mountpoint=/ -o canmount=noauto rpool_$INST_UUID/$INST_ID/ROOT/default
zfs mount rpool_$INST_UUID/$INST_ID/ROOT/default
zfs mount bpool_$INST_UUID/$INST_ID/BOOT/default
for i in {usr,var,var/lib};
do
    zfs create -o canmount=off rpool_$INST_UUID/$INST_ID/DATA/default/$i
done
for i in {home,root,srv,usr/local,var/log,var/spool};
do
    zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/$i
done
chmod 750 /mnt/root

# esp fs
for i in ${DISK}; do
 mkfs.vfat -n EFI ${i}-part1
 mkdir -p /mnt/boot/efis/${i##*/}-part1
 mount -t vfat ${i}-part1 /mnt/boot/efis/${i##*/}-part1
done

mkdir -p /mnt/boot/efi
mount -t vfat ${INST_PRIMARY_DISK}-part1 /mnt/boot/efi

# optional fs
#zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/games
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/www
# for GNOME
#zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/AccountsService
# for Docker
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/docker
# for NFS
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/nfs
# for LXC
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/lxc
# for LibVirt
zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/libvirt
##other application
# zfs create -o canmount=on rpool_$INST_UUID/$INST_ID/DATA/default/var/lib/$name
