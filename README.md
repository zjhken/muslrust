# muslrust
[![build status](https://secure.travis-ci.org/clux/muslrust.svg)](http://travis-ci.org/clux/muslrust)

Debian based Docker environment for building static binaries compiled with rust and linked against musl instead of glibc.

The container comes with `openssl` and `curl` compiled against `musl-gcc` so that we can statically link against these system libraries as well.

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


## C Libraries
The following system libraries are compiled against `musl-gcc`:

- [x] curl ([curl crate](https://github.com/carllerche/curl-rust))
- [x] openssl ([openssl crate](https://github.com/sfackler/rust-openssl))
- [ ] zlib ([zlib-sys crate](https://github.com/alexcrichton/libz-sys))

Turns out you don't generally need zlib as `flate2` bundles `miniz.c` as the default implementation, so have skipped this for now. The high use count of `zlib-sys` on crates.io may be due to flate2 having it as an optional dependency.

NB: Make sure you are using curl crate version >= 0.2.17 if using curl.

## Developing
Clone, tweak, build, and run tests:

```sh
git clone git@github.com:clux/muslrust.git && cd muslrust
docker build -t clux/muslrust .
make test
```

The tests verify that you can use `curl`, `openssl`, `flate2`, and `rand` in simplistic ways.
