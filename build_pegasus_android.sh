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
export PATH=/opt/homebrew/opt/openjdk@11/bin:$PATH
export QT_VERSION=5.15.2
export QT_INSTALL_DIR=/Users/txl/Qt
export QT_ANDROID_DIR=$QT_INSTALL_DIR/$QT_VERSION/android

# Architecture to build for
export ANDROID_ABI=${ANDROID_ABI:-arm64-v8a}

echo "=== Environment Variables ==="
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
echo "JAVA_HOME: $JAVA_HOME"
echo "QT_ANDROID_DIR: $QT_ANDROID_DIR"
echo "ANDROID_ABI: $ANDROID_ABI"
echo ""

# Step 1: Initialize submodules
echo "=== Initializing Git submodules ==="
cd /Users/txl/Documents/EMUDECK/Fork-Pegasus
git submodule update --init --recursive

# Step 2: Build Pegasus for Android
echo "=== Building Pegasus Frontend for Android ==="
export PATH=$QT_ANDROID_DIR/bin:$PATH

# Clean previous build
rm -rf build-android
mkdir -p build-android
cd build-android

# Run qmake
$QT_ANDROID_DIR/bin/qmake .. \
    ANDROID_ABIS=$ANDROID_ABI

# Build
make -j$(sysctl -n hw.ncpu)

# Install to android build directory
rm -rf android-build
mkdir -p android-build
make install INSTALL_ROOT=$PWD/android-build

echo "=== Building APK ==="
# Create the APK
$QT_ANDROID_DIR/bin/androiddeployqt \
    --input src/app/android-pegasus-fe-deployment-settings.json \
    --output $PWD/android-build \
    --android-platform android-30 \
    --gradle

echo "=== Build Complete ==="
echo "APK location: build-android/android-build/build/outputs/apk/debug/"
find build-android/android-build/build/outputs/apk -name "*.apk" -exec ls -lh {} \;

