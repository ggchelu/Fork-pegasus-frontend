FROM ubuntu:20.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_ROOT=/opt/android-ndk
ENV QT_VERSION=5.15.2
ENV QT_INSTALL_DIR=/opt/Qt
ENV PATH=${QT_INSTALL_DIR}/${QT_VERSION}/android/bin:${PATH}

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    python3 \
    openjdk-11-jdk \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up JAVA_HOME
RUN echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /etc/environment && \
    . /etc/environment && \
    java -version

# Install Qt 5.15.2
RUN mkdir -p ${QT_INSTALL_DIR} && cd ${QT_INSTALL_DIR} \
    && wget https://download.qt.io/archive/qt/5.15/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz \
    && tar xf qt-everywhere-src-${QT_VERSION}.tar.xz \
    && cd qt-everywhere-src-${QT_VERSION} \
    && ./configure -prefix ${QT_INSTALL_DIR}/${QT_VERSION} \
        -opensource -confirm-license \
        -release -shared \
        -nomake examples -nomake tests \
        -android-ndk ${ANDROID_NDK_ROOT} \
        -android-sdk ${ANDROID_SDK_ROOT} \
        -android-ndk-host linux-x86_64 \
        -android-arch arm64-v8a \
        -skip qtwebengine \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf qt-everywhere-src-${QT_VERSION} qt-everywhere-src-${QT_VERSION}.tar.xz

# Install Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && cd ${ANDROID_SDK_ROOT}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip \
    && unzip commandlinetools-linux-8092744_latest.zip \
    && mv cmdline-tools latest \
    && rm commandlinetools-linux-8092744_latest.zip \
    && cd latest/bin \
    && yes | ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses \
    && ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Install Android NDK
RUN mkdir -p ${ANDROID_NDK_ROOT} && cd ${ANDROID_NDK_ROOT} \
    && wget https://dl.google.com/android/repository/android-ndk-r21e-linux-x86_64.zip \
    && unzip android-ndk-r21e-linux-x86_64.zip \
    && rm android-ndk-r21e-linux-x86_64.zip \
    && mv android-ndk-r21e/* . \
    && rmdir android-ndk-r21e

WORKDIR /src
COPY . .

# Build the project
RUN mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc)

# Create the Android APK
RUN cd build \
    && make install INSTALL_ROOT=/src/android-build \
    && androiddeployqt \
        --input android-libpegasus-fe.so-deployment-settings.json \
        --output /src/android-build \
        --android-platform android-30 \
        --jdk ${JAVA_HOME} \
        --gradle