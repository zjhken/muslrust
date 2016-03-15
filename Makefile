SHELL := /bin/bash

.PHONY: build run

build:
	docker build -t clux/muslrust .

run:
	docker run -it clux/muslrust /bin/bash

