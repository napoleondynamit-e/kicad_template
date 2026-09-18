---
name: hardware-component-search
description: Find, compare, and recommend real electronic components for this PCB project. Use for component selection, alternatives, supplier or lifecycle checks, datasheet comparison, and CAD-asset availability. Do not use for validating an already downloaded symbol or footprint; use hardware-part-validation instead.
---

# Hardware Component Search

## Workflow

1. Read `AGENTS.md`, relevant requirements under `docs/requirements/`, and `workflows/component-search.md`.
2. Extract electrical, mechanical, thermal, assembly, lifecycle, cost, and availability constraints. Mark unknown constraints explicitly.
3. Search by exact MPN and function. Prefer manufacturer datasheets and product pages for technical facts; use distributor data for stock, lifecycle, and packaging.
4. Use `.tools/bin/datasheet` for local datasheet, supplier, and SnapEDA/SnapMagic queries. Treat CAD availability as a convenience signal, never as proof of correctness.
5. Compare three to five realistic candidates when the market permits. Separate verified facts from calculations and assumptions.
6. Recommend one exact MPN, or explain which missing requirement prevents a defensible choice.

## Output

Answer in chat by default. Write a report under `docs/reviews/part-search/`
only when the user requests a durable artifact.

Include extracted requirements, a compact candidate table, official datasheet
links, package and lifecycle notes, risks, required validation, and one exact
recommended MPN.

Do not edit the BOM, KiCad sources, or CAD libraries unless explicitly asked.
