#!/bin/bash

cd "`dirname $0`"

paths=(
    "/lib/x86_64-linux-gnu/libudev.so.1" # Ubuntu, Xubuntu, Mint
    "/usr/lib64/libudev.so.1" # SUSE, Fedora
    "/usr/lib/libudev.so.1" # Arch, Fedora 32bit
    "/lib/i386-linux-gnu/libudev.so.1" # Ubuntu 32bit
)
mkdir -p /tmp/shadowsocks-gui
for i in "${paths[@]}"
do
    if [ -f $i ]
    then
        ln -sf "$i" /tmp/shadowsocks-gui/libudev.so.0
        break
    fi
done
LD_LIBRARY_PATH=/tmp/shadowsocks-gui/ $PWD/nw app.nw
