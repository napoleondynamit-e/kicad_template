SHELL := /usr/bin/env bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DATASHEET ?= datasheet
SNAPEDA_DIR ?= $(ROOT_DIR)/lib/snapeda
BOM_FIELDS ?= Reference,Value,Footprint,QUANTITY,Manufacturer,MPN,LCSC,Mouser,DNP
BOM_GROUP_BY ?= Value,Footprint,Manufacturer,MPN

.PHONY: snapeda_login snapeda_download erc drc bom gerbers drill pos fab release

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

bom:
	@test -n "$(SCH)" || { echo "SCH is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/bom"
	@kicad-cli sch export bom \
		--output "$(ROOT_DIR)/bom/bom.csv" \
		--fields "$(BOM_FIELDS)" \
		--group-by "$(BOM_GROUP_BY)" \
		--exclude-dnp \
		"$(SCH)"

gerbers:
	@test -n "$(PCB)" || { echo "PCB is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/fab/gerbers"
	@kicad-cli pcb export gerbers \
		--output "$(ROOT_DIR)/fab/gerbers" \
		--board-plot-params \
		--check-zones \
		"$(PCB)"

drill:
	@test -n "$(PCB)" || { echo "PCB is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/fab/drill"
	@kicad-cli pcb export drill \
		--output "$(ROOT_DIR)/fab/drill" \
		--excellon-separate-th \
		--generate-report \
		--report-path "$(ROOT_DIR)/fab/drill/drill-report.txt" \
		"$(PCB)"

pos:
	@test -n "$(PCB)" || { echo "PCB is required" >&2; exit 2; }
	@mkdir -p "$(ROOT_DIR)/fab/placement"
	@kicad-cli pcb export pos \
		--output "$(ROOT_DIR)/fab/placement/positions.csv" \
		--format csv \
		--units mm \
		--side both \
		--smd-only \
		--exclude-dnp \
		"$(PCB)"

fab: gerbers drill pos

release: erc drc bom fab
