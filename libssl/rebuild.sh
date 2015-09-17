#!/bin/sh
set -ex

VERSION="1.0.2d"

source "../rebuild-functions.sh"

# Override configure for non-standard one of OpenSSL
function configure() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local LOG="$4"
  
  OPTIONS="no-shared zlib threads"
  if [ "$PLATFORM" == "MacOSX" ]
  then
    ./Configure darwin64-x86_64-cc --prefix="$PREFIX" $OPTIONS
  elif [ "$PLATFORM" == "iPhoneSimulator" ]
  then
    if [ "$ARCH" == "x86_64" ]
    then
      ./Configure darwin64-x86_64-cc --prefix="$PREFIX" $OPTIONS
    elif [ "$ARCH" == "i386" ]
    then
      ./Configure darwin-i386-cc --prefix="$PREFIX" $OPTIONS
    fi
  elif [ "$PLATFORM" == "iPhoneOS" ]
  then
    ./Configure iphoneos-cross --prefix="$PREFIX" $OPTIONS
    sed -ie "s/-isysroot \$(CROSS_TOP)\/SDKs\/\$(CROSS_SDK)//" "Makefile"  # -isysroot is already defined through CC
  fi
}

# Download source
if [ ! -f "openssl-$VERSION.tar.gz" ]
then
  curl -O "https://www.openssl.org/source/openssl-$VERSION.tar.gz"
fi

# Extract source
rm -rf "openssl-$VERSION"
tar -xvf "openssl-$VERSION.tar.gz"

# Build library
pushd "openssl-$VERSION"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "openssl-$VERSION"
