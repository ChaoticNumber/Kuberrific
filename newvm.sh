#!/bin/bash

# Default values for VM configuration
RAM=1024 # megabytes
CPUS=2
STORAGE=10 # gigabytes
SOURCE_IMAGE=/path/to/source-image.img
TARGET_IMAGE=/path/to/target-image.qcow2
CLOUD_INIT_FILE=""

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

# Check if the target image file already exists and append a sequential number if it does
counter=1
while [ -f "$TARGET_IMAGE" ]; do
    TARGET_IMAGE="${TARGET_IMAGE%.*}_$counter.qcow2"
    ((counter++))
done

# Echo message if a new file was created
if [ $counter -gt 1 ]; then
    echo "Target image file already exists. New file $TARGET_IMAGE has been created."
fi

# Convert image to qcow2 format
qemu-img convert -f raw -O qcow2 $SOURCE_IMAGE $TARGET_IMAGE

# Start VM with cloud-init
if [ -n "$CLOUD_INIT_FILE" ]; then
    qemu-system-x86_64 \
        -m $RAM \
        -smp $CPUS \
        -drive file=$TARGET_IMAGE,if=virtio \
        -initrd $CLOUD_INIT_FILE \
        -append "console=ttyS0 cloud-config-url=http://example.com/my-cloud-config.yaml" \
        -vga virtio \
        -display vnc=:0 \
        -cpu qemu64
# Start VM without cloud-init
else
    qemu-system-x86_64 \
        -m $RAM \
        -smp $CPUS \
        -drive file=$TARGET_IMAGE,if=virtio \
        -drive file=/dev/zero,if=virtio,format=raw,id=swap,if=none \
        -device virtio-blk,drive=swap \
        -device virtio-net,netdev=net0 \
        -netdev user,id=net0 \
        -vga virtio \
        -display vnc=:0 \
        -cpu qemu64
fi

# End of script
