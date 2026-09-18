# KiCad Agent Project Template

A standalone starting point for PCB development with KiCad, an AI coding agent,
project-local engineering skills, deterministic ERC/DRC commands, component
research, and CAD-library validation.

## Prerequisites

Install these before running the bootstrap script:

- Git;
- Bash on Linux or macOS;
- KiCad with `kicad-cli` available in `PATH`;
- Python 3.10 or newer;
- Rust and Cargo 1.85 or newer;
- at least one AI agent: OpenAI Codex or Cursor.

Optional tools:

- `ngspice` for SPICE-backed checks;
- distributor API credentials for supplier-specific workflows;
- a Gemini or OpenAI API key for LLM-backed datasheet extraction.

## Start A Project

Create an empty project directory, download only `bootstrap.sh`, and run it:

```bash
mkdir my-board
curl -fsSL --output my-board/bootstrap.sh \
  https://raw.githubusercontent.com/napoleondynamit-e/kicad_template/master/bootstrap.sh
bash my-board/bootstrap.sh
```

The script populates its directory with the template structure, installs the
tools, and creates the skill links. It does not initialize a Git repository or
configure remotes. For safety, automatic population only runs when
`bootstrap.sh` is the directory's sole file.

If the project was already created from this template, run:

```bash
./bootstrap.sh
```

The script is idempotent. It updates the project-local `kikcad-happy` checkout,
installs `datasheet-cli` into the user's Cargo bin directory when `datasheet`
is not already available in `PATH`, and exposes the `kikcad-happy` skills to
Codex and Cursor through `.agents/skills/`.

Verify the installation without network access or modifications:

```bash
./bootstrap.sh --check
make doctor
```

Then replace this README introduction with the product description, fill in
`docs/requirements/`, and create the KiCad project under `kicad/`.

## Tool Layout

Bootstrap keeps the `kikcad-happy` checkout and generated environment inside
the project:

```text
.tools/
|-- env
`-- kicad-happy/
```

`kikcad-happy` comes from
`https://github.com/napoleondynamit-e/kikcad-happy`. Its skills are linked into
`.agents/skills/`, the shared project-level location understood by Codex and
Cursor. `datasheet-cli` comes from
`https://github.com/napoleondynamit-e/datasheet-cli` and is installed into the
first suitable user-level bin directory already in `PATH` (normally
`~/.cargo/bin` or `~/.local/bin`). Set `DATASHEET_CLI_INSTALL_ROOT` to override
the selected Cargo install root.

Nothing requires system-wide or root installation. `.tools/` and generated
skill links are ignored by Git. Override a repository or branch when testing a
fork:

```bash
KICAD_HAPPY_REF=my-branch ./bootstrap.sh
DATASHEET_CLI_REPO=https://github.com/example/datasheet-cli.git ./bootstrap.sh
```

## Project Structure

| Path | Purpose |
| --- | --- |
| `kicad/` | KiCad project, schematic, PCB, and project-local tables |
| `lib/` | Imported symbols, footprints, 3D models, and CAD assets |
| `bom/` | Component records and generated BOM artifacts |
| `docs/requirements/` | System, hardware, and firmware-visible requirements |
| `docs/architecture/` | Power trees, interfaces, control/data-flow diagrams |
| `docs/decisions/` | Durable architecture decision records |
| `docs/datasheets/` | Authoritative manufacturer PDFs for selected hardware |
| `docs/reviews/` | Requested search and validation reports |
| `docs/validation/` | Bring-up and verification plans/results |
| `fab/` | Manufacturing release outputs and manifests |
| `stackup/` | Stackup and impedance constraints |
| `work/` | Generated reports and intermediate analysis output |
| `workflows/` | Human- and agent-readable project workflows |
| `.agents/skills/` | Shared Agent Skills plus generated kicad-happy links |
| `.codex/` | Codex project configuration and custom subagents |
| `.cursor/` | Cursor-specific project rules |

## Typical Commands

```bash
make doctor
make snapeda_login
make snapeda_download PART=INA240A2DR FORMAT=kicad
make erc SCH=kicad/project.kicad_sch
make drc PCB=kicad/project.kicad_pcb
```

Run an agent from the repository root so it receives `AGENTS.md`, discovers the
project skills, and can resolve all relative paths.

## Credentials

Copy `.env.example` to `.env` and populate only the services you use. Never
commit `.env`, API keys, login cookies, or signed download URLs. The bootstrap
script does not read or upload credentials.
