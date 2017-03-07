# muslrust
[![build status](https://secure.travis-ci.org/clux/muslrust.svg)](http://travis-ci.org/clux/muslrust)
[![docker pulls](https://img.shields.io/docker/pulls/clux/muslrust.svg)](
https://hub.docker.com/r/clux/muslrust/)
[![docker image info](https://images.microbadger.com/badges/image/clux/muslrust.svg)](http://microbadger.com/images/clux/muslrust)
[![docker tag](https://images.microbadger.com/badges/version/clux/muslrust.svg)](https://hub.docker.com/r/clux/muslrust/tags/)

A plain docker environment for building static binaries compiled with rust and linked against musl instead of glibc.

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

From there on, you can include it in a blank docker image (because everything you need is included in the binary) and perhaps end up with a [5MB docker blog image](https://github.com/clux/blog).

## Docker builds
Latest is always the last built nightly pushed by travis. To pin against specific builds, see the [available tags](https://hub.docker.com/r/clux/muslrust/tags/) on the docker hub.

## C Libraries
The following system libraries are compiled against `musl-gcc`:

- [x] curl ([curl crate](https://github.com/carllerche/curl-rust))
- [x] openssl ([openssl crate](https://github.com/sfackler/rust-openssl))

We try to keep these up to date.

zlib is not included as the common `flate2` crate bundles `miniz.c` as the default implementation, and this just works.

## Developing
Clone, tweak, build, and run tests:

```sh
git clone git@github.com:clux/muslrust.git && cd muslrust
make build
make test
```

The tests verify that you can use `hyper`, `curl`, `openssl`, `flate2`, and `rand` in simplistic ways.

## SSL Verification
You need to point openssl at the location of your certificates explicitly to have https requests not return certificate errors.

```sh
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export SSL_CERT_DIR=/etc/ssl/certs
```

You can also hardcode this in your binary, or, more sensibly set it in your running docker image.

## Caching Cargo Locally
Repeat builds locally are always from scratch (thus slow) without a cached cargo directory. You can set up a docker volume by just adding `-v cargo-cache:/root/.cargo` to the docker run command.

You'll have an extra volume that you can inspect with `docker volume inspect cargo-cache`.

Suggested developer usage is to add the following function to your `~/.bashrc`:

```sh
musl-build() {
  docker run \
    -v cargo-cache:/root/.cargo \
    -v "$PWD:/volume" -w /volume \
    --rm -it clux/muslrust cargo build --release
}
```

Then use in your project:

```sh
$ cd myproject
$ musl-build
    Finished release [optimized] target(s) in 0.0 secs
```

Second time around this will be quick, and you can even mix it with native `cargo build` calls without screwing with your cache.
