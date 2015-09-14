#!/bin/sh
set -ex

VERSION="2.7"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "lcms2-$VERSION.tar.gz" ]
then
  curl -O "http://skylineservers.dl.sourceforge.net/project/lcms/lcms/$VERSION/lcms2-$VERSION.tar.gz"
fi

# Extract source
rm -rf "lcms2-$VERSION"
tar -xvf "lcms2-$VERSION.tar.gz"

# Build library
pushd "lcms2-$VERSION"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "lcms2-$VERSION"
