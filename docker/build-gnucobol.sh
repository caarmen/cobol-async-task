#!/usr/bin/env bash

set -e

gnucobol_version="3.2"

curl "https://ftp.gnu.org/gnu/gnucobol/gnucobol-${gnucobol_version}.tar.gz" --output gnucobol.tar.gz
tar xzf "gnucobol.tar.gz"
rm "gnucobol.tar.gz"
mv "gnucobol-${gnucobol_version}" gnucobol

# Build cobc forcing support for CBL_GC_WAITPID.
# Also disable some features to build faster.
pushd gnucobol || exit
./configure \
    CC=clang \
    CPPFLAGS="-DHAVE_SYS_WAIT_H=1" \
    --without-db \
    --without-xml2 \
    --disable-dependency-tracking \
    --with-json=no \
    --with-curses=no \

make SUBDIRS="lib libcob cobc config"
make install SUBDIRS="lib libcob cobc config"
ldconfig
make clean SUBDIRS="lib libcob cobc config"


popd || exit