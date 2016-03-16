SHELL := /bin/bash

.PHONY: build run test push

build:
	docker build -t clux/muslrust .
push:
	docker push clux/muslrust
run:
	docker run -v $$PWD/test:/volume  -w /volume -it clux/muslrust /bin/bash

test-plain:
	docker run \
		-v $$PWD/test/plaincrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --verbose
	cd test/plaincrate && ./target/x86_64-unknown-linux-musl/debug/plaincrate
	ldd test/plaincrate/target/x86_64-unknown-linux-musl/debug/plaincrate > /dev/null || echo "static"

test-curl:
	docker run \
		-v $$PWD/test/curlcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --verbose
	cd test/curlcrate && ./target/x86_64-unknown-linux-musl/debug/curlcrate
	ldd test/curlcrate/target/x86_64-unknown-linux-musl/debug/curlcrate > /dev/null || echo "static"

test-ssl:
	docker run \
		-v $$PWD/test/sslcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --verbose
	cd test/sslcrate && ./target/x86_64-unknown-linux-musl/debug/sslcrate
	ldd test/sslcrate/target/x86_64-unknown-linux-musl/debug/sslcrate > /dev/null || echo "static"

test-zlib:
	docker run \
		-v $$PWD/test/zlibcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --verbose
	cd test/zlibcrate && ./target/x86_64-unknown-linux-musl/debug/zlibcrate
	ldd test/zlibcrate/target/x86_64-unknown-linux-musl/debug/zlibcrate > /dev/null || echo "static"

test: test-plain test-ssl test-curl test-zlib
