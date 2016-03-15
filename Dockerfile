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
  sudo

RUN curl -sf https://static.rust-lang.org/rustup.sh > rustup.sh && chmod +x rustup.sh && \
    ./rustup.sh --with-target=x86_64-unknown-linux-musl --channel=nightly
