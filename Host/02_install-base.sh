#!/bin/sh
#This script setups root user and some config files.

echo "Gekko Oasix build system V0.1"
echo "== Stage 2: Install base components. =="

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
SRC_DIR="${SCRIPT_DIR}/Sources"

mkdir -p "$SRC_DIR"

echo "Sources directory: $SRC_DIR"

LINUX_KRNL_DIR_NAME="linux-7.2.11"
cd "$SRC_DIR"
wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.2.11.tar.xz
tar -xf linux-7.2.11.tar.xz
cd linux-7.2.11
make mrproper
make headers_install ARCH=x86_64 INSTALL_HDR_PATH="$MOUNT_POINT/usr"

echo "Installing Glibc..."
GLIBC_DIR_NAME="glibc-2.44"
GLIBC_VER="2.44"
cd "$SRC_DIR"
wget https://ftp.gnu.org/gnu/glibc/glibc-2.44.tar.xz
tar -xf glibc-2.44.tar.xz
cd "$GLIBC_DIR_NAME"
GLIBC_BUILD_DIR="glibc-build"
cd "$SRC_DIR"
mkdir -p "$GLIBC_BUILD_DIR" && cd "$GLIBC_BUILD_DIR"
../"${GLIBC_DIR_NAME}"/configure \
    --prefix=/usr \
    --host=x86_64-pc-linux-gnu \
    --build=x86_64-pc-linux-gnu \
    --enable-kernel=4.19 \
    --with-headers="$MOUNT_POINT/usr/include"

make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "=== Glibc successfully installed! ==="

echo "Installing Bash..."
BASH_DIR_NAME="bash-5.3"
cd "$SRC_DIR"
wget https://ftp.gnu.org/gnu/bash/bash-5.3.tar.gz
tar -xf bash-5.3.tar.gz
cd "$BASH_DIR_NAME"
./configure --prefix=/usr
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "Creating Bash symlinks..."
ln -sf /usr/bin/bash "$MOUNT_POINT"/bin/bash
ln -sf bash "$MOUNT_POINT"/bin/sh
echo "=== Bash successfully installed! ==="

echo "installing GNU Coreutils..."
COREUTILS_DIR_NAME="coreutils-9.12"
cd "$SRC_DIR"
wget https://ftp.gnu.org/gnu/coreutils/coreutils-9.12.tar.xz
tar -xf coreutils-9.12.tar.xz
cd "$COREUTILS_DIR_NAME"
FORCE_UNSAFE_CONFIGURE=1 ./configure \
    --prefix=/usr \
    --enable-no-install-program=kill,uptime
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "=== GNU Coreutils successfully installed! ==="


echo "Installing Linux kernel..."
cd "${SRC_DIR}/${LINUX_KRNL_DIR_NAME}"
make mrproper
make defconfig

read -p "Do you want to customize the Linux kernel? (y/n): " ANS

if [ "$ANS" = "y" ] || [ "$ANS" = "Y" ]; then
    make menuconfig
    echo "Menuconfig done. Starting the compilation..."
    make -j$(nproc)
    make modules_install INSTALL_MOD_PATH="$MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"/boot
    cp -v arch/x86/boot/bzImage "$MOUNT_POINT"/boot/vmlinuz-7.2.11-gekko
else
    echo "OK. Starting the compilation..."
    make -j$(nproc)
    make modules_install INSTALL_MOD_PATH="$MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"/boot
    cp -v arch/x86/boot/bzImage "$MOUNT_POINT"/boot/vmlinuz-7.2.11-gekko
fi

echo "Base installation done. Run 03_install-openrc.sh ."
rm -r "$SRC_DIR"
