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
function manualRescue {
	echo "Entering fake root env..."
	sudo chroot /mnt
}
function autoRescue {
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

function autorun {
	echo "Ensuring symlink fs is not mounted..."
	unmountFS
	mountFS
	autoRescue
	unmountFS
}
function manualrun {
	echo "Ensuring symlink fs is not mounted..."
	unmountFS
	mountFS
	manualRescue
	unmountFS
}

if [ "$1" == "-m" ]; then
	manualrun
else
	autorun
fi

echo "Done."

