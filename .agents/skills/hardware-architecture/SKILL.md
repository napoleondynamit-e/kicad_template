---
name: hardware-architecture
description: Create or review PCB-system architecture, including power trees, electrical interfaces, sensing, protection, control boundaries, and durable hardware decisions. Use before detailed schematic work or when requirements must be mapped to functional blocks.
---

# Hardware Architecture

## Workflow

1. Read `AGENTS.md`, `README.md`, and the relevant requirements under `docs/requirements/`.
2. Separate verified requirements from assumptions and provisional choices.
3. Model functional blocks, power rails, interfaces, protection boundaries, and control/data flows before selecting detailed circuits.
4. Use Mermaid flowcharts for power and signal topology, sequence diagrams for startup or fault flows, and tables for interface contracts.
5. Identify failure modes, unresolved requirements, and measurements needed to close them.
6. Record approved durable choices as ADRs under `docs/decisions/`.

## Expected Artifacts

- `docs/architecture/power-tree.md`
- `docs/architecture/interfaces.md`
- `docs/architecture/control-loop.md` when applicable
- `docs/decisions/ADR-*.md`

Do not invent exact limits or component values without requirements,
calculations, measurements, or datasheet evidence.
