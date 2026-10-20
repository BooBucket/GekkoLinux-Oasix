#!/bin/sh
#This script installs wget and injects GPA

echo "Gekko Oasix build system V0.1"
echo "== Stage 4: Populate system (Install usable programs). =="

echo "Checking root rights..."
CURRENT_USER=$(whoami)

if [ "$CURRENT_USER" = "root" ]; then
    echo "Root rights found."
else
    echo "Fatal: This script needs to be ran with root rights. Aborting..."
    exit 1
fi

MOUNT_POINT="/mnt/gekko"
echo "Checking is $MOUNT_POINT mounted..."
if [ ! -d "$MOUNT_POINT" ]; then
    read -p "$MOUNT_POINT is not mounted! Please, enter the name of Gekko Linux's partition manually here: " DISK_FULLNAME
    echo "Mounting $MOUNT_POINT.."
    mkdir -p "$MOUNT_POINT"
    mount -t ext4 "$DISK_FULLNAME" "$MOUNT_POINT"
    echo "$MOUNT_POINT is mounted!"
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
EXO_DIR=SRC_DIR="${SCRIPT_DIR}/Exo"
mkdir -p "$EXO_DIR"

echo "Injecting EXO package manager..."
cd "$EXO_DIR"
wget https://github.com/BooBucket/GekkoLinux-EXO/releases/download/unstable/gekko-exo-2026.10.19.tar.gz
tar -xf gekko-exo-2026.10.19.tar.gz
cd gekko-exo-2026.10.19

EXO_EXENAME="exo"
chmod +x "$EXO_EXENAME" &&
cp -v "$EXO_EXENAME" "$MOUNT_POINT/usr/bin" &&
ln -sf /usr/bin/exo "$MOUNT_POINT/bin/exo"

echo "== EXO Package manager is successfully injected! You may now start chroot configuring."
