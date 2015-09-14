#!/bin/sh
set -ex

VERSION="2.1.0"

source "../rebuild-functions.sh"

# Download source
if [ ! -f "expat-$VERSION.tar.gz" ]
then
  curl -O "http://iweb.dl.sourceforge.net/project/expat/expat/$VERSION/expat-$VERSION.tar.gz"
fi

# Extract source
rm -rf "expat-$VERSION"
tar -xvf "expat-$VERSION.tar.gz"

# Patch source to force-include unistd.h
echo "#include <unistd.h>" > "expat-$VERSION/xmlwf/readfilemap.c~"
cat "expat-$VERSION/xmlwf/readfilemap.c" >> "expat-$VERSION/xmlwf/readfilemap.c~"
mv -f "expat-$VERSION/xmlwf/readfilemap.c~" "expat-$VERSION/xmlwf/readfilemap.c"

# Build library
pushd "expat-$VERSION"

build_library_macosx
build_library_iphonesimulator
build_library_iphoneos

popd

# Clean up
rm -rf "expat-$VERSION"
