SHELL := /bin/bash

.PHONY: build run test push

build:
	docker build -t clux/muslrust .
run:
	docker run -v $$PWD/test:/volume  -w /volume -it clux/muslrust /bin/bash

test-plain:
	./test.sh plain
test-curl:
	./test.sh curl
test-ssl:
	./test.sh ssl
test-zlib:
	./test.sh zlib

test: test-plain test-ssl test-curl test-zlib
.PHONY: test-plain test-curl test-ssl test-zlib

