#!/bin/sh
set -ex

VERSION="1.0.2d"

source "../rebuild-functions.sh"

rm -rf "build"
mkdir "build"

pushd "build"
curl -O "https://raw.githubusercontent.com/x2on/OpenSSL-for-iPhone/21c4109c4f5a9f9c7b6312472d59d849a59579d7/build-libssl.sh"

sed -ie "s/^VERSION=.*/VERSION=\"$VERSION\"/" "build-libssl.sh"
sed -ie "s/^MIN_SDK_VERSION=.*/MIN_SDK_VERSION=\"$IOS_MIN_VERSION\"/" "build-libssl.sh"

chmod a+x build-libssl.sh
./build-libssl.sh
popd

rm -rf "include"
mv "build/include" "include"
rm -rf "lib"
mv "build/lib" "lib"

rm -rf "build"
