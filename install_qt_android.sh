#!/bin/bash

set -e
set -x

# This script installs Qt 5.15.2 for Android using aqtinstall

# Check if aqtinstall is available
if ! command -v aqt &> /dev/null; then
    echo "Installing aqtinstall..."
    python3 -m pip install --user aqtinstall
fi

# Install Qt for Android
QT_INSTALL_DIR=/Users/txl/Qt
mkdir -p $QT_INSTALL_DIR

echo "Installing Qt 5.15.2 for Android..."
python3 -m aqt install-qt mac android 5.15.2 android_arm64_v8a -O $QT_INSTALL_DIR

echo "Qt installation complete!"
echo "Qt installed to: $QT_INSTALL_DIR/5.15.2/android_arm64_v8a/"

