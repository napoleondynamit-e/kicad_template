# KiCad Agent Project Setup

This guide creates and configures a PCB project from the KiCad agent template.
The resulting `README.md` is intentionally reserved for information unique to
that project: its product, users, scope, constraints, and success criteria.

## Prerequisites

Install these before running the bootstrap script:

- Git;
- Bash on Linux or macOS;
- KiCad with `kicad-cli` available in `PATH`;
- Node.js 18 or newer with npm;
- Python 3.11 or newer with virtual-environment support and access to `pcbnew`;
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

Template population is intentionally one-time. Later `bootstrap.sh` runs never
merge or copy newer template files into an existing project, so local project
changes remain fully independent. Create a new project to receive newer
template structure or defaults.

If the project was already created from this template, run:

```bash
./bootstrap.sh
```

For an existing project, the script only updates the project-local
`kikcad-happy` and KiCad MCP tool checkouts, builds the MCP server and its local
Python environment, installs `datasheet-cli` into the user's Cargo bin directory
when `datasheet` is not already available in `PATH`, and refreshes the
`kikcad-happy` skill links under `.agents/skills/`.

Verify the installation without network access or modifications:

```bash
./bootstrap.sh --check
make doctor
```

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

Unknown values should remain explicit `TBD`s. Do not invent them, and do not
start a later stage while a critical unknown can change its outcome. Detailed,
testable requirements belong under `docs/requirements/`; the README remains the
concise product-level context.

An agent can help turn an initial product idea into this context:

```bash
codex 'Stage 0: help me complete README.md with the product context, scope, users, constraints, assumptions, open questions, and measurable success criteria. Ask only for decisions that cannot be inferred safely, then update PROJECT_STATUS.md.'
```

## Work With An Agent

Run the agent from the project root so it automatically receives `AGENTS.md`.
Those instructions require the agent to read and maintain `PROJECT_STATUS.md`,
so prompts do not need to repeat file-loading instructions:

```bash
cd my-board
codex
```

KiCad MCP is enabled for the project by default and exposes its complete tool
set to Codex and Cursor. Start a new agent session after bootstrap so the client
loads the server configuration. Confirm the connection with `codex mcp list`,
`/mcp` inside Codex, or `cursor-agent mcp list`.

The server's availability is not permission to change the design. Agents must
not write schematics, PCB files, symbols, footprints, library tables, or BOM
data unless the prompt explicitly requests that implementation. Review,
inspection, validation, ERC, and DRC tasks remain read-only; `kicad-happy`
review findings are fixed only in a separate implementation task.

Enter prompts in that interactive session. You can also start a session with
an initial prompt directly:

```bash
codex 'Report the current stage, blockers, and next action.'
```

To let the agent continue whatever stage is currently active:

```bash
codex 'Continue the current stage. Verify its completion gate and update the project status with evidence, blockers, and the next action.'
```

For a non-interactive run that may edit project files, replace `codex` with
`codex exec --sandbox workspace-write`. If the project is not a Git repository,
also add `--skip-git-repo-check`. Cursor Agent users can use the same prompts
with `cursor-agent`, or `cursor-agent --print` for a non-interactive run.

The primary agent selects the appropriate skill or specialist from the stage
and task. Specify a role only when it establishes an important boundary, such
as implementation versus independent read-only review. These commands are
starting prompts, not rigid scripts; review each result before accepting it.

### Stage 0 — Project Definition

```bash
codex 'Stage 0: help me complete README.md with the product context, scope, users, constraints, assumptions, open questions, and measurable success criteria. Ask only for decisions that cannot be inferred safely, then update PROJECT_STATUS.md.'
```

### Stage 1 — Requirements

```bash
codex 'Stage 1: derive testable electrical, mechanical, safety, manufacturing, and firmware-visible requirements. Give them stable IDs, rationale or sources, and verification methods. Record unknown limits as explicit TBDs and update the project status.'
```

### Stage 2 — Hardware Architecture

```bash
codex 'Stage 2: use $hardware-architecture to define the power tree, interfaces, protection, sensing, control boundaries, budgets, assumptions, and unresolved decisions. Record approved trade-offs and update the project status.'
```

### Stage 3 — Component Selection

```bash
codex 'Stage 3: use $hardware-component-search to select exact MPNs against the approved requirements and architecture. Verify technical facts from manufacturer datasheets, record sourcing and lifecycle risks, update the component records, and update the project status.'
```

### Stage 4 — CAD Library Validation

```bash
codex 'Stage 4, validator role: use $hardware-part-validation to independently validate every imported symbol, footprint, pin-to-pad mapping, package dimension, orientation, and 3D model against manufacturer documentation. Do not modify CAD during review. Save the findings and update the project status.'
```

### Stage 5 — Schematic

```bash
codex 'Stage 5, implementation role: create or finish the KiCad schematic from the approved requirements, architecture, and validated parts. Run ERC and address implementation errors. Keep the stage in progress and set the next action to independent review.'
```

The deterministic ERC command is also available directly:

```bash
make erc SCH=kicad/project.kicad_sch
```

Run the independent schematic review in a separate session:

```bash
codex 'Stage 5, reviewer role: spawn kicad_reviewer for an independent read-only schematic review. Wait for its result, do not modify the design, and update the project status only if the completion gate is satisfied.'
```

### Stage 6 — PCB Layout

```bash
codex 'Stage 6, implementation role: create or finish the PCB layout from the reviewed schematic and constraints. Check placement, return paths, power integrity, clearances, manufacturability, thermal behavior, and EMC risks. Run DRC, address implementation errors, and leave the stage pending independent review.'
```

The deterministic DRC command is also available directly:

```bash
make drc PCB=kicad/project.kicad_pcb
```

Run the independent layout review in a separate session:

```bash
codex 'Stage 6, reviewer role: spawn kicad_reviewer for an independent read-only PCB review using the DRC evidence. Wait for its result, do not modify the design, and update the project status only if the completion gate is satisfied.'
```

### Stage 7 — Manufacturing Release

```bash
codex 'Stage 7, release role: use $bom and the fabrication skill for the selected manufacturer. Prepare and verify sourcing, variants, assembly constraints, fabrication outputs, BOM, and placement data under fab/. Keep the stage in progress and set the next action to independent release review.'
```

Run the independent release review in a separate session:

```bash
codex 'Stage 7, reviewer role: spawn kicad_reviewer for an independent read-only review of the BOM, libraries, DRC evidence, and manufacturing artifacts. Do not modify release files. Update the project status only if the release gate is satisfied.'
```

### Stage 8 — Bring-Up And Validation

```bash
codex 'Stage 8: create the bring-up and validation plan from the requirements. Define equipment, safe power-on limits, measurements, pass/fail criteria, and result records. Do not invent measurements; update the project status with the tests that must be performed on hardware.'
```

After performing the physical tests, provide the measurements to the agent:

```bash
codex 'Stage 8: record the supplied bring-up measurements, compare them with the requirement pass/fail criteria, and update the validation records and project status. Keep every missing or failed test explicit.'
```

## Tool Layout

Bootstrap keeps the `kikcad-happy` and KiCad MCP checkouts and generated
environments inside the project:

```text
.tools/
|-- env
|-- kicad-happy/
`-- kicad-mcp/
```

`kikcad-happy` comes from
`https://github.com/napoleondynamit-e/kikcad-happy`. Its skills are linked into
`.agents/skills/`, the shared project-level location understood by Codex and
Cursor. KiCad MCP comes from
`https://github.com/mixelpixx/KiCAD-MCP-Server`, is pinned to a stable release,
and is enabled through `.codex/config.toml` and `.cursor/mcp.json` without a
tool allowlist. `datasheet-cli` comes from
`https://github.com/napoleondynamit-e/datasheet-cli` and is installed into the
first suitable user-level bin directory already in `PATH` (normally
`~/.cargo/bin` or `~/.local/bin`). Set `DATASHEET_CLI_INSTALL_ROOT` to override
the selected Cargo install root.

Nothing requires system-wide or root installation. `.tools/` and generated
skill links are ignored by Git. Override a repository or branch when testing a
fork:

```bash
KICAD_HAPPY_REF=my-branch ./bootstrap.sh
KICAD_MCP_REF=v2.7.0 ./bootstrap.sh
DATASHEET_CLI_REPO=https://github.com/example/datasheet-cli.git ./bootstrap.sh
```

Set `KICAD_MCP_PYTHON` when the default `python3` cannot import `pcbnew`, for
example to the Python interpreter bundled with KiCad.

## Project Structure

| Path | Purpose |
| --- | --- |
| `README.md` | Unique product context, scope, constraints, and success criteria |
| `SETUP.md` | Reusable template installation and tooling instructions |
| `PROJECT_STATUS.md` | Current project stage, completion gates, blockers, and next action |
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
| `.agents/skills/` | Shared Agent Skills plus generated kicad-happy links |
| `.codex/` | Codex project configuration and custom subagents |
| `.cursor/` | Cursor-specific project rules |

## Typical Commands

```bash
make doctor
make status
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
