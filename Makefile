SHELL := /bin/bash

.PHONY: build run test push

build: .build
.build:
	rm -f .build
	docker build -t clux/muslrust .
	touch .build
run:
	docker run -v $$PWD/test:/volume  -w /volume -it clux/muslrust /bin/bash

test-plain: build
	./test.sh plain
test-curl: build
	./test.sh curl
test-ssl: build
	./test.sh ssl
test-zlib: build
	./test.sh zlib

test: test-plain test-ssl test-curl test-zlib
.PHONY: test-plain test-curl test-ssl test-zlib

