FROM debian:stable

RUN apt-get update && apt-get install -y unzip automake build-essential curl file pkg-config git python libtool

ARG NPROC=1

WORKDIR /opt/android
## INSTALL ANDROID SDK
ENV ANDROID_SDK_REVISION 4333796
ENV ANDROID_SDK_HASH 92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9
RUN curl -s -O https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_REVISION}.zip \
    && echo "${ANDROID_SDK_HASH}  sdk-tools-linux-${ANDROID_SDK_REVISION}.zip" | sha256sum -c \
    && unzip sdk-tools-linux-${ANDROID_SDK_REVISION}.zip \
    && rm -f sdk-tools-linux-${ANDROID_SDK_REVISION}.zip

## INSTALL ANDROID NDK
ENV ANDROID_NDK_REVISION 17b
ENV ANDROID_NDK_HASH 5dfbbdc2d3ba859fed90d0e978af87c71a91a5be1f6e1c40ba697503d48ccecd
RUN curl -s -O https://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip \
    && echo "${ANDROID_NDK_HASH}  android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip" | sha256sum -c \
    && unzip android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip \
    && rm -f android-ndk-r${ANDROID_NDK_REVISION}-linux-x86_64.zip

ENV WORKDIR /opt/android
ENV ANDROID_SDK_ROOT ${WORKDIR}/tools
ENV ANDROID_NDK_ROOT ${WORKDIR}/android-ndk-r${ANDROID_NDK_REVISION}

ENV TOOLCHAIN_DIR ${WORKDIR}/toolchain-arm
RUN ${ANDROID_NDK_ROOT}/build/tools/make_standalone_toolchain.py \
         --arch arm \
         --api 21 \
         --install-dir ${TOOLCHAIN_DIR} \
         --stl=libc++

#INSTALL cmake
ENV CMAKE_VERSION 3.12.1
RUN cd /usr \
    && curl -s -O https://cmake.org/files/v3.12/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && tar -xzf /usr/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
    && rm -f /usr/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz
ENV PATH /usr/cmake-${CMAKE_VERSION}-Linux-x86_64/bin:$PATH

## Boost
ARG BOOST_VERSION=1_68_0
ARG BOOST_VERSION_DOT=1.68.0
ARG BOOST_HASH=7f6130bc3cf65f56a618888ce9d5ea704fa10b462be126ad053e80e553d6d8b7
RUN set -ex \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://dl.bintray.com/boostorg/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION}.tar.bz2 \
    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
    && rm -f boost_${BOOST_VERSION}.tar.bz2 \
    && cd boost_${BOOST_VERSION} \
    && ./bootstrap.sh

ENV HOST_PATH $PATH
ENV PATH $TOOLCHAIN_DIR/arm-linux-androideabi/bin:$TOOLCHAIN_DIR/bin:$PATH

# Build iconv for lib boost locale
ENV ICONV_VERSION 1.15
ENV ICONV_HASH  ccf536620a45458d26ba83887a983b96827001e92a13847b45e4925cc8913178
RUN curl -s -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_VERSION}.tar.gz \
    && echo "${ICONV_HASH}  libiconv-${ICONV_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf libiconv-${ICONV_VERSION}.tar.gz \
    && rm -f libiconv-${ICONV_VERSION}.tar.gz \
    && cd libiconv-${ICONV_VERSION} \
    && CC=arm-linux-androideabi-clang CXX=arm-linux-androideabi-clang++ ./configure --build=x86_64-linux-gnu --host=arm-eabi --prefix=${WORKDIR}/libiconv --disable-rpath \
    && make -j${NPROC} && make install

## Build BOOST
RUN cd boost_${BOOST_VERSION} \
    && ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale --build-dir=android32 --stagedir=android32 toolset=clang threading=multi threadapi=pthread target-os=android -sICONV_PATH=${WORKDIR}/libiconv  stage -j${NPROC}

#Note : we build openssl because the default lacks DSA1

# download, configure and make Zlib
ENV ZLIB_VERSION 1.2.11
ENV ZLIB_HASH c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
RUN curl -s -O https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz \
    && echo "${ZLIB_HASH}  zlib-${ZLIB_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf zlib-${ZLIB_VERSION}.tar.gz \
    && rm zlib-${ZLIB_VERSION}.tar.gz \
    && mv zlib-${ZLIB_VERSION} zlib \
    && cd zlib && CC=clang CXX=clang++ ./configure --static \
    && make -j${NPROC}

# open ssl
ARG OPENSSL_VERSION=1.0.2p
ARG OPENSSL_HASH=50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00
RUN curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf openssl-${OPENSSL_VERSION}.tar.gz \
    && rm openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && sed -i -e "s/mandroid/target\ armv7\-none\-linux\-androideabi/" Configure \
    && CC=clang CXX=clang++ \
           ./Configure android-armv7 \
           no-asm \
           no-shared --static \
           --with-zlib-include=${WORKDIR}/zlib/include --with-zlib-lib=${WORKDIR}/zlib/lib \
    && make -j${NPROC} \
    && cd .. && mv openssl-${OPENSSL_VERSION}  openssl

# ZMQ
ARG ZMQ_VERSION=v4.2.5
ARG ZMQ_HASH=d062edd8c142384792955796329baf1e5a3377cd
RUN git clone https://github.com/zeromq/libzmq.git -b ${ZMQ_VERSION} \
    && cd libzmq \
    && test `git rev-parse HEAD` = ${ZMQ_HASH} || exit 1 \
    && ./autogen.sh \
    && CC=clang CXX=clang++ ./configure --prefix=${PWD}/prebuilt --host=arm-linux-androideabi --enable-static --disable-shared \
    && make -j${NPROC} \
    && make install

# zmq.hpp
ARG CPPZMQ_VERSION=v4.2.3
ARG CPPZMQ_HASH=6aa3ab686e916cb0e62df7fa7d12e0b13ae9fae6
RUN git clone https://github.com/zeromq/cppzmq.git -b ${CPPZMQ_VERSION} \
    && cd cppzmq \
    && test `git rev-parse HEAD` = ${CPPZMQ_HASH} || exit 1

ADD . /src
RUN cd /src \
    && BOOST_ROOT=${WORKDIR}/boost_${BOOST_VERSION} BOOST_LIBRARYDIR=${WORKDIR}/boost_${BOOST_VERSION}/android32/lib/ \
         OPENSSL_ROOT_DIR=${WORKDIR}/openssl/ \
         CMAKE_INCLUDE_PATH="${WORKDIR}/cppzmq:${WORKDIR}/libzmq/prebuilt/include" \
         CMAKE_LIBRARY_PATH=${WORKDIR}/libzmq/prebuilt/lib \
         ANDROID_STANDALONE_TOOLCHAIN_PATH=${TOOLCHAIN_DIR} \
         CXXFLAGS="-I ${WORKDIR}/libzmq/prebuilt/include/" \
     PATH=${HOST_PATH} make release-static-android -j${NPROC}
