FROM alpine:3.6

RUN apk add --no-cache libpq ca-certificates

# Debug
RUN apk add --no-cache bash strace
RUN ln -sf /lib/ld-musl-x86_64.so.1 /lib/ld64.so.1
ENV RUST_BACKTRACE=1

# For testing purposes we only used debug builds here
ADD target/x86_64-unknown-linux-musl/debug/dieselcrate .

CMD dieselcrate
