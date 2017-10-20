FROM ubuntu:xenial
MAINTAINER Eirik Albrigtsen <sszynrae@gmail.com>
# NB: currently using xenial because newer ubuntus or debians force fPIC
# and ring complains at fPIC when compiling rocket

# Required packages:
# - musl-dev, musl-tools - the musl toolchain
# - curl, g++, make, pkgconf, cmake - for fetching and building third party libs
# - ca-certificates - openssl + curl + peer verification of downloads
# - xutils-dev - for openssl makedepend
# - git - cargo builds in user projects
# - linux-headers-amd64 - needed for building openssl 1.1 (stretch only)
# - file - needed by rustup.sh install
# recently removed:
# cmake (not used), nano, zlib1g-dev
RUN apt-get update && apt-get install -y \
  musl-dev \
  musl-tools \
  file \
  git \
  make \
  g++ \
  curl \
  pkgconf \
  ca-certificates \
  xutils-dev \
  --no-install-recommends

#   && \
#  rm -rf /var/lib/apt/lists/*


# Install rust (old fashioned way to avoid unnecessary rustup.rs shenanigans)
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

# Convenience list of versions and variables for compilation later on
# This helps continuing manually if anything breaks.
ENV SSL_VER=1.0.2l \
    CURL_VER=7.56.0 \
    ZLIB_VER=1.2.11 \
    PQ_VER=9.6.5 \
    CC=musl-gcc \
    PREFIX=/musl \
    PATH=/usr/local/bin:$PATH \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    LD_LIBRARY_PATH=$PREFIX

RUN mkdir /workdir && mkdir $PREFIX
WORKDIR /libworkdir

# Tricks
RUN ln -s /usr/include/x86_64-linux-gnu/asm /usr/include/x86_64-linux-musl/asm && \
    ln -s /usr/include/asm-generic /usr/include/x86_64-linux-musl/asm-generic && \
    ln -s /usr/include/linux /usr/include/x86_64-linux-musl/linux
RUN echo "$PREFIX/lib" >> /etc/ld-musl-x86_64.path



# Build zlib (used in openssl and pq)
RUN curl -sSL http://zlib.net/zlib-$ZLIB_VER.tar.gz | tar xz && \
    cd zlib-$ZLIB_VER && \
    CC="musl-gcc -fPIC -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" ./configure --static --prefix=$PREFIX && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf zlib-$ZLIB_VER

# Build openssl (used in curl and pq)
RUN curl -sSL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    ./Configure no-zlib no-shared -fPIC --prefix=$PREFIX --openssldir=$PREFIX/ssl linux-x86_64 && \
    env C_INCLUDE_PATH=$PREFIX/include make depend 2> /dev/null && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf openssl-$SSL_VER

# Build curl
RUN curl -sSL https://curl.haxx.se/download/curl-$CURL_VER.tar.gz | tar xz && \
    cd curl-$CURL_VER && \
    CC="musl-gcc -fPIC -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" ./configure \
      --enable-shared=no --with-zlib --enable-static=ssl --enable-optimize --prefix=$PREFIX \
      --with-ca-path=/etc/ssl/certs/ --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --without-ca-fallback && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf curl-$CURL_VER

# Build libpq
RUN curl -sSL https://ftp.postgresql.org/pub/source/v$PQ_VER/postgresql-$PQ_VER.tar.gz | tar xz && \
    cd postgresql-$PQ_VER && \
    CC="musl-gcc -fPIE -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" ./configure \
    --without-readline \
    --prefix=$PREFIX --host=x86_64-unknown-linux-musl && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf postgresql-$PQ_VER

# Need dynamic versions of libpq and libssl for diesel_codegen during the build phase
# All the dynamic artifacts from our compiled libpq can be removed though
RUN rm $PREFIX/lib/*.so && rm $PREFIX/lib/*.so.* && rm $PREFIX/lib/postgres* -rf && \
    apt-get install -y libssl-dev libpq-dev

# SSL cert directories get overridden by --prefix and --openssldir
# and they do not match the typical host configurations.
# The SSL_CERT_* vars fix this, but only when inside this container
# musl-compiled binary must point SSL at the correct certs (muslrust/issues/5) elsewhere
ENV PATH=$PREFIX/bin:$PATH \
    PKG_CONFIG_ALLOW_CROSS=true \
    PKG_CONFIG_ALL_STATIC=true \
    PQ_LIB_STATIC_X86_64_UNKNOWN_LINUX_MUSL=true \
    PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig \
    PG_CONFIG_X86_64_UNKNOWN_LINUX_GNU=/usr/bin/pg_config \
    OPENSSL_STATIC=true \
    OPENSSL_DIR=$PREFIX \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_DIR=/etc/ssl/certs \
    LIBZ_SYS_STATIC=1

# Allow ditching the -w /volume flag to docker run
WORKDIR /volume
