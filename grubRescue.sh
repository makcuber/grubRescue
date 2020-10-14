#!/bin/bash

echo "Mounting root partition..."
sudo mount /dev/nvme0n1p4 /mnt &

echo "Mounting core fs..."
sudo mount --bind /dev /mnt/dev &
sudo mount --bind /dev/pts /mnt/dev/pts &
sudo mount --bind /proc /mnt/proc &
sudo mount --bind /sys /mnt/sys &

echo "Mounting boot partition..."
sudo mount /dev/nvme0n1p1 /mnt/boot/efi &

echo "Entering fake root env..."
sudo chroot /mnt

echo "Done."
