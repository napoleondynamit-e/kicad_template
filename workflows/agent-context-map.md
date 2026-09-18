# Agent Context Map

This file tells an agent where project truth should live. Update the status and
paths as the design develops.

## Context Sources

| Area | Location | Purpose |
| --- | --- | --- |
| Project overview | `README.md` | Product purpose, scope, and entry points |
| Agent rules | `AGENTS.md` | Always-applicable operating constraints |
| Requirements | `docs/requirements/` | Electrical, mechanical, safety, and firmware-visible constraints |
| Architecture | `docs/architecture/` | Power, interfaces, control, and protection topology |
| Decisions | `docs/decisions/` | Approved trade-offs and rationale |
| Component records | `bom/` | MPNs, sourcing, lifecycle, and validation state |
| CAD libraries | `lib/` | Symbols, footprints, models, and provenance |
| KiCad design | `kicad/` | Schematic and PCB source of truth |
| Validation | `docs/validation/` | Bring-up plans, tests, and measured results |
| Manufacturing | `fab/` | Release outputs and manifests |

## Read Order By Task

For architecture or design work:

1. Read `README.md` and the relevant requirements.
2. Read existing architecture and decisions.
3. Inspect component records before proposing parts already evaluated.
4. Write a durable artifact only when requested or when implementing an
   explicitly approved decision.

For component selection:

1. Extract requirements before searching.
2. Use manufacturer documentation for technical facts.
3. Use distributors for availability and lifecycle evidence.
4. Treat downloaded CAD as untrusted until separately validated.

For KiCad review:

1. Read requirements and component validation records.
2. Run deterministic ERC/DRC.
3. Run the relevant `kicad-happy` review skill.
4. Report findings by severity and preserve evidence under `work/` or
   `docs/reviews/` as appropriate.
