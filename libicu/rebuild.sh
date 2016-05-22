#!/bin/sh
set -ex

_VERSION="56.1"
VERSION="56_1"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "icu4c-$VERSION-src.tgz" ]
then
  curl -O "http://download.icu-project.org/files/icu4c/$_VERSION/icu4c-$VERSION-src.tgz"
fi

# Extract source (twice)
rm -rf "icu"
tar -xvf "icu4c-$VERSION-src.tgz"
rm -rf "icu~"
mv "icu" "icu~"
tar -xvf "icu4c-$VERSION-src.tgz"

### Apply patch for building 56.1 (see https://mail-index.netbsd.org/pkgsrc-users/2016/01/20/msg022855.html)

pushd "icu"
patch -p 0 < "../icu-release-56-1-flagparser-fix.patch"
popd
pushd "icu~"
patch -p 0 < "../icu-release-56-1-flagparser-fix.patch"
popd

# Pre-build for cross-compilation to satisfy "--with-cross-build=..."
pushd "icu~/source"
./configure --disable-icuio --disable-layout --disable-tests --disable-samples
make -j
popd

# Build library
pushd "icu/source"

EXTRA_CFLAGS="-DU_CHARSET_IS_UTF8=1 -DUCONFIG_NO_LEGACY_CONVERSION=1 -DUCONFIG_NO_COLLATION=1 -DUCONFIG_NO_BREAK_ITERATION=1 -DUCONFIG_NO_FORMATTING=1"

EXTRA_CONFIGURE_OPTIONS="--disable-dyload --disable-icuio --disable-layout --disable-tests --disable-samples"
build_library_macosx

build_library_iphonesimulator

EXTRA_CONFIGURE_OPTIONS="$EXTRA_CONFIGURE_OPTIONS --disable-tools --with-cross-build=`pwd`/../../icu~/source"
build_library_iphoneos

popd

# Clean up
rm -rf "icu"
rm -rf "icu~"
