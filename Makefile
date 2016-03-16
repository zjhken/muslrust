SHELL := /bin/bash

.PHONY: build run test

build:
	docker build -t clux/muslrust .

run:
	docker run -v $$PWD/test:/volume  -w /volume -it clux/muslrust /bin/bash

test-plain:
	docker run \
		-v $$PWD/test/plaincrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --target=x86_64-unknown-linux-musl --release
	./test/plaincrate/target/x86_64-unknown-linux-musl/release/plaincrate

test-curl:
	docker run \
		-v $$PWD/test/curlcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --target=x86_64-unknown-linux-musl --release --verbose

test-ssl:
	docker run \
		-v $$PWD/test/sslcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --target=x86_64-unknown-linux-musl --release --verbose

test: test-plain test-ssl test-curl
