# Pegasus Android APK Build Instructions

## Summary

The build process has been successfully set up! The C++ code has compiled successfully. Only the final APK packaging step remains.

## What's Been Done

1. ✅ Installed Android NDK r21e
2. ✅ Installed Qt 5.15.2 for Android (using aqtinstall)
3. ✅ Fixed macOS-specific `sed` command issues
4. ✅ Commented out OpenSSL dependencies (optional, for HTTPS)
5. ✅ Built all C++ code successfully - `libpegasus-fe_arm64-v8a.so` was created!

## Files Created/Modified

- `build_pegasus_android.sh` - Main build script
- `src/app/install.pri` - Fixed sed commands for macOS, commented out OpenSSL libs

## Final Steps to Create APK

You need to install Gradle and complete the packaging. Run these commands in your terminal:

```bash
# 1. Install Gradle if not already installed
brew install gradle

# 2. Set environment variables
export ANDROID_SDK_ROOT=/Users/txl/Library/Android/sdk
export ANDROID_NDK_ROOT=/Users/txl/Library/Android/sdk/ndk/21.4.7075529
export ANDROID_NDK=$ANDROID_NDK_ROOT
export ANDROID_NDK_HOME=$ANDROID_NDK_ROOT
export ANDROID_NDK_LATEST_HOME=$ANDROID_NDK_ROOT
export JAVA_HOME=/opt/homebrew/opt/openjdk@11
export PATH=/opt/homebrew/opt/openjdk@11/bin:$PATH

# 3. Navigate to build directory
cd /Users/txl/Documents/EMUDECK/Fork-Pegasus/build-android

# 4. Install the library
make install INSTALL_ROOT=$PWD/android-build

# 5. Package the APK
/Users/txl/Qt/5.15.2/android/bin/androiddeployqt \\
    --input src/app/android-pegasus-fe-deployment-settings.json \\
    --output $PWD/android-build \\
    --android-platform android-30 \\
    --gradle
```

## Find Your APK

After successful build, your APK will be located at:
```
/Users/txl/Documents/EMUDECK/Fork-Pegasus/build-android/android-build/build/outputs/apk/debug/android-build-debug.apk
```

## Alternative: Use the Build Script

If you prefer, just run:
```bash
cd /Users/txl/Documents/EMUDECK/Fork-Pegasus
./build_pegasus_android.sh
```

This will do a clean build from scratch.

## Notes

- The build is configured for `arm64-v8a` architecture (64-bit ARM)
- OpenSSL support is disabled (HTTPS may not work, but basic functionality will)
- The APK will be a debug build (not signed for release)

## Troubleshooting

If you encounter issues:

1. **Gradle not found**: Install with `brew install gradle`
2. **Java version issues**: Make sure you're using Java 11 (OpenJDK@11)
3. **NDK errors**: Verify NDK is at `/Users/txl/Library/Android/sdk/ndk/21.4.7075529`
4. **Qt errors**: Verify Qt is at `/Users/txl/Qt/5.15.2/android`

## Building for Other Architectures

To build for 32-bit ARM (armeabi-v7a):
```bash
export ANDROID_ABI=armeabi-v7a
./build_pegasus_android.sh
```

## Success!

The hard part (building Qt-based C++ code for Android) is complete! Just need to wrap it up with Gradle.

