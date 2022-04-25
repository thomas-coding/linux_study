#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/workspace/.toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"
export ARCH=arm
export CROSS_COMPILE=arm-none-linux-gnueabihf-

cmd_help() {
	echo "Basic mode:"
	echo "$0 h			---> command help"
	echo "$0 linux		---> make linux"
	echo "$0 rootfs		---> make rootfs"
	echo "$0 qemu		---> make qemu"
}

build_rootfs() {
	echo "Build rootfs"
	# Build busybox
	cd ${shell_folder}/busybox
	make menuconfig # NOTE: only need run first time
	make
	make install

	# Copy busybox to rootfs
	cd ${shell_folder}
	mkdir -p ${shell_folder}/rootfs
	cp -r ${shell_folder}/busybox/_install/* ${shell_folder}/rootfs/

	# Copy toolchain lib to rootfs
	mkdir -p ${shell_folder}/rootfs/lib
	cp -r /root/workspace/.toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/arm-none-linux-gnueabihf/libc/lib/* ${shell_folder}/rootfs/lib

	# Make dev dir
	mkdir -p ${shell_folder}/rootfs/dev
	cd ${shell_folder}/rootfs/dev
	mknod -m 666 tty1 c 4 1
	mknod -m 666 tty2 c 4 2
	mknod -m 666 tty3 c 4 3
	mknod -m 666 tty4 c 4 4
	mknod -m 666 console c 5 1
	mknod -m 666 null c 1 3

	# Init SD card with ext3 file system
	cd ${shell_folder}
	rm -rf ${shell_folder}/rootfs.ext3
	dd if=/dev/zero of=rootfs.ext3 bs=1M count=32
	mkfs.ext3 rootfs.ext3

	# Mount SD to mnt dir
	cd ${shell_folder}
	rm -rf ${shell_folder}/mnt
	mkdir -p ${shell_folder}/mnt
	mount -t ext3 ${shell_folder}/rootfs.ext3 ${shell_folder}/mnt -o loop

	# Copy rootfs file to SD card
	cp -r ${shell_folder}/rootfs/* ${shell_folder}/mnt/

	# Clean
	umount ${shell_folder}/mnt
	rm -rf ${shell_folder}/rootfs
	rm -rf ${shell_folder}/mnt
}

if [[ $1  = "h" ]]; then
	cmd_help
	exit
elif [[ $1  = "linux" ]]; then
	cd ${shell_folder}/linux
	make vexpress_defconfig
	make
	exit
elif [[ $1  = "rootfs" ]]; then
	build_rootfs
	exit
elif [[ $1  = "qemu" ]]; then
	cd ${shell_folder}/qemu
	./configure --target-list=arm-softmmu --enable-debug
	make
	exit
else
	echo "wrong args."
	cmd_help
	exit
fi
