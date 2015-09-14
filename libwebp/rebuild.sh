#!/bin/sh
set -ex

VERSION="0.4.3"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "libwebp-$VERSION.tar.gz" ]
then
  curl -O "http://downloads.webmproject.org/releases/webp/libwebp-$VERSION.tar.gz"
fi

# Extract source
rm -rf "libwebp-$VERSION"
tar -xvf "libwebp-$VERSION.tar.gz"

# Build library
pushd "libwebp-$VERSION"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "libwebp-$VERSION"
