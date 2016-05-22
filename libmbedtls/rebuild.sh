#!/bin/sh
set -ex

VERSION="2.2.1"

source "../rebuild-functions.sh"

# Override build hooks to make configure a no-op
function configure() {
  local PREFIX="$3"
  
  perl -p -e "s|DESTDIR=.*|DESTDIR=$PREFIX|g" "Makefile" > "Makefile~"
  mv -f "Makefile~" "Makefile"
}

# Download source
if [ ! -f "mbedtls-$VERSION-apache.tgz" ]
then
  curl -O "https://tls.mbed.org/download/mbedtls-$VERSION-apache.tgz"
fi

# Extract source
rm -rf "mbedtls-$VERSION"
tar -xvf "mbedtls-$VERSION-apache.tgz"

# Build library
pushd "mbedtls-$VERSION"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "mbedtls-$VERSION"
