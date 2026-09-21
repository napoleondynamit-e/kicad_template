# Commands

## Start Codex

```bash
codex

codex exec --sandbox read-only --skip-git-repo-check \
  "Select a CAN transceiver for these requirements: ..."

codex exec --sandbox workspace-write --skip-git-repo-check \
  "Add the approved CAN transceiver and its support circuit to the schematic"
```

For an explicitly controlled handoff:

```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Delegate the component search to component_researcher: ..."
```

| Task | Agent | Model |
| --- | --- | --- |
| Component and supplier search | `component_researcher` | `gpt-5.6-luna`, medium |
| Symbol and footprint validation | `part_validator` | `gpt-5.6-terra`, high |
| Schematic, PCB, BOM, or release review | `kicad_reviewer` | `gpt-5.6-terra`, high |
| Bounded architecture investigation | `hardware_architect` | `gpt-5.6-sol`, high |
| Integration and KiCad implementation | Primary agent | Active session model |

## Recommended Board Workflow

### 1. Formalize the product brief and testable requirements

```bash
codex exec --sandbox workspace-write "Formalize this product brief in the relevant project files: ..."
```
### 2. Select the main components
```bash
codex exec --sandbox read-only "Select exact MPNs for the main functional blocks from the requirements"
```

### 3. Validate downloaded CAD, then add approved parts to KiCad

```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Validate the downloaded symbols and footprints for the selected MPNs"
```

```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Add the validated parts to the project libraries and schematic"
```

### 4. Implement each functional block and its support circuitry in turn
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Implement the power-input block and its complete support circuitry"
```

### 5. Check the implemented block against exact manufacturer datasheets
```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Review the power-input block against the selected component datasheets"
```

### 6. Finish the schematic and run ERC
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Complete the remaining schematic and run ERC"
```

### 7. Trace requirements to the completed schematic
```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Verify every applicable project requirement against the schematic"
```

### 8. Generate the BOM and estimate cost
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Generate the BOM and estimate board cost for this quantity: ..."
```

### 9. Define or refine the stackup
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Define the stackup and impedance assumptions for this manufacturer: ..."
```

### 10. Define PCB constraints and configure KiCad rules
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Derive PCB constraints from the requirements and stackup, then configure the rules"
```

### 11. Implement the PCB, run DRC, then review it independently
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Place and route the PCB according to the approved rules, then run DRC"
```
```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Review the PCB against its requirements without modifying it"
```

### 12. Generate and review manufacturing outputs
```bash
codex exec --sandbox workspace-write --skip-git-repo-check \
  "Generate fabrication, drill, placement, and BOM outputs"
```
```bash
codex exec --sandbox read-only --skip-git-repo-check \
  "Review the manufacturing release without modifying it"
```

`datasheet` searches suppliers and downloads candidate CAD assets. Downloading
an asset does not validate it or place it in the design.

## Component Data

```bash
datasheet mouser search "TPS62160" --json
datasheet mouser stock "TPS62160DQCR" --json
datasheet mouser download "TPS62160DQCR" --dir datasheets

datasheet jlcpcb search "100nF 0402 X7R 16V" \
  --basic-only --in-stock --json
datasheet jlcpcb part C1525 --json
datasheet jlcpcb stock C1525 --json

datasheet snapeda search "TPS62160DQCR"
make snapeda_login
make snapeda_download PART=TPS62160DQCR FORMAT=kicad
```

Supplier results and downloaded CAD are untrusted until checked against the
exact manufacturer datasheet.

## Deterministic KiCad Commands

These commands do not need an agent. Their output paths are fixed by the
Makefile:

```bash
make erc SCH=kicad/project.kicad_sch
make drc PCB=kicad/project.kicad_pcb
make bom SCH=kicad/project.kicad_sch
make gerbers PCB=kicad/project.kicad_pcb
make drill PCB=kicad/project.kicad_pcb
make pos PCB=kicad/project.kicad_pcb

# All PCB fabrication outputs
make fab PCB=kicad/project.kicad_pcb

# ERC, DRC, BOM, and all fabrication outputs
make release SCH=kicad/project.kicad_sch PCB=kicad/project.kicad_pcb
```

Outputs:

| Command | Output |
| --- | --- |
| `make erc` | `work/erc/erc.rpt` |
| `make drc` | `work/drc/drc.rpt` |
| `make bom` | `bom/bom.csv` |
| `make gerbers` | `fab/gerbers/` |
| `make drill` | `fab/drill/`, including `drill-report.txt` |
| `make pos` | `fab/placement/positions.csv` |
| `make fab` | All three `fab/` outputs above |
| `make release` | ERC, DRC, BOM, and all `fab/` outputs |

## Direct Review Tools

These commands are normally run by `kicad_reviewer`:

```bash
python3 .agents/skills/kicad/scripts/analyze_schematic.py \
  kicad/project.kicad_sch --analysis-dir work/analysis

python3 .agents/skills/kicad/scripts/analyze_pcb.py \
  kicad/project.kicad_pcb --full --analysis-dir work/analysis

python3 .agents/skills/emc/scripts/analyze_emc.py \
  --analysis-dir work/analysis --market eu

python3 .agents/skills/kicad/scripts/analyze_gerbers.py \
  fab/gerbers --analysis-dir work/analysis
```

The analyzers supplement deterministic checks and manufacturer evidence; they
do not replace them.
