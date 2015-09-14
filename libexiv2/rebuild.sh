#!/bin/sh
set -ex

VERSION="0.25"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "exiv2-$VERSION.tar.gz" ]
then
  curl -O "http://www.exiv2.org/exiv2-$VERSION.tar.gz"
fi

# Extract source
rm -rf "exiv2-$VERSION"
tar -xvf "exiv2-$VERSION.tar.gz"

# Work around broken "make clean"
if [ ! -d "exiv2-$VERSION/test" ]
then
  mkdir "exiv2-$VERSION/test"
  echo "clean:" > "exiv2-$VERSION/test/Makefile"
fi

# Build library
pushd "exiv2-$VERSION"

EXTRA_CONFIGURE_OPTIONS="--with-expat=`pwd`/../../libexpat/MacOSX"
build_library_macosx

EXTRA_CONFIGURE_OPTIONS="--with-expat=`pwd`/../../libexpat/iPhoneSimulator"
build_library_iphonesimulator

EXTRA_CONFIGURE_OPTIONS="--with-expat=`pwd`/../../libexpat/iPhoneOS"
build_library_iphoneos

popd

# Clean up
rm -rf "exiv2-$VERSION"
