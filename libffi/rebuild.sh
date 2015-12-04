#!/bin/sh
set -ex

VERSION="3.2.1"

source "../rebuild-functions.sh"

# Override build hooks to patch "curlbuild.h" to be compatible with 32 and 64 bit architectures
function post_build_hook() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local DESTINATION="$4"

  mv "$PREFIX/lib/libffi-$VERSION/include" "$PREFIX"
  # cp "$PREFIX/include/curl/curlbuild.h" "$DESTINATION/curlbuild-$ARCH.h"
}
function post_package_hook() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local DESTINATION="$4"

  # mv "$DESTINATION/curlbuild-$ARCH.h" "$DESTINATION/include/curl/"
}

# Download source
if [ ! -f "libffi-$VERSION.tar.gz" ]
then
  curl -O "ftp://sourceware.org/pub/libffi/libffi-$VERSION.tar.gz"
fi

# Extract source
rm -rf "libffi-$VERSION"
tar -xvf "libffi-$VERSION.tar.gz"

# Build library
pushd "libffi-$VERSION"

build_library_macosx
build_library_iphonesimulator

# TODO: arm64 does not work in version 3.2.1
# TODO: Split headers in armv7 and arm64 versions
# build_library_iphoneos

popd

# Clean up
rm -rf "libffi-$VERSION"
