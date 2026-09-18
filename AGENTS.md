# Project Agent Context

This repository contains a KiCad PCB project. Read the product description and
requirements before proposing circuits, selecting components, or changing CAD
files.

## Default Read Order

1. `README.md`
2. Relevant files under `docs/requirements/`
3. Relevant architecture under `docs/architecture/`
4. Existing decisions under `docs/decisions/`

## Project Context Map

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

## Tool Use

- Use `datasheet` from `PATH` for datasheets, supplier data, SnapEDA/SnapMagic,
  and structured extraction.
- Use `kicad-cli` for deterministic ERC, DRC, and exports.
- Use the project-local `kicad-happy` skills as an additional review layer; they
  do not replace ERC, DRC, calculations, or manufacturer documentation.
- Use MCP only for external systems that the project-local tools and normal web
  access cannot handle reliably.

## Operating Rules

- Treat manufacturer datasheets as authoritative for electrical and mechanical
  component facts.
- Treat imported CAD assets as untrusted until symbol pins, pad mapping,
  package dimensions, and orientation are validated.
- Keep open-ended research in chat unless a durable report is requested.
- Write approved decisions under `docs/decisions/` and requested review reports
  under `docs/reviews/`.
- Do not edit KiCad, BOM, or library files unless the task explicitly requires
  it.
- Do not commit secrets, cookies, API keys, generated `.tools/`, or signed URLs.

## Task Workflows

### Architecture And Design

1. Read `README.md` and the relevant requirements.
2. Read existing architecture and decisions.
3. Inspect component records before proposing parts already evaluated.
4. Write a durable artifact only when requested or when implementing an
   explicitly approved decision.

### Component Selection

1. Extract requirements before searching.
2. Use manufacturer documentation for technical facts.
3. Use distributors for availability and lifecycle evidence.
4. Treat downloaded CAD as untrusted until separately validated.

A useful component search result contains extracted requirements, unresolved
constraints, three to five realistic candidates when available, one exact
recommended MPN or a clear blocker, official datasheet links, package and
lifecycle information, supplier and CAD-asset notes, risks, and required
validation. Keep results in chat unless a durable report under
`docs/reviews/part-search/` is requested.

### KiCad Review

1. Read requirements and component validation records.
2. Run deterministic ERC or DRC as appropriate.
3. Run the relevant `kicad-happy` review skill.
4. Report findings by severity and preserve requested evidence under `work/`
   or `docs/reviews/`.

### SnapEDA And SnapMagic Imports

Use `make snapeda_login` to authenticate and download a KiCad asset with:

```bash
make snapeda_download PART=INA240A2DR FORMAT=kicad
```

The login session is cached outside version control. Never place credentials
in command history, tracked files, or agent prompts. SnapEDA and SnapMagic are
import sources, not sources of truth; validate imported symbols, footprints,
package geometry, and orientation against manufacturer documentation.

## Skills And Delegation

Project skills are discovered from `.agents/skills/**/SKILL.md`. Codex users can
invoke a skill as `$skill-name`; Cursor exposes the same skills through its `/`
menu.

Codex-specific custom agents live in `.codex/agents/*.toml`. Delegate only
bounded, independent, or context-heavy research and review work. Handle small
edits and deterministic CLI commands in the parent agent. Avoid parallel agents
that would edit the same files.
