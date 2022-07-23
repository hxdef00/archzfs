#!/bin/bash

if ! [[ -z "${DISK}" ]]; then
  echo 'define DISK'
  exit
fi

INST_LINVAR='linux'
INST_UUID=$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'a-z0-9' | cut -c-6)
INST_ID=arch
INST_PRIMARY_DISK=$(echo $DISK | cut -f1 -d\ )
