#!/bin/sh
#This script installs OpenRC

echo "Gekko Oasix build system V0.1"
echo "== Stage 3: Install OpenRC. =="

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

echo "Installing OpenRC..."

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SRC_DIR="${SCRIPT_DIR}/Sources"
mkdir -p "$SRC_DIR"
echo "Sources directory: $SRC_DIR"
cd "$SRC_DIR"
git clone https://github.com/OpenRC/openrc.git

OPENRC_SRC_DIRNAME="openrc"
cd "$OPENRC_SRC_DIRNAME"

meson setup builddir \
    --prefix=/usr \
    --bindir=/bin \
    --sbindir=/sbin \
    --libdir=/lib64 \
    --libexecdir=/lib \
    --buildtype=release \
    -Dpam=false \
    -Dselinux=disabled

ninja -C builddir
DESTDIR="$MOUNT_POINT" meson install -C builddir

ln -sf /sbin/openrc-init "${MOUNT_POINT}/sbin/init"
echo "=== OpenRC successfully installed! ==="
rm -r "$SRC_DIR"
