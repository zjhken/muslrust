# muslrust
[![build status](https://secure.travis-ci.org/clux/muslrust.svg)](http://travis-ci.org/clux/muslrust)
[![docker pulls](https://img.shields.io/docker/pulls/clux/muslrust.svg)](
https://hub.docker.com/r/clux/muslrust/)
[![docker image info](https://images.microbadger.com/badges/image/clux/muslrust.svg)](http://microbadger.com/images/clux/muslrust)
[![docker tag](https://images.microbadger.com/badges/version/clux/muslrust.svg)](https://hub.docker.com/r/clux/muslrust/tags/)

Debian based Docker environment for building static binaries compiled with rust and linked against musl instead of glibc.

This is only useful if you require external C dependencies, because otherwise you could do `rustup target add x86_64-unknown-linux-musl`.

This container comes with `openssl` and `curl` compiled against `musl-gcc` so that we can statically link against these system libraries as well.

## Usage
Pull and run from a rust project root:

```sh
docker pull clux/muslrust
docker run -v $PWD:/volume -w /volume -t clux/muslrust cargo build
```

You should have a static executable in the target folder:

```sh
ldd target/x86_64-unknown-linux-musl/debug/EXECUTABLE
        not a dynamic executable
```

## Docker builds
Latest is always the last built nightly pushed by travis. To pin against specific builds, see the [available tags](https://hub.docker.com/r/clux/muslrust/tags/) on the docker hub.

## C Libraries
The following system libraries are compiled against `musl-gcc`:

- [x] curl ([curl crate](https://github.com/carllerche/curl-rust))
- [x] openssl ([openssl crate](https://github.com/sfackler/rust-openssl))
- [ ] ~~zlib ([zlib-sys crate](https://github.com/alexcrichton/libz-sys))~~

You shouldn't need zlib as `flate2` bundles `miniz.c` as the default implementation.

## Developing
Clone, tweak, build, and run tests:

```sh
git clone git@github.com:clux/muslrust.git && cd muslrust
make build
make test
```

The tests verify that you can use `curl`, `openssl`, `flate2`, and `rand` in simplistic ways.
