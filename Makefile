SHELL := /bin/bash

.PHONY: build run test

build:
	docker build -t clux/muslrust .

run:
	docker run -it clux/muslrust /bin/bash

test:
	docker run \
		-v $$PWD/test/curlcrate:/volume \
		-w /volume \
		-t clux/muslrust \
		cargo build --target=x86_64-unknown-linux-musl --release
