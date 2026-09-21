# Project Agent Context

This repository contains a KiCad PCB project. Read `README.md` first, then find
task-relevant files by filename, directory name, content, and Git history. You can find requirements and docs in `docs/`.

## Task Routing

| Task class | Executor | Model | Tools and search area | Write access |
| --- | --- | --- | --- | --- |
| Requirements, planning, integration, user discussion | Primary agent | Active session model | `README.md`, relevant Markdown, repository search, Git history | Text files requested by the user |
| Architecture investigation | `hardware_architect` when the work is bounded and context-heavy | `gpt-5.6-sol`, high | Product requirements, existing design files, calculations, manufacturer evidence | Only an explicitly requested architecture artifact |
| Component and supplier search | `component_researcher` | `gpt-5.6-luna`, medium | `datasheet`, manufacturer data, supplier stock/pricing, existing BOM and component files | None; return exact MPN and evidence to the primary agent |
| Imported symbol and footprint validation | `part_validator` | `gpt-5.6-terra`, high | Manufacturer datasheet, local libraries, KiCad symbol/footprint data | None; report `PASS`, `WARN`, or `FAIL` |
| Schematic, PCB, BOM, library, or release review | `kicad_reviewer` | `gpt-5.6-terra`, high | `kicad-cli`, `kicad-happy`, `datasheet`, KiCad and relevant project files | None; report findings only |
| Schematic, library, or PCB implementation | Primary agent | Active session model | Approved requirements, validated parts, and available KiCad tooling | Only when the user explicitly requests the CAD change |
| ERC, DRC, BOM, and fabrication exports | Primary agent | Active session model | `kicad-cli` or existing Make targets | Generated outputs only when requested |

The primary agent owns scope, design decisions, user communication, and final
integration. Delegate component selection or supplier research to
`component_researcher`, imported-part validation to `part_validator`, and
schematic or PCB file analysis to `kicad_reviewer`. Keep trivial local lookups,
small edits, and deterministic commands in the primary agent. Do not run
parallel agents that could edit the same files.

## Tool Boundaries

- Use `datasheet` from `PATH` for datasheets, supplier data, structured
  extraction, and SnapEDA/SnapMagic downloads. A downloaded CAD asset is not
  validated and is not yet part of the schematic.
- Use `kicad-cli` for deterministic ERC, DRC, BOM, and manufacturing exports.
- Use project-local `kicad-happy` skills as an additional read-only review
  layer. They do not replace ERC, DRC, calculations, or manufacturer evidence.

## Operating Rules

- Treat manufacturer datasheets as authoritative for electrical and mechanical
  facts. Treat supplier data as evidence for availability and price.
- Treat imported CAD assets as untrusted until pins, pads, package dimensions,
  and orientation have been checked against manufacturer documentation.
- Treat review, inspection, analysis, validation, ERC, and DRC requests as
  read-only. Never fix findings inside the same review task.
- Do not edit KiCad, BOM, library, or fabrication files unless the user
  explicitly requests that implementation or export.
- Keep open-ended research in chat. Create a durable report only when requested,
  placing it in a clearly named existing directory or a path agreed in the task.
- Preserve unknowns as `TBD`; do not invent requirements or limits.
- Do not commit secrets, cookies, API keys, generated `.tools/`, or signed URLs.

## Recommended Design Flow

This is guidance, not a gate system. Steps may overlap or repeat as evidence
changes.

1. Formalize the product brief and testable requirements.
2. Select the main components.
3. Download and validate CAD assets, then add approved parts to the project and
   schematic.
4. Implement the support circuitry for each main functional block in turn.
5. Check each block against the exact manufacturer datasheets.
6. Complete the schematic and resolve ERC findings.
7. Verify every applicable project requirement against the schematic.
8. Generate and review the BOM and estimate cost at the intended quantity.
9. Establish a preliminary stackup early and refine it before layout.
10. Refine PCB constraints and configure KiCad rules.
11. Place and route the PCB, run DRC, and verify it against PCB requirements.
12. Generate and review fabrication, drill, placement, and BOM outputs.

## Skills And Agents

Project skills live under `.agents/skills/**/SKILL.md`; invoke one as
`$skill-name` when useful. Codex custom-agent definitions live under
`.codex/agents/*.toml`. Their configured model, reasoning level, sandbox, and
instructions apply when the primary agent delegates to them.
