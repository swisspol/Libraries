#!/bin/sh

OSX_MIN_VERSION="10.8"
OSX_ARCHS="x86_64"

IOS_MIN_VERSION="8.0"
IOS_SIMULATOR_ARCHS="i386 x86_64"
IOS_DEVICE_ARCHS="armv7 arm64"

IOS_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^iPhone' | tail -n 1 |  awk '{ print $2 }'`
OSX_SDK_VERSION=`xcodebuild -version -sdk | grep -A 1 '^MacOSX' | tail -n 1 |  awk '{ print $2 }'`
DEVELOPER_DIR=`xcode-select --print-path`

function post_build_hook() {
  echo "Post build hook"
}

function post_package_hook() {
  echo "Post package hook"
}

function build_library_arch () {
  local DESTINATION="$1"
  local PLATFORM="$2"
  local ARCH="$3"

  local PREFIX="$DESTINATION-$ARCH"
  local LOG="$PREFIX.log"

  # Find SDK
  export DEVROOT="$DEVELOPER_DIR/Platforms/$PLATFORM.platform/Developer"
  if [ "$PLATFORM" == "MacOSX" ]
  then
    export SDKROOT="$DEVROOT/SDKs/$PLATFORM$OSX_SDK_VERSION.sdk"
  else
    export SDKROOT="$DEVROOT/SDKs/$PLATFORM$IOS_SDK_VERSION.sdk"
  fi

  # Find tools
  export CC=`xcrun -find clang`
  export CPP="$CC -E"
  export LD=`xcrun -find ld`
  export AR=`xcrun -find ar`
  export RANLIB=`xcrun -find ranlib`
  export LIPO=$(xcrun -find lipo)

  # Set up build environment
  export CFLAGS="-arch $ARCH -isysroot $SDKROOT -I$SDKROOT/usr/include"
  export LDFLAGS="-arch $ARCH -isysroot $SDKROOT -L$SDKROOT/usr/lib"
  if [ "$PLATFORM" == "MacOSX" ]
  then
    export CFLAGS="$CFLAGS -mmacosx-version-min=$OSX_MIN_VERSION"
    export LDFLAGS="$LDFLAGS -mmacosx-version-min=$OSX_MIN_VERSION"
  elif [ "$PLATFORM" == "iPhoneSimulator" ]
  then
    export CFLAGS="$CFLAGS -mios-simulator-version-min=$IOS_MIN_VERSION"
    export LDFLAGS="$LDFLAGS -mios-simulator-version-min=$IOS_MIN_VERSION"
  elif [ "$PLATFORM" == "iPhoneOS" ]
  then
    export CFLAGS="$CFLAGS -miphoneos-version-min=$IOS_MIN_VERSION  -fembed-bitcode"
    export LDFLAGS="$LDFLAGS -miphoneos-version-min=$IOS_MIN_VERSION"
  fi
  export CFLAGS="$CFLAGS $EXTRA_CFLAGS"
  export CPPFLAGS="$CFLAGS"
  if [ "$ARCH" == "x86_64" ]
  then
    HOST="i386"
  elif [ "$ARCH" == "arm64" ]
  then
    HOST="arm"
  else
    HOST="$ARCH"
  fi

  # Configure and build
  rm -f "$LOG"
  touch "$LOG"
  rm -rf "$PREFIX"
  ./configure \
    --prefix="$PREFIX" \
    --host=$HOST-apple-darwin \
    --enable-static \
    --disable-shared \
    $EXTRA_CONFIGURE_OPTIONS > "$LOG"
  make -j4 > "$LOG"
  make install > "$LOG"
  make clean > "$LOG"
  
  # Hook
  post_build_hook "$PLATFORM" "$ARCH" "$PREFIX" "$DESTINATION"
  
  # Copy "bin/" for first architecture and on OS X only
  if [ "$PLATFORM" == "MacOSX" ] && [ -d "$PREFIX/bin" ] && [ ! -d "$DESTINATION/bin" ]
  then
      mv "$PREFIX/bin" "$DESTINATION/bin"
  fi
  
  # Copy "include/" for first architecture only
  if [ ! -d "$DESTINATION/include" ]
  then
    mv "$PREFIX/include" "$DESTINATION/include"
  fi
  
  # Copy and merge "lib/"
  mkdir -p "$DESTINATION/lib"
  pushd "$PREFIX/lib"
  for LIBRARY in *.a
  do
    if [ -e "$DESTINATION/lib/$LIBRARY" ]
    then
      $LIPO -create "$DESTINATION/lib/$LIBRARY" "$LIBRARY" -output "$DESTINATION/lib/$LIBRARY"
    else
      mv "$LIBRARY" "$DESTINATION/lib/$LIBRARY"
    fi
  done
  popd
  
  # Hook
  post_package_hook "$PLATFORM" "$ARCH" "$PREFIX" "$DESTINATION"
  
  # Clean up
  rm -rf "$PREFIX"
  rm -f "$LOG"
}

function build_library_platform () {
  local PREFIX="$1"
  local PLATFORM="$2"
  local ARCHS="$3"

  local PREFIX="$PREFIX/$PLATFORM"

  # Build each arch for the platform
  rm -rf "$PREFIX"
  mkdir -p "$PREFIX"
  for ARCH in ${ARCHS}
  do
    build_library_arch "$PREFIX" "$PLATFORM" "$ARCH"
  done
}

function build_library_macosx () {
  build_library_platform "`pwd`/.." "MacOSX" "$OSX_ARCHS"
}

function build_library_iphonesimulator () {
  build_library_platform "`pwd`/.." "iPhoneSimulator" "$IOS_SIMULATOR_ARCHS"
}

function build_library_iphoneos () {
  build_library_platform "`pwd`/.." "iPhoneOS" "$IOS_DEVICE_ARCHS"
}
