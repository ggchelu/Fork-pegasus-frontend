#!/bin/bash

set -e  # Exit on error
set -x  # Print commands

# Environment setup
export ANDROID_SDK_ROOT=/Users/txl/Library/Android/sdk
export ANDROID_NDK_ROOT=/Users/txl/Library/Android/sdk/ndk/21.4.7075529
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export ANDROID_NDK_LATEST_HOME=$ANDROID_NDK_ROOT
export ANDROID_NDK=$ANDROID_NDK_ROOT
export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export QT_VERSION=5.15.2
export QT_INSTALL_DIR=/Users/txl/Qt
export QT_SRC_DIR=/Users/txl/Desktop/qt-everywhere-src-5.15.2

# Architecture to build for
export ANDROID_ABI=${ANDROID_ABI:-arm64-v8a}

echo "=== Environment Variables ==="
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
echo "JAVA_HOME: $JAVA_HOME"
echo "QT_INSTALL_DIR: $QT_INSTALL_DIR"
echo "QT_SRC_DIR: $QT_SRC_DIR"
echo "ANDROID_ABI: $ANDROID_ABI"
echo ""

# Step 1: Build Qt for Android if not already built
if [ ! -d "$QT_INSTALL_DIR/$QT_VERSION/android/bin" ]; then
    echo "=== Building Qt $QT_VERSION for Android ==="
    mkdir -p $QT_INSTALL_DIR
    cd $QT_SRC_DIR
    
    # Clean previous build if exists
    if [ -f "Makefile" ]; then
        make clean || true
    fi
    
    ./configure \
        -prefix $QT_INSTALL_DIR/$QT_VERSION/android \
        -opensource \
        -confirm-license \
        -release \
        -xplatform android-clang \
        -android-ndk $ANDROID_NDK_ROOT \
        -android-sdk $ANDROID_SDK_ROOT \
        -android-ndk-platform android-30 \
        -android-arch $ANDROID_ABI \
        -nomake tests \
        -nomake examples \
        -skip qtwebengine \
        -skip qtwebview \
        -skip qtpurchasing \
        -no-warnings-are-errors
    
    make -j$(sysctl -n hw.ncpu)
    make install
    
    echo "=== Qt build completed ==="
else
    echo "=== Qt already built, skipping ==="
fi

# Step 2: Initialize submodules
echo "=== Initializing Git submodules ==="
cd /Users/txl/Documents/EMUDECK/Fork-Pegasus
git submodule update --init --recursive

# Step 3: Build Pegasus for Android
echo "=== Building Pegasus Frontend for Android ==="
export PATH=$QT_INSTALL_DIR/$QT_VERSION/android/bin:$PATH

# Clean previous build
rm -rf build-android
mkdir -p build-android
cd build-android

# Run qmake
$QT_INSTALL_DIR/$QT_VERSION/android/bin/qmake .. \
    ENABLE_APNG=1 \
    ANDROID_ABIS=$ANDROID_ABI \
    FORCE_QT_PNG=1

# Build
make -j$(sysctl -n hw.ncpu)

# Install to android build directory
make install INSTALL_ROOT=$PWD/android-build

echo "=== Building APK ==="
# Create the APK
$QT_INSTALL_DIR/$QT_VERSION/android/bin/androiddeployqt \
    --input src/app/android-pegasus-fe-deployment-settings.json \
    --output $PWD/android-build \
    --android-platform android-30 \
    --gradle

echo "=== Build Complete ==="
echo "APK location: build-android/android-build/build/outputs/apk/debug/"
ls -lh build-android/android-build/build/outputs/apk/debug/*.apk

