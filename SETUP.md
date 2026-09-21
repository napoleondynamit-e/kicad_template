# KiCad Agent Project Setup

This guide creates and configures a PCB project from the KiCad agent template.
The resulting `README.md` is intentionally reserved for information unique to
that project: its product, users, scope, constraints, and success criteria.

## Prerequisites

Install these before running the bootstrap script:

- Git;
- Bash on Linux or macOS;
- Rust and Cargo 1.85 or newer.

Install these for project work after bootstrap:

- KiCad with `kicad-cli` available in `PATH`;
- Python 3.11 or newer for `kicad-happy` analyzers;
- at least one AI agent: OpenAI Codex or Cursor;
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
cd my-board
git init
```

Git initialization is an explicit project-owner step; the bootstrap script
does not perform it.

The script does exactly three things: populates its directory from the
template, installs `datasheet-cli` when `datasheet` is absent from `PATH`, and
installs project-local `kicad-happy` with its skill links. It does not install
KiCad, initialize Git, configure remotes, or configure other automation tools.
For safety, template population only runs when `bootstrap.sh` is the directory's
sole file. After all operations complete successfully, the downloaded
`bootstrap.sh` removes itself. It remains in place if an operation fails.

Template population is intentionally one-time. Later `bootstrap.sh` runs never
merge or copy newer template files into an existing project, so local project
changes remain fully independent. Create a new project to receive newer
template structure or defaults.

To repair a missing tool installation later, download and run the script again:

```bash
curl -fsSL --output bootstrap.sh \
  https://raw.githubusercontent.com/napoleondynamit-e/kicad_template/master/bootstrap.sh
bash bootstrap.sh
```

For an existing project, the template copy is skipped. Existing installations
of `datasheet-cli` and `kicad-happy` are kept. The allowed `kicad`, `emc`, and
`spice` skill links are created and obsolete supplier links are removed. The
downloaded script then removes itself.

## Define The Project Before Design Work

After bootstrap, complete [README.md](README.md) before starting requirements,
architecture, component selection, or CAD work. It is the first source of
project context read by agents and should give them enough information to
understand the product without relying on setup documentation.

At minimum, replace the project name and every relevant `TBD`, covering:

- the product purpose and intended users;
- primary use cases, in-scope behavior, and explicit exclusions;
- power, loads, interfaces, and operating environment;
- mechanical, safety, compliance, manufacturing, sourcing, and cost limits;
- the firmware/software boundary, known assumptions, and open questions;
- measurable success criteria.

Unknown values should remain explicit `TBD`s. Do not invent them. Put detailed
requirements and design records in clearly named files wherever they fit the
project; no fixed `docs/` hierarchy is required.

An agent can help turn an initial product idea into this context:

```bash
codex exec --sandbox workspace-write \
  "Complete README.md from my product description; keep unknowns as TBD"
```

## Work With An Agent

Run Codex from the project root. These commands expect the project directory to
already be a Git repository; bootstrap deliberately does not initialize it.
Codex automatically receives `AGENTS.md`, project skills, and project-scoped
custom agents:

```bash
codex
codex exec --sandbox workspace-write \
  "Review the current schematic"
codex exec --sandbox workspace-write \
  "Implement the approved power input in the schematic"
```

The primary agent delegates component search, part validation, and KiCad review
to the cheaper project agents defined under `.codex/agents/`. `AGENTS.md` and
the selected skill define the operating boundaries. See [COMMAND.md](COMMAND.md)
for task and direct-tool examples.

Deterministic checks remain available without an agent:

```bash
make erc SCH=kicad/project.kicad_sch
make drc PCB=kicad/project.kicad_pcb
```

## Tool Layout

Bootstrap keeps the `kikcad-happy` checkout inside the project:

```text
.tools/
`-- kicad-happy/
```

`kikcad-happy` comes from
`https://github.com/napoleondynamit-e/kikcad-happy`. Only its `kicad`, `emc`,
and `spice` review skills are linked into `.agents/skills/`. Supplier, BOM, and
datasheet workflows from `kicad-happy` are deliberately excluded so sourcing
always goes through `datasheet-cli`, which comes from
`https://github.com/napoleondynamit-e/datasheet-cli` and is installed into the
Cargo user bin directory when `datasheet` is not already available in `PATH`.

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
| `README.md` | Unique product context, scope, constraints, and success criteria |
| `SETUP.md` | Reusable template installation and tooling instructions |
| `kicad/` | KiCad project, schematic, PCB, and project-local tables |
| `lib/` | Imported symbols, footprints, 3D models, and CAD assets |
| `bom/` | Current grouped supply selections and generated BOM artifacts |
| `docs/` | Optional project notes; organize and name them to suit the project |
| `fab/` | Manufacturing release outputs and manifests |
| `stackup/` | Stackup and impedance constraints |
| `work/` | Generated reports and intermediate analysis output |
| `.agents/skills/` | Shared Agent Skills plus generated kicad-happy links |
| `.codex/` | Codex project configuration and custom subagents |
| `.cursor/` | Cursor-specific project rules |

## Typical Commands

```bash
make snapeda_login
make snapeda_download PART=INA240A2DR FORMAT=kicad
make erc SCH=kicad/project.kicad_sch
make drc PCB=kicad/project.kicad_pcb
make release SCH=kicad/project.kicad_sch PCB=kicad/project.kicad_pcb
```

Run an agent from the repository root so it receives `AGENTS.md`, discovers the
project skills, and can resolve all relative paths.

## Credentials

Copy `.env.example` to `.env` and populate only the services you use. Never
commit `.env`, API keys, login cookies, or signed download URLs. The bootstrap
script does not read or upload credentials.

`.env` is not loaded automatically by `codex exec`. For a Mouser task, load it
and pass the variable explicitly:

```bash
source .env
MOUSER_API_KEY="$MOUSER_API_KEY" codex exec --sandbox workspace-write \
  "Find the optimal component for these requirements using Mouser: ..."
```
