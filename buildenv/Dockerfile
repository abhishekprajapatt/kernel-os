FROM debian:12

ARG BINUTILS_VERSION=2.45
ARG GCC_VERSION=15.2

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        gcc \
        libgmp3-dev \
        libmpfr-dev \
        libisl-dev \
        libmpc-dev \
        texinfo \
        bison \
        flex \
        make \
        bzip2 \
        patch \
        build-essential \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && wget --no-check-certificate https://ftpmirror.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
    && wget --no-check-certificate https://ftpmirror.gnu.org/gnu/gcc/gcc-${GCC_VERSION}.0/gcc-${GCC_VERSION}.0.tar.xz \
    && tar Jxf binutils-${BINUTILS_VERSION}.tar.xz \
    && tar Jxf gcc-${GCC_VERSION}.0.tar.xz \
    && rm binutils-${BINUTILS_VERSION}.tar.xz gcc-${GCC_VERSION}.0.tar.xz

COPY buildenv/src /usr/local/src/
COPY buildenv/gcc/t-x86_64-elf /usr/local/src/gcc-${GCC_VERSION}.0/gcc/config/i386/
COPY buildenv/gcc/config.gcc.patch /usr/local/src/gcc-${GCC_VERSION}.0/gcc/

RUN set -eux \
    && cd /usr/local/src \
    && sed -i 's/\r$//' build-binutils.sh build-gcc.sh \
    && chmod +x build-binutils.sh build-gcc.sh \
    && bash build-binutils.sh ${BINUTILS_VERSION} \
    && bash build-gcc.sh ${GCC_VERSION}.0 \
    && rm -rf binutils-${BINUTILS_VERSION} gcc-${GCC_VERSION}.0

RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        nasm \
        xorriso \
        grub-pc-bin \
        grub-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /root/env
WORKDIR /root/env