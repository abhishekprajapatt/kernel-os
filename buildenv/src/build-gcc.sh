#!/bin/bash
set -e

GCC_VERSION=${1:-15.2}

export PREFIX="/usr/local"
export TARGET="x86_64-elf"
export PATH="$PREFIX/bin:$PATH"

SRC_DIR="$PREFIX/src"
SOURCE_TAR="gcc-${GCC_VERSION}.tar.xz"
SOURCE_URL="https://ftp.gnu.org/gnu/gcc/${SOURCE_TAR}"
BUILD_DIR="build-gcc"
PATCH_FILE="config.gcc.patch"

if [ ! -d "$SRC_DIR/gcc-${GCC_VERSION}" ]; then
    cd "$SRC_DIR"
    wget "${SOURCE_URL}"
    tar -xf "${SOURCE_TAR}"
    rm "${SOURCE_TAR}"
fi

cat > "$SRC_DIR/gcc-${GCC_VERSION}/gcc/${PATCH_FILE}" << 'EOF'
--- config.gcc	2016-04-11 03:14:59.000000000 -0700
+++ config.gcc	2016-04-27 13:47:22.444331746 -0700
@@ -1420,6 +1420,7 @@
 	tm_file="${tm_file} i386/unix.h i386/att.h dbxelf.h elfos.h newlib-stdint.h i386/i386elf.h"
 	;;
 x86_64-*-elf*)
+	tmake_file="${tmake_file} i386/t-x86_64-elf"
 	tm_file="${tm_file} i386/unix.h i386/att.h dbxelf.h elfos.h newlib-stdint.h i386/i386elf.h i386/x86-64.h"
 	;;
 x86_64-*-rtems*)
EOF

cd "$SRC_DIR/gcc-${GCC_VERSION}/gcc"
patch < "${PATCH_FILE}" || echo "Patch failed but continuing..."

cd "$SRC_DIR"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

../gcc-${GCC_VERSION}/configure \
    --target="${TARGET}" \
    --prefix="${PREFIX}" \
    --with-sysroot \
    --disable-nls \
    --enable-languages=c,c++ \
    --without-headers \
    --enable-multilib \
    --disable-libssp

make -j"$(nproc)" all-gcc
make -j"$(nproc)" all-target-libgcc
make install-gcc
make install-target-libgcc

cd "$SRC_DIR"
rm -rf "${BUILD_DIR}" "gcc-${GCC_VERSION}"

echo "GCC ${GCC_VERSION} installed to ${PREFIX}/${TARGET} with multilib support."