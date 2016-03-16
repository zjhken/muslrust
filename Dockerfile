FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  cmake \
  curl \
  file \
  git \
  g++ \
  make \
  python \
  nano \
  ca-certificates \
  xz-utils \
  curl \
  musl-tools \
  pkg-config \
  apt-file \
  xutils-dev \
  sudo

RUN curl -sf https://static.rust-lang.org/rustup.sh > rustup.sh && chmod +x rustup.sh && \
    ./rustup.sh --with-target=x86_64-unknown-linux-musl --channel=nightly

# Compile a bunch of stuff and make install it to /dist
ENV SSL_VER=1.0.2g \
    CURL_VER=7.47.1 \
    CC=musl-gcc \
    PREFIX=/dist \
    PATH=/dist/bin:$PATH \
    PKG_CONFIG_PATH=/dist/lib/pkgconfig

# OpenSSL
# TODO: need zlib before openssl if using that
RUN curl -sL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    ./Configure no-shared --prefix=$PREFIX --openssldir=$PREFIX/ssl no-zlib linux-x86_64 && \
    make depend && make -j4 && make install && \
    cd .. && rm -rf openssl-$SSL_VER

RUN curl https://curl.haxx.se/download/curl-$CURL_VER.tar.gz | tar xz && \
    cd curl-$CURL_VER/ && \
    ./configure --enable-shared=no --enable-static=ssl --prefix=$PREFIX && \
    make -j4 && make install && \
    cd .. && rm -rf curl-$CURL_VER

# At this point pkg-config should pick up the correct curl with correct deps..
# Unfortunately, this is not the case, have to set this at the moment (rust-openssl/issues/351)
ENV OPENSSL_LIB_DIR=$PREFIX/lib \
    OPENSSL_INCLUDE_DIR=$PREFIX/include \
    OPENSSL_STATIC=1
