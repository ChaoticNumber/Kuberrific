#!/bin/bash

# Default values for VM configuration
RAM=1024 # megabytes
CPUS=2
STORAGE=10 # gigabytes
SOURCE_IMAGE=/path/to/source-image.img
TARGET_IMAGE=/path/to/target-image.qcow2

# Usage message
usage() {
    echo "Usage: $0 [-r RAM] [-c CPUS] [-s STORAGE] [-i SOURCE_IMAGE] [-o TARGET_IMAGE]"
    exit 1
}

# Parse command line arguments
while getopts ":r:c:s:i:o:" opt; do
    case $opt in
        r) RAM="$OPTARG" ;;
        c) CPUS="$OPTARG" ;;
        s) STORAGE="$OPTARG" ;;
        i) SOURCE_IMAGE="$OPTARG" ;;
        o) TARGET_IMAGE="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if the source image file exists
if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image file not found"
    exit 1
fi

# Check if the target image file already exists
if [ -f "$TARGET_IMAGE" ]; then
    echo "Error: Target image file already exists"
    exit 1
fi

# Convert image to qcow2 format
qemu-img convert -f raw -O qcow2 $SOURCE_IMAGE $TARGET_IMAGE

# Start VM
qemu-system-x86_64 \
-m $RAM \
-smp $CPUS \
-drive file=$TARGET_IMAGE,if=virtio \
-drive file=/dev/zero,if=virtio,format=raw,id=swap \
-device virtio-blk,drive=swap \
-device virtio-net,netdev=net0 \
-netdev user,id=net0 \
-vga virtio \
-display gtk,gl=on \
-usb \
-cpu host \
-soundhw hda \
-device intel-hda

# End of script
