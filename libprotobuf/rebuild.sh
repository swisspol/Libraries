#!/bin/sh
set -ex

VERSION="2.6.1"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "protobuf-$VERSION.tar.gz" ]
then
  curl -L -O "https://github.com/google/protobuf/releases/download/v$VERSION/protobuf-$VERSION.tar.gz"
fi

# Extract source
rm -rf "protobuf-$VERSION"
tar -xvf "protobuf-$VERSION.tar.gz"

# Build library
pushd "protobuf-$VERSION"

EXTRA_CONFIGURE_OPTIONS=""
build_library_macosx
rm -f "../MacOSX/lib/libprotoc.a"

EXTRA_CONFIGURE_OPTIONS="--with-protoc=`pwd`/../MacOSX/bin/protoc"
build_library_iphonesimulator
rm -f "../iPhoneSimulator/lib/libprotoc.a"
build_library_iphoneos
rm -f "../iPhoneOS/lib/libprotoc.a"

popd

# Clean up
rm -rf "protobuf-$VERSION"
