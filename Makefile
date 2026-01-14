# https://clarkgrubb.com/makefile-style-guide
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := pre-pr
.DELETE_ON_ERROR:
.SUFFIXES:

.PHONY: pre-pr
pre-pr: fmt lint sec-check-quiet docs test-unit

.PHONY: docs
docs: docs-aws-nitro docs-gcp-sev-snp docs-gcp-tdx

.PHONY: docs-aws-nitro
docs-aws-nitro:
	@terraform-docs markdown table \
		./modules/aws-nitro-enclaves \
		--output-file README.md

.PHONY: docs-gcp-sev-snp
docs-gcp-sev-snp:
	@terraform-docs markdown table \
		./modules/gcp-sev-snp \
		--output-file README.md

.PHONY: docs-gcp-tdx
docs-gcp-tdx:
	@terraform-docs markdown table \
		./modules/gcp-tdx \
		--output-file README.md

.PHONY: fmt
fmt:
	@terraform fmt -recursive

.PHONY: fmt-check
fmt-check:
	@terraform fmt -recursive -check

lint_config=$(CURDIR)/.tflint.hcl
.PHONY: lint-init
lint-init:
	@tflint --config $(lint_config) --init

.PHONY: lint
lint: lint-init
	@tflint --config $(lint_config) --recursive

.PHONY: sec-check
sec-check:
	@trivy config \
		--config .trivy.yml \
		.

.PHONY: sec-check-quiet
sec-check-quiet:
	@trivy config \
		--config .trivy.yml \
		. > /dev/null 2>&1

.PHONY: test-unit
test-unit: \
	test-unit-aws-nitro \
	test-unit-gcp-sev-snp \
	test-unit-gcp-tdx

.PHONY: test-unit-aws-nitro
test-unit-aws-nitro:
	@cd ./modules/aws-nitro-enclaves && terraform test

.PHONY: test-unit-gcp-sev-snp
test-unit-gcp-sev-snp:
	@cd ./modules/gcp-sev-snp && terraform test

.PHONY: test-unit-gcp-tdx
test-unit-gcp-tdx:
	@cd ./modules/gcp-tdx && terraform test
