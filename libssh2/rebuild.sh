#!/bin/sh
set -ex

VERSION="1.6.0"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "libssh2-$VERSION.tar.gz" ]
then
  curl -O "http://www.libssh2.org/download/libssh2-$VERSION.tar.gz"
fi

# Extract source
rm -rf "libssh2-$VERSION"
tar -xvf "libssh2-$VERSION.tar.gz"

# Build library
pushd "libssh2-$VERSION"

EXTRA_CONFIGURE_OPTIONS="--disable-debug --with-libz --with-openssl --with-libssl-prefix=`pwd`/../../libssl/MacOSX"
build_library_macosx

EXTRA_CONFIGURE_OPTIONS="--disable-debug --with-libz --with-openssl --with-libssl-prefix=`pwd`/../../libssl/iPhoneSimulator"
build_library_iphonesimulator

EXTRA_CONFIGURE_OPTIONS="--disable-debug --with-libz --with-openssl --with-libssl-prefix=`pwd`/../../libssl/iPhoneOS"
build_library_iphoneos

popd

# Clean up
rm -rf "libssh2-$VERSION"
