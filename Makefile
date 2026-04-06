MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: build
build:
	./scripts/build-container.sh

.PHONY: test
test:
	./scripts/run-container-structure-test.sh
