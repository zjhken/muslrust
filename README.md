# muslrust
Debian based Docker environment for building static binaries compiled with rust and linked against musl instead of glibc.

The container comes with `openssl` and `curl` compiled against `musl-gcc` so that we can statically link against these system libraries as well.

## Usage
Pull and run from a rust project root:

```sh
docker pull clux/muslrust
docker run \
  -v $PWD:/volume \
  -w /volume \
  -t clux/muslrust \
  cargo build --target=x86_64-unknown-linux-musl --release
```

You should have a static executable in the target folder:

```sh
ldd target/x86_64-unknown-linux-musl/release/EXECUTABLE
        not a dynamic executable
```


## C Libraries
The following system libraries are compiled against `musl-gcc`:

- [x] curl ([curl crate](https://github.com/carllerche/curl-rust))
- [x] openssl ([openssl crate]](https://github.com/sfackler/rust-openssl))
- [ ] zlib ([zlib-sys crate](https://github.com/alexcrichton/libz-sys))

Turns out you don't generally need zlib as `flate2` bundles `miniz.c` as the default implementation, so have skipped this for now. I suspect the high use count of `zlib-sys` is due to flate2 having it as an optional dependency.

## Developing
Clone, tweak, build, and run tests:

```sh
git clone git@github.com:clux/muslrust.git && cd muslrust
docker build -t clux/muslrust .
make test
```

The tests verify that you can use `curl`, `openssl`, `flate2`, and `rand` in simplistic ways.
