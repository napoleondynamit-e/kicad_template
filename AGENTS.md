# Project Agent Context

This repository contains a KiCad PCB project. Read the product description and
requirements before proposing circuits, selecting components, or changing CAD
files.

## Default Read Order

1. `README.md`
2. `workflows/agent-context-map.md`
3. Relevant files under `docs/requirements/`
4. Relevant workflow under `workflows/`
5. Existing decisions under `docs/decisions/`

## Tool Use

- Use `.tools/bin/datasheet` for datasheets, supplier data, SnapEDA/SnapMagic,
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

## Skills And Delegation

Project skills are discovered from `.agents/skills/**/SKILL.md`. Codex users can
invoke a skill as `$skill-name`; Cursor exposes the same skills through its `/`
menu.

Codex-specific custom agents live in `.codex/agents/*.toml`. Delegate only
bounded, independent, or context-heavy research and review work. Handle small
edits and deterministic CLI commands in the parent agent. Avoid parallel agents
that would edit the same files.
