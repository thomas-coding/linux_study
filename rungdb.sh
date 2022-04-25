#!/bin/bash

# shell folder
shell_folder=$(cd "$(dirname "$0")" || exit;pwd)


export PATH="/root/workspace/.toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/:$PATH"

# gdb
arm-none-linux-gnueabihf-gdb \
-ex 'target remote localhost:1234' \
-ex "add-symbol-file ${shell_folder}/linux/vmlinux" \
-q
 