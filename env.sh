export INST_LINVAR='linux'
export INST_UUID=$(dd if=/dev/urandom bs=1 count=100 2>/dev/null | tr -dc 'a-z0-9' | cut -c-6)
export INST_ID=arch
export INST_PRIMARY_DISK=$(echo $DISK | cut -f1 -d\ )

export INST_PARTSIZE_ESP=4
export INST_PARTSIZE_BPOOL=4
export INST_PARTSIZE_SWAP=32
