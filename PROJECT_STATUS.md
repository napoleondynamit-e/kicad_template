# Project Status

This file is the shared workflow state for the project owner and agents. Read it
before starting work and update it whenever a stage starts, becomes blocked, or
meets its completion gate.

Allowed statuses are `not_started`, `in_progress`, `blocked`, `complete`, and
`not_applicable`. A stage is `complete` only when its completion gate is met and
the evidence column points to the resulting files or reports.

Stages normally proceed in numeric order. Starting a later stage before the
previous gate is complete requires an explicit reason under **Decisions Needed**
or **Active Blockers**. Keep **Current State**, the stage board, and the update
log consistent with each other.

## Current State

- Current stage: `0 — Project Definition`
- Status: `in_progress`
- Next action: Complete the `README.md` project-context template with the actual
  product description, users, scope, constraints, assumptions, open questions,
  and success criteria.
- Blockers: Product definition has not been supplied yet.
- Last updated: `TBD`

## Stage Board

| ID | Stage | Status | Completion gate | Evidence |
| --- | --- | --- | --- | --- |
| 0 | Project Definition | `in_progress` | README identifies the product, scope, users, primary constraints, and success criteria. | `README.md` — project-specific fields are still `TBD` |
| 1 | Requirements | `not_started` | Requirements have stable IDs, rationale or sources, verification methods, and no unrecorded critical unknowns. | `docs/requirements/` |
| 2 | Hardware Architecture | `not_started` | Power tree, interfaces, protection, sensing, control boundaries, budgets, assumptions, and blocking decisions are documented. | `docs/architecture/`, `docs/decisions/` |
| 3 | Component Selection | `not_started` | Critical functions have exact MPNs checked against requirements, manufacturer datasheets, lifecycle, sourcing, and package constraints. | `bom/`, `docs/datasheets/`, `docs/reviews/part-search/` |
| 4 | CAD Library Validation | `not_started` | Every imported symbol and footprint has verified pins, pads, dimensions, orientation, provenance, and 3D alignment where applicable. | `lib/`, `docs/reviews/part-validation/` |
| 5 | Schematic | `not_started` | Schematic implements the approved architecture; power, interfaces, values, annotations, and connectivity are reviewed; ERC has no unresolved violations. | `kicad/*.kicad_sch`, `work/erc/`, `docs/reviews/` |
| 6 | PCB Layout | `not_started` | Placement and routing meet electrical, mechanical, return-path, thermal, EMC, and manufacturing constraints; DRC has no unresolved violations. | `kicad/*.kicad_pcb`, `work/drc/`, `docs/reviews/` |
| 7 | Manufacturing Release | `not_started` | BOM, fabrication and placement outputs, assembly constraints, sourcing, variants, and release review are complete for the selected manufacturer. | `bom/`, `fab/` |
| 8 | Bring-Up And Validation | `not_started` | A safe bring-up plan exists and every applicable requirement has a pass/fail verification record; untested items remain explicit blockers. | `docs/validation/` |

## Active Blockers

- Product-specific context in `README.md` has not been supplied yet.

## Decisions Needed

- Product purpose and intended user.
- Input power, outputs, interfaces, environment, size, cost, and manufacturing
  constraints that affect the design.

## Update Log

Add one row for meaningful stage transitions. Do not log routine edits.

| Date | Stage | Change | Evidence or reason |
| --- | --- | --- | --- |
