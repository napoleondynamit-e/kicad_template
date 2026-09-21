---
name: hardware-component-search
description: Find, compare, and recommend real electronic components using datasheet-cli. Use for component selection, supplier searches, pricing, stock, lifecycle, datasheet comparison, and CAD-asset availability. Do not use for validating an imported symbol or footprint.
---

# Hardware Component Search

This skill is normally executed by `component_researcher`. Supplier access is
owned exclusively by `datasheet-cli`; do not invoke supplier or BOM workflows
from `kicad-happy`.

## Workflow

1. Read `AGENTS.md`, `README.md`, and locate relevant constraints and existing
   part choices by filename, content, directory, and Git history.
2. Extract electrical, mechanical, thermal, assembly, lifecycle, quantity,
   cost, and availability constraints. Keep unknowns explicit.
3. Call `datasheet` directly. For known operations, run the command without a
   preliminary help lookup:

   ```bash
   datasheet mouser search "<query>" --json
   datasheet jlcpcb search "<query>" --in-stock --json
   datasheet snapeda search "<exact MPN>"
   ```

   Consult `datasheet ... --help` only after the documented command is rejected
   by the installed version.
4. Use manufacturer datasheets for technical facts and supplier results for
   price, stock, lifecycle, MOQ, and product-page URLs.
5. Compare realistic candidates, then recommend one exact MPN or state the
   missing constraint that prevents a defensible choice.

## Selected Result

When the user asks for the optimal, best, or recommended position and a
defensible selection is found, update `bom/supply_chain.md`. This file is the
current selection state, not an append-only research log.

Group parts by functional block. Keep a main component and its support parts in
the same section; for example, an MCU section may contain the MCU, oscillator,
decoupling, reset, and programming parts. Use this compact structure:

```markdown
## <functional block>

| Component | Unit price | Qty | Supplier page |
| --- | ---: | ---: | --- |
| <name and exact MPN> | <currency and unit price> | <pieces priced> | <supplier product-page URL> |
```

The Component cell must start with the design role, followed by the exact MPN,
for example `MCU — STM32G431CBT6`. Before writing, read the complete file.
Preserve unrelated groups and rows, but replace the row for the same design
role within its group. Never retain duplicate choices or search history. For a
multi-part selection, write one row per selected physical part in the relevant
groups, then rewrite the file in place.

Use the requested quantity or a quantity already defined by the project. If no
quantity exists, use a one-piece quote and make that visible in the row. Quote
the Markdown cell when needed and keep each entry to one line. Record only
selected positions, not rejected candidates. Do not update the file when
selection is blocked or only exploratory research was requested.

Keep the chat response compact: state the recommendation, decisive trade-off,
and important risk. Do not write another report unless requested.

Apart from maintaining `bom/supply_chain.md`, do not modify BOM data, KiCad
sources, or CAD libraries. Import and validation are separate tasks.
