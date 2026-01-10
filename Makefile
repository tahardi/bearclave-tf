# https://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := pre-pr
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: pre-pr
pre-pr: fmt lint security-scan docs

.PHONY: docs
docs:
	@terraform-docs markdown table --output-file README.md ./modules/...

.PHONY: fmt
fmt:
	@terraform fmt -recursive

.PHONY: fmt-check
fmt-check:
	@terraform fmt -recursive -check

.PHONY: lint
lint:
	@tflint --recursive

.PHONY: lint-fix
lint-fix:
	@tflint --recursive --fix

.PHONY: security-scan
security-scan:
	@tfsec .
