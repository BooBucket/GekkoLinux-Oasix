#!/bin/sh
# This script creates directories for the future system

echo "Gekko Oasix build system V0.1"
echo "== Stage 1: Setup & Bootstrap. =="

echo "Checking root rights..."
CURRENT_USER=$(whoami)

if [ "$CURRENT_USER" = "root" ]; then
    echo "Root rights found."
else
    echo "Fatal: This script needs to be ran with root rights. Aborting..."
    exit 1
fi

read -p "Enter your disk type (IDE, SATA, NVME): " DISK_TNAME

if [ "$DISK_TNAME" = "IDE" ] || [ "$DISK_TNAME" = "ide" ] || [ "$DISK_TNAME" = "Ide" ]; then
    DISK_PREFIX="/dev/hd"
elif [ "$DISK_TNAME" = "SATA" ] || [ "$DISK_TNAME" = "sata" ] || [ "$DISK_TNAME" = "Sata" ]; then
    DISK_PREFIX="/dev/sd"
elif [ "$DISK_TNAME" = "NVME" ] || [ "$DISK_TNAME" = "nvme" ] || [ "$DISK_TNAME" = "Nvme" ]; then
    DISK_PREFIX="/dev/nvme0n"
fi

read -p "Enter disk name (a-z, 1-9): " DISK_NAME
read -p "Enter disk suffix (1-9, p1-9): " DISK_SUFFIX

DISK_FULLNAME="$DISK_PREFIX$DISK_NAME$DISK_SUFFIX"

read -p "Is $DISK_FULLNAME right name of partition? (y/n): " ANS

if [ "$ANS" = "y" ]; then

    MOUNT_POINT="/mnt/gekko"
    mkdir -p "$MOUNT_POINT"
    echo "Mounting $DISK_FULLNAME to $MOUNT_POINT..."
    if ! mountpoint -q "$MOUNT_POINT"; then
        mount -t ext4 "$DISK_FULLNAME" "$MOUNT_POINT"
    fi
    echo "Creating root folders..."
    mkdir -p "$MOUNT_POINT/bin"
    mkdir -p "$MOUNT_POINT/boot"
    mkdir -p "$MOUNT_POINT/dev"
    mkdir -p "$MOUNT_POINT/etc"
    mkdir -p "$MOUNT_POINT/home"
    mkdir -p "$MOUNT_POINT/lib"
    mkdir -p "$MOUNT_POINT/lib64"
    mkdir -p "$MOUNT_POINT/media"
    mkdir -p "$MOUNT_POINT/mnt"
    mkdir -p "$MOUNT_POINT/opt"
    mkdir -p "$MOUNT_POINT/proc"
    mkdir -p "$MOUNT_POINT/root"
    mkdir -p "$MOUNT_POINT/run"
    mkdir -p "$MOUNT_POINT/sbin"
    mkdir -p "$MOUNT_POINT/srv"
    mkdir -p "$MOUNT_POINT/sys"
    mkdir -p "$MOUNT_POINT/tmp"
    mkdir -p "$MOUNT_POINT/usr"
    mkdir -p "$MOUNT_POINT/var"
    echo "Successfully created root folders!"
    exit 1
else
    echo "Error: incorrect path specified"
    exit 1
fi
