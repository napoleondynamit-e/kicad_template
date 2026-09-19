SHELL := /usr/bin/env bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DATASHEET ?= datasheet
SNAPEDA_DIR ?= $(ROOT_DIR)/lib/snapeda

.PHONY: bootstrap doctor status snapeda_login snapeda_download erc drc

bootstrap:
	@./bootstrap.sh

doctor:
	@./bootstrap.sh --check

status:
	@cat "$(ROOT_DIR)/PROJECT_STATUS.md"

snapeda_login:
	@$(DATASHEET) snapeda login

snapeda_download:
	@test -n "$(PART)" || { echo "PART is required" >&2; exit 2; }
	@mkdir -p "$(SNAPEDA_DIR)"
	@$(DATASHEET) snapeda download "$(PART)" --format "$(if $(FORMAT),$(FORMAT),kicad)" --out "$(SNAPEDA_DIR)/$(PART)-$(if $(FORMAT),$(FORMAT),kicad).zip"

erc:
	@test -n "$(SCH)" || { echo "SCH is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/work/erc"
	@kicad-cli sch erc --exit-code-violations --output "$(ROOT_DIR)/work/erc/erc.rpt" "$(SCH)"

drc:
	@test -n "$(PCB)" || { echo "PCB is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/work/drc"
	@kicad-cli pcb drc --exit-code-violations --output "$(ROOT_DIR)/work/drc/drc.rpt" "$(PCB)"
