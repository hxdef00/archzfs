#!/bin/bash

if [[ -z "${DISK}" ]]; then
  echo 'define DISK'
  exit
fi

for i in ${DISK}; do
  blkdiscard -f $i &
done
wait

for i in ${DISK}; do
  sgdisk --zap-all $i
  sgdisk -n1:1M:+${INST_PARTSIZE_ESP}G -t1:EF00 $i
  sgdisk -n2:0:+${INST_PARTSIZE_BPOOL}G -t2:BE00 $i
  if [ "${INST_PARTSIZE_SWAP}" != "" ]; then
    sgdisk -n4:0:+${INST_PARTSIZE_SWAP}G -t4:8200 $i
  fi
  if [ "${INST_PARTSIZE_RPOOL}" = "" ]; then
    sgdisk -n3:0:0   -t3:BF00 $i
  else
    sgdisk -n3:0:+${INST_PARTSIZE_RPOOL}G -t3:BF00 $i
  fi
  sgdisk -a1 -n5:24K:+1000K -t5:EF02 $i
done

# useless
disk_num=0; for i in $DISK; do disk_num=$(( $disk_num + 1 )); done
if [ $disk_num -gt 1 ]; then INST_VDEV_BPOOL=mirror; fi

sleep 5
ls -l /dev/disk/by-id

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    bpool $INST_VDEV_BPOOL $(for i in ${DISK}; do printf "$i-part2 "; done)
    
zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    rpool $INST_VDEV $(for i in ${DISK}; do printf "$i-part3 "; done)
