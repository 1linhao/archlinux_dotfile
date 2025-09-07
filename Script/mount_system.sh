#!/bin/bash

mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o autodefrag,noatime,compress=zstd:1,subvol=@ /mnt/root
mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o autodefrag,noatime,compress=zstd:1,subvol=@boot /mnt/root/boot
mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o nodatacow,noatime,compress=zstd:1,subvol=@tmp /mnt/root/var/tmp
mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o nodatacow,noatime,compress=zstd:1,subvol=@cache /mnt/root/var/cache
mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o nodatacow,noatime,compress=zstd:1,subvol=@log /mnt/root/var/log
mount /dev/disk/by-uuid/d2efc181-3137-4404-a70a-8b4f6da2b40b --mkdir -o nodatacow,noatime,compress=zstd:1,subvol=@docker /mnt/root/var/lib/docker
mount /dev/disk/by-uuid/9904-6D06 --mkdir /mnt/root/boot/efi
echo "the system mountpoin is /mnt/root"
