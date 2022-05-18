#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)

export PATH="/root/workspace/.toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"
export PATH="/home/cn1396/.toolchain/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"

# Linux kernel code maybe relocate, so you should modify symbol address for debug different part
# 1. Debug startup of zimage
# zimage is pic, set the address suit start address
# add-symbol-file ${shell_folder}/linux/arch/arm/boot/compressed/vmlinux 0x60010000
#
# 2. Debug zimage after relocated
# After zimage relocate, in "badr	r0, restart", get relocate address from r0
# calculation offset between r0 and restart address in symbol, and reload zimage vmlinux
# add-symbol-file linux/arch/arm/boot/compressed/vmlinux 0x60C9CE40
#
# 3. Debug kernel start
# objdump linux/vmlinux, get the address of all section we need, load
# add-symbol-file ${shell_folder}/linux/vmlinux 0x60100000 -s .head.text 0x60008000 -s .rodata 0x60900000 -s .init.text 0x60b00460
# b *0x60008000
#
# 4. Debug kernel
# just load vmlinux, the va is suitable
# add-symbol-file ${shell_folder}/linux/vmlinux

# Usage
#-ex "add-symbol-file ${shell_folder}/linux/arch/arm/boot/compressed/vmlinux 0x60010000" \
#-ex "add-symbol-file ${shell_folder}/linux/arch/arm/boot/compressed/vmlinux 0x60C9CE40" \
#-ex "add-symbol-file ${shell_folder}/linux/vmlinux 0x60100000 -s .head.text 0x60008000 -s .rodata 0x60900000 -s .init.text 0x60b00460" \
#-ex "add-symbol-file ${shell_folder}/linux/vmlinux" \

# busybox
#-ex "add-symbol-file ${shell_folder}/busybox/busybox/busybox_unstripped" \

# gdb
arm-none-linux-gnueabihf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/linux/vmlinux" \
-q
