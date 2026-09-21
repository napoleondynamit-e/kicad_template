---
name: hardware-architecture
description: Create or review PCB-system architecture, including power trees, electrical interfaces, sensing, protection, control boundaries, and durable hardware decisions. Use before detailed schematic work or when requirements must be mapped to functional blocks.
---

# Hardware Architecture

## Workflow

1. Read `AGENTS.md`, `README.md`, and locate relevant requirements and prior
   decisions by filename, content, directory, and Git history.
2. Separate verified requirements from assumptions and provisional choices.
3. Model functional blocks, power rails, interfaces, protection boundaries, and control/data flows before selecting detailed circuits.
4. Use Mermaid flowcharts for power and signal topology, sequence diagrams for startup or fault flows, and tables for interface contracts.
5. Identify failure modes, unresolved requirements, and measurements needed to close them.
6. Record approved durable choices only when requested, using a clear filename
   and a location appropriate to the existing project.

Do not invent exact limits or component values without requirements,
calculations, measurements, or datasheet evidence.
