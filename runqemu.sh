#!/bin/bash

# Shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/workspace/software/qemu/qemu-6.0.0/build/:$PATH"

qemu_option=
if [[ $1  = "--gdb" ]]; then
    qemu_option+=" -s -S"
    echo "enable gdb, please run script './rungdb', and enter c "
else
    echo "not use gdb, just run"
fi

qemu_option+=" -machine vexpress-a9"
qemu_option+=" -kernel ${shell_folder}/linux/arch/arm/boot/zImage"
qemu_option+=" -dtb ${shell_folder}/linux/arch/arm/boot/dts/vexpress-v2p-ca9.dtb"
qemu_option+=" -sd ${shell_folder}/buildroot/output/images/rootfs.ext2"
qemu_option+=" -nographic"
#qemu_option+=" -d guest_errors"
qemu_option+=" -monitor telnet:127.0.0.1:65530,server,nowait"
qemu_option+=" -append nokaslr"


#gdb --args ../qemu_study/qemu/build/arm-softmmu/qemu-system-arm ${qemu_option} -append "console=ttyAMA0"
gdb --args ${shell_folder}/qemu/build/arm-softmmu/qemu-system-arm ${qemu_option} -append "root=/dev/mmcblk0 rw console=ttyAMA0"
