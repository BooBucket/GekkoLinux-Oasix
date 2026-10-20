#!/bin/sh
#This script installs some usable programs, such as iw, eudev, dbus etc.

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
SRC_DIR="${SCRIPT_DIR}/Sources"
mkdir -p "$SRC_DIR"
echo "Sources directory: $SRC_DIR"
cd "$SRC_DIR"

echo "Installing util-linux..."
wget https://www.kernel.org/pub/linux/utils/util-linux/v2.42/util-linux-2.42.4.tar.gz
tar -xf util-linux-2.42.4.tar.gz
UTILLINUX_DIRNAME="util-linux-2.42.4"
cd "$UTILLINUX_DIRNAME"

./configure \
    --prefix=/usr \
    --bindir=/usr/bin \
    --sbindir=/usr/sbin \
    --libdir=/usr/lib \
    --runstatedir=/run \
    --disable-chfn-chsh \
    --disable-login \
    --disable-nologin \
    --disable-su \
    --disable-setpriv \
    --disable-runuser \
    --disable-pylibmount \
    --disable-static \
    --without-python \
    --without-systemd \
    --without-systemdsystemunitdir \
    ADJTIME_PATH=/var/lib/hwclock/adjtime

make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== Util-linux is successfully installed! =="

cd "$SRC_DIR"
echo "Installing eudev..."
git clone https://github.com/eudev-project/eudev.git
cd eudev

./autogen.sh
./configure --prefix=/usr --sysconfdir=/etc --disable-static

make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install

echo "== Eudev is successfully installed! =="

cd "$SRC_DIR"
echo "Installing dhcpcd..."
wget https://github.com/NetworkConfiguration/dhcpcd/releases/download/v10.5.2/dhcpcd-10.5.2.tar.xz
tar -xf dhcpcd-10.5.2.tar.xz
DHCPD_DIRNAME="dhcpcd-10.5.2"
cd "$DHCPD_DIRNAME"

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --sbindir=/sbin \
    --libexecdir=/lib/dhcpcd \
    --dbdir=/var/lib/dhcpcd \
    --runstatedir=/run

make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install

ln -sf /etc/init.d/dhcpd "${MOUNT_POINT}/etc/runlevels/default/dhcpcd"

echo "== DHCP is successfully installed! =="

cd "$SRC_DIR"
echo "Installing iw..."
echo "Installing libnl..."
wget https://github.com/thom311/libnl/releases/download/libnl3_12_0/libnl-3.12.0.tar.gz
tar -xf libnl-3.12.0.tar.gz
LIBNL_DIRNAME="libnl-3.12.0"
cd "$LIBNL_DIRNAME"

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --disable-static  &&
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== libnl installed! =="

cd "$SRC_DIR"
wget https://www.kernel.org/pub/software/network/iw/iw-6.17.tar.xz
tar -xf iw-6.17.tar.xz
IW_DIRNAME="iw-6.17"
cd "$IW_DIRNAME"
export PKG_CONFIG_PATH="$MOUNT_POINT/usr/lib/pkgconfig:$MOUNT_POINT/usr/share/pkgconfig"

sed -i "/INSTALL.*gz/s/.gz//" Makefile &&
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install

echo "== iw is successfully installed! =="

cd "$SRC_DIR"

echo "Installing archive programs (bzip2, tar, gzip, xz)..."

echo "Installing bzip2..."
wget https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
tar -xf bzip2-1.0.8.tar.gz
BZIP_DIRNAME="bzip2-1.0.8"
cd "$BZIP_DIRNAME"

BZIP2_VER=$(pwd | sed 's/.*bzip2-//')
make -f Makefile-libbz2_so
make clean
make -j$(nproc)
make PREFIX="$MOUNT_POINT/usr" install
cp -av libbz2.so.* "$MOUNT_POINT/usr/lib/" &&
ln -sf libbz2.so.${BZIP2_VER} "$MOUNT_POINT/usr/lib/libbz2.so"
echo "== Bzip2 installed! =="

cd "$SRC_DIR"
echo "Installing tar..."
wget https://ftp.gnu.org/gnu/tar/tar-1.35.tar.gz
tar -xf tar-1.35.tar.gz
TAR_DIRNAME="tar-1.35"
cd "$TAR_DIRNAME"

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr &&
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== Tar installed! =="

cd "$SRC_DIR"
echo "Installing gzip..."
wget https://ftp.gnu.org/gnu/gzip/gzip-1.15.tar.gz
tar -xf gzip-1.15.tar.gz
TAR_DIRNAME="gzip-1.15"
cd "$TAR_DIRNAME"

FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== Gzip installed! =="

cd "$SRC_DIR"
echo "Installing XZ..."
wget https://github.com/tukaani-project/xz/releases/download/v5.8.4/xz-5.8.4.tar.gz
tar -xf xz-5.8.4.tar.gz
XZ_DIRNAME="xz-5.8.4"
cd "$XZ_DIRNAME"

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.4
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== XZ installed! =="
echo "== Archive programs are successfully installed! =="

cd "$SRC_DIR"

echo "Installing GNU Nano..."
wget https://ftp.gnu.org/gnu/nano/nano-9.2.tar.xz
tar -xf nano-9.2.tar.xz
NANO_DIRNAME="nano-9.2"
cd "$NANO_DIRNAME"

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-color    \
            --enable-utf8 &&
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== GNU Nano is successfully installed! =="

cd "$SRC_DIR"

echo "Installing Vim..."
git clone --depth 1 https://github.com/vim/vim.git
cd vim

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-features=normal \
    --enable-multibyte \
    --disable-gui \
    --without-x \
    --with-tlib=ncurses &&
make -j$(nproc)
make DESTDIR="$MOUNT_POINT" install
echo "== Vim is successfully installed! =="

cd "$SRC_DIR"

echo "Installing wpa_supplicant..."
wget https://w1.fi/releases/wpa_supplicant-2.12.tar.gz
tar -xf wpa_supplicant-2.12.tar.gz
WPASUP_DIRNAME="wpa_supplicant-2.12"
cd "$WPASUP_DIRNAME/wpa_supplicant"
export PKG_CONFIG_PATH="$MOUNT_POINT/usr/lib/pkgconfig:$MOUNT_POINT/usr/share/pkgconfig"

cp -v defconfig .config &&
echo "CONFIG_LIBNL32=y" >> .config &&
echo "CONFIG_BGSCAN_SIMPLE=y" >> .config &&
make -j$(nproc) BINDIR=/usr/sbin &&
make DESTDIR="$MOUNT_POINT" BINDIR=/usr/sbin install

echo "== wpa_supplicant is successfully installed! =="

cd "$SRC_DIR"

echo "Installing dbus..."
wget https://dbus.freedesktop.org/releases/dbus/dbus-1.16.2.tar.xz
tar -xf dbus-1.16.2.tar.xz
DBUS_DIRNAME="dbus-1.16.2"
cd "$DBUS_DIRNAME"

mkdir build && cd build
meson setup --prefix=/usr          \
            --buildtype=release    \
            --wrap-mode=nofallback \
            -D systemd=disabled    \
            .. &&
ninja &&
meson install --destdir "$MOUNT_POINT"
mkdir -p "$MOUNT_POINT/var/lib/dbus"
dbus-uuidgen --ensure="$MOUNT_POINT/var/lib/dbus/machine-id"
ln -sf /var/lib/dbus/machine-id "$MOUNT_POINT/etc/machine-id"
echo "== dbus is successfully installed! =="

cd "$SRC_DIR"

echo "Installing htop..."
wget https://github.com/htop-dev/htop/releases/download/3.5.3/htop-3.5.3.tar.xz
tar -xf htop-3.5.3.tar.xz
HTOP_DIRNAME="htop-3.5.3"
cd "$HTOP_DIRNAME"

./configure --prefix=/usr &&
make -j$(nproc) &&
make DESTDIR="$MOUNT_POINT" install
echo "== Htop is successfully installed! =="

cd "$SCRIPT_DIR"
echo "Population done! Run 05_inject_gpa.sh"
rm -r "$SRC_DIR"
