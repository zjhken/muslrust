#!/bin/bash
set -ex

docker_build() {
  local -r crate="$1"crate
  docker run \
    --rm \
    -v "$PWD/test/${crate}:/volume" \
    -v cargo-cache:/root/.cargo \
    -w /volume \
    -e RUST_BACKTRACE=1 \
    -it clux/muslrust \
    cargo build -vv
  cd "test/${crate}"
  ./target/x86_64-unknown-linux-musl/debug/"${crate}"
  [[ "$(ldd "target/x86_64-unknown-linux-musl/debug/${crate}")" =~ "not a dynamic" ]] && \
    echo "${crate} is a static executable"
}

docker_build "$1"
