#!/bin/sh
set -ex

VERSION="1.6.18"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "libpng-${VERSION}.tar.gz" ]
then
  curl -O "http://iweb.dl.sourceforge.net/project/libpng/libpng16/${VERSION}/libpng-${VERSION}.tar.gz"
fi

# Extract source
rm -rf "libpng-${VERSION}"
tar -xvf "libpng-${VERSION}.tar.gz"

# Build library
pushd "libpng-${VERSION}"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "libpng-${VERSION}"
