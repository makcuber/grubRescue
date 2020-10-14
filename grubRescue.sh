#!/bin/bash

bootPart="/dev/nvme0n1p1"
rootPart="/dev/nvme0n1p4"
delay=1

#set -e #enable exit on error

function mountFS { 
	echo "Mounting root partition as symlink..."
	sudo mount "$rootPart" /mnt &
	sleep "$delay"
	
	echo "Mounting core fs as symlink..."
	sudo mount --bind /dev /mnt/dev
	sleep "$delay"
	sudo mount --bind /dev/pts /mnt/dev/pts &
	sleep "$delay"
	sudo mount --bind /proc /mnt/proc &
	sleep "$delay"
	sudo mount --bind /sys /mnt/sys &
	sleep "$delay"
	
	echo "Mounting boot partition as symlink..."
	sudo mount /dev/nvme0n1p1 /mnt/boot/efi &
	sleep "$delay"
}
function chrootExe {
	echo "Entering fake root env..."
	#"set -e" enables exit on error
	sudo chroot /mnt /bin/bash -c "set -e && grub-install $bootPart && update-grub && exit"
}
function unmountFS {
	echo "Unmounting symlinked boot partition..."
	sudo umount /mnt/boot/efi
	sleep "$delay"
	
	echo "Unmounting symlinked core fs..."
	sudo umount /mnt/sys
	sleep "$delay"
	sudo umount /mnt/proc
	sleep "$delay"
	sudo umount /mnt/dev/pts
	sleep "$delay"
	sudo umount /mnt/dev
	sleep "$delay"
	
	echo "Unmount symlinked root partition..."
	sudo umount /mnt
	sleep "$delay"
}

function run {
	echo "Ensuring symlink fs is not mounted..."
	unmountFS
	mountFS
	chrootExe
	unmountFS
}
run
echo "Done."

