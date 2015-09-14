#!/bin/sh
set -ex

VERSION="0.6.21"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "libexif-${VERSION}.tar.gz" ]
then
  curl -O "http://iweb.dl.sourceforge.net/project/libexif/libexif/$VERSION/libexif-$VERSION.tar.gz"
fi

# Extract source
rm -rf "libexif-${VERSION}"
tar -xvf "libexif-${VERSION}.tar.gz"

# Build library
pushd "libexif-${VERSION}"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "libexif-${VERSION}"
