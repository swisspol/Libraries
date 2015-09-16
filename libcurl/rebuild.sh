#!/bin/sh
set -ex

VERSION="7.44.0"

source "../rebuild-functions.sh"

# Override build hooks
function post_build_hook() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local DESTINATION="$4"
  
  cp "$PREFIX/include/curl/curlbuild.h" "$DESTINATION/curlbuild-$ARCH.h"
}
function post_package_hook() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local DESTINATION="$4"
  
  mv "$DESTINATION/curlbuild-$ARCH.h" "$DESTINATION/include/curl/"
}

# Download source
if [ ! -f "curl-$VERSION.tar.gz" ]
then
  curl -L -O "https://github.com/bagder/curl/releases/download/curl-7_44_0/curl-$VERSION.tar.gz"
fi

# Extract source
rm -rf "curl-$VERSION"
tar -xvf "curl-$VERSION.tar.gz"

# Build library
pushd "curl-$VERSION"

EXTRA_CONFIGURE_OPTIONS="--disable-debug --disable-curldebug --disable-verbose \
  --without-ssl --without-libssh2 --with-darwinssl \
  --enable-ipv6 \
  --enable-http \
  --enable-proxy \
  --disable-ftp \
  --disable-file \
  --disable-ldap \
  --disable-ldaps \
  --disable-rtsp \
  --disable-dict \
  --disable-telnet \
  --disable-tftp \
  --disable-pop3 \
  --disable-imap \
  --disable-smb \
  --disable-smtp \
  --disable-gopher \
  --disable-manual \
  "
build_library_macosx
rm "../MacOSX/include/curl/curlbuild-x86_64.h"

build_library_iphonesimulator
printf "#ifdef __LP64__\n#include \"curlbuild-x86_64.h\"\n#else\n#include \"curlbuild-i386.h\"\n#endif\n" > "../iPhoneSimulator/include/curl/curlbuild.h"

build_library_iphoneos
printf "#ifdef __LP64__\n#include \"curlbuild-arm64.h\"\n#else\n#include \"curlbuild-armv7.h\"\n#endif\n" > "../iPhoneOS/include/curl/curlbuild.h"

popd

# Clean up
rm -rf "curl-$VERSION"
