# muslrust
Debian based Docker environment for building static binaries compiled with rust and linked against musl instead of glibc.

This should work out of the box for rust binaries without C dependencies (libc is okay).

## Usage
Clone and build:

```sh
git clone git@github.com:clux/muslrust.git && cd muslrust
docker build -t clux/muslrust .
```

Then, in a rust project directory:

```sh
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

## Future
Compile popular C libraries against musl-gcc so that you can use crates with C ffi dependencies.

- [ ] libcurl
- [ ] openssl
- [ ] zlib
