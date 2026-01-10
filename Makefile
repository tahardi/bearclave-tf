# https://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := pre-pr
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: pre-pr
pre-pr: fmt lint sec-check docs

.PHONY: docs
docs: docs-aws-nitro

.PHONY: docs-aws-nitro
docs-aws-nitro:
	@terraform-docs markdown table \
		./modules/aws-nitro-enclaves \
		--output-file README.md

.PHONY: fmt
fmt:
	@terraform fmt -recursive

.PHONY: fmt-check
fmt-check:
	@terraform fmt -recursive -check

.PHONY: lint-init
lint-init:
	@tflint --config .tflint.hcl --init

.PHONY: lint
lint: lint-init
	@tflint --config .tflint.hcl

.PHONY: lint-fix
lint-fix: lint-init
	@tflint --config .tflint.hcl --fix

.PHONY: sec-check
sec-check:
	@trivy config \
		--config .trivy.yml \
		--format table \
		.

.PHONY: sec-check-json
sec-check-json:
	@trivy config \
		--config .trivy.yml \
		--format json \
		.
