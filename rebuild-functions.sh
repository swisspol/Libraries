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

function configure() {
  local PLATFORM="$1"
  local ARCH="$2"
  local PREFIX="$3"
  local LOG="$4"
  
  if [ "$ARCH" == "x86_64" ] || [ "$ARCH" == "i386" ]
  then
    HOST="i386-apple-darwin"
  elif [ "$ARCH" == "arm64" ] || [ "$ARCH" == "armv7" ]
  then
    HOST="arm-apple-darwin"
  fi
  
  ./configure --prefix="$PREFIX" --host="$HOST" --enable-static --disable-shared $EXTRA_CONFIGURE_OPTIONS > "$LOG"
}

function build_library_arch () {
  local DESTINATION="$1"
  local PLATFORM="$2"
  local ARCH="$3"

  local PREFIX="$DESTINATION-$ARCH"
  local LOG="$PREFIX.log"

  # Find SDK
  DEVROOT="$DEVELOPER_DIR/Platforms/$PLATFORM.platform/Developer"
  if [ "$PLATFORM" == "MacOSX" ]
  then
    SDKROOT="$DEVROOT/SDKs/$PLATFORM$OSX_SDK_VERSION.sdk"
  else
    SDKROOT="$DEVROOT/SDKs/$PLATFORM$IOS_SDK_VERSION.sdk"
  fi
  
  # Find tools
  export CC=`xcrun -find clang`
  export CPP="$CC -E"
  export CXX=`xcrun -find clang++`
  export CXXCPP="$CC -E"
  export LD=`xcrun -find ld`
  export AR=`xcrun -find ar`
  export RANLIB=`xcrun -find ranlib`
  export LIPO=`xcrun -find lipo`
  export STRIP=`xcrun -find strip`
  export CC_FOR_BUILD=`xcrun -find clang`
  
  # Override tools to compile for SDK
  CC_FLAGS="-isysroot $SDKROOT -arch $ARCH"
  LD_FLAGS="-isysroot $SDKROOT -arch $ARCH"
  if [ "$PLATFORM" == "MacOSX" ]
  then
    CC_FLAGS="$CC_FLAGS -mmacosx-version-min=$OSX_MIN_VERSION"
  elif [ "$PLATFORM" == "iPhoneSimulator" ]
  then
    CC_FLAGS="$CC_FLAGS -mios-simulator-version-min=$IOS_MIN_VERSION"
  elif [ "$PLATFORM" == "iPhoneOS" ]
  then
    CC_FLAGS="$CC_FLAGS -miphoneos-version-min=$IOS_MIN_VERSION"
    if (( $(echo "$IOS_SDK_VERSION >= 9.0" | bc -l) ))
    then
      CC_FLAGS="$CC_FLAGS -fembed-bitcode"
    fi
  fi
  export CC="$CC $CC_FLAGS $EXTRA_CFLAGS"
  export CPP="$CPP $CC_FLAGS $EXTRA_CFLAGS"
  export CXX="$CXX $CC_FLAGS $EXTRA_CFLAGS"
  export CXXCPP="$CXXCPP $CC_FLAGS $EXTRA_CFLAGS"
  export LD="$LD $LD_FLAGS"
  
  # Work around libtool bug (see http://stackoverflow.com/questions/32622284/)
  if [ "$PLATFORM" != "MacOSX" ]
  then
    export MACOSX_DEPLOYMENT_TARGET="10.4"
  fi
  
  # Configure and build
  rm -f "$LOG"
  touch "$LOG"
  rm -rf "$PREFIX"
  configure "$PLATFORM" "$ARCH" "$PREFIX" "$LOG"
  make -j4 > "$LOG"
  make install > "$LOG"
  make clean > "$LOG"
  
  # Archive configure log if available
  if [ -e "config.log" ]
  then
    mv "config.log" "$DESTINATION/configure-$ARCH.log"
  fi
  
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
    if [ -L "$LIBRARY" ]  # Preserve symbolic link as-is
    then
      if [ ! -e "$DESTINATION/lib/$LIBRARY" ]
      then
        mv "$LIBRARY" "$DESTINATION/lib/$LIBRARY"
      fi
    else
      $STRIP -S -o "$LIBRARY~" "$LIBRARY"  # Strip debugging symbols
      mv -f "$LIBRARY~" "$LIBRARY"
      if [ -e "$DESTINATION/lib/$LIBRARY" ]
      then
        $LIPO -create "$DESTINATION/lib/$LIBRARY" "$LIBRARY" -output "$DESTINATION/lib/$LIBRARY"
      else
        mv "$LIBRARY" "$DESTINATION/lib/$LIBRARY"
      fi
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
