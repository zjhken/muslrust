FROM ubuntu:xenial
MAINTAINER Eirik Albrigtsen <sszynrae@gmail.com>

RUN apt-get update && apt-get install -y \
  cmake \
  curl \
  file \
  git \
  g++ \
  python \
  make \
  nano \
  ca-certificates \
  xz-utils \
  musl-tools \
  pkg-config \
  apt-file \
  xutils-dev \
  --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

# Install rust
ARG NIGHTLY_SNAPSHOT=""
RUN if test "${NIGHTLY_SNAPSHOT}"; then DATEARG="--date=${NIGHTLY_SNAPSHOT}"; fi &&\
  curl https://static.rust-lang.org/rustup.sh | sh -s -- \
  --with-target=x86_64-unknown-linux-musl \
  --yes \
  --disable-sudo \
  ${DATEARG} \
  --channel=nightly && \
  mkdir /.cargo && \
  echo "[build]\ntarget = \"x86_64-unknown-linux-musl\"" > /.cargo/config

# Compile C libraries with musl-gcc
ENV SSL_VER=1.0.2l \
    CURL_VER=7.56.0 \
    ZLIB_VER=1.2.11 \
    PQ_VER=9.6.5 \
    CC=musl-gcc \
    PREFIX=/usr/local \
    PATH=/usr/local/bin:$PATH \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# Build zlib (used in openssl and pq)
RUN curl -sSL http://zlib.net/zlib-$ZLIB_VER.tar.gz | tar xz && \
    cd zlib-$ZLIB_VER && \
    CC="musl-gcc -fPIC" ./configure --static --prefix=$PREFIX && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf zlib-$ZLIB_VER

# Build openssl (used in curl and pq)
RUN curl -sL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    env CC="musl-gcc -fPIC" ./Configure no-shared --prefix=$PREFIX --openssldir=$PREFIX/ssl linux-x86_64 -fPIC && \
    env C_INCLUDE_PATH=$PREFIX/musl/include make depend 2> /dev/null && make -j$(nproc) && make install && \
    cd .. && rm -rf openssl-$SSL_VER

# Build curl
RUN curl https://curl.haxx.se/download/curl-$CURL_VER.tar.gz | tar xz && \
    cd curl-$CURL_VER && \
    ./configure --enable-shared=no --enable-static=ssl --enable-optimize --prefix=$PREFIX \
      --with-ca-path=/etc/ssl/certs/ --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --without-ca-fallback && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf curl-$CURL_VER

# Build libpq
RUN curl -sSL https://ftp.postgresql.org/pub/source/v$PQ_VER/postgresql-$PQ_VER.tar.gz | tar xz && \
    cd postgresql-$PQ_VER && \
    CC="musl-gcc -fPIE -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" ./configure \
    --without-readline --with-openssl --with-zlib \
    --prefix=$PREFIX --host=x86_64-unknown-linux-musl && \
    cd src/interfaces/libpq && \
    make -j$(nproc) all-static-lib && make install-lib-static && \
    cd ../../../.. && rm -rf postgresql-$PQ_VER

# Some extra evars for pq-sys
ENV PQ_LIB_STATIC=1 \
    PQ_LIB_DIR=$PREFIX/lib \
    PKG_CONFIG_ALL_STATIC=1

# SSL cert directories get overridden by --prefix and --openssldir
# and they do not match the typical host configurations.
# The SSL_CERT_* vars fix this, but only when inside this container
# musl-compiled binary must point SSL at the correct certs (muslrust/issues/5) elsewhere
# OPENSSL_ vars are backwards compat with older rust-openssl and are not needed with new versions of it
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_DIR=/etc/ssl/certs \
    OPENSSL_LIB_DIR=$PREFIX/lib \
    OPENSSL_INCLUDE_DIR=$PREFIX/include \
    OPENSSL_DIR=$PREFIX \
    OPENSSL_STATIC=1
