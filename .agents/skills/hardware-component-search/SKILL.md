---
name: hardware-component-search
description: Find, compare, and recommend real electronic components for this PCB project. Use for component selection, alternatives, supplier or lifecycle checks, datasheet comparison, and CAD-asset availability. Do not use for validating an already downloaded symbol or footprint; use hardware-part-validation instead.
---

# Hardware Component Search

This is a read-only research skill normally executed by the
`component_researcher` custom agent. It produces a recommendation and evidence;
it does not add the component to KiCad.

## Workflow

1. Read `AGENTS.md`, `README.md`, and locate relevant requirements, existing
   part choices, and constraints by filename, content, directory, and Git
   history.
2. Extract electrical, mechanical, thermal, assembly, lifecycle, cost, and availability constraints. Mark unknown constraints explicitly.
3. Search by exact MPN and function. Prefer manufacturer datasheets and product pages for technical facts; use distributor data for stock, lifecycle, and packaging.
4. Use `datasheet` from `PATH` for Mouser, DigiKey, JLCPCB/LCSC, datasheet, and
   SnapEDA/SnapMagic queries. Treat CAD availability as a convenience signal,
   never as proof of correctness.
5. Compare three to five realistic candidates when the market permits. Separate verified facts from calculations and assumptions.
6. Recommend one exact MPN, or explain which missing requirement prevents a defensible choice.

## Output

Answer in chat by default. Write a report only when the user requests a durable
artifact, using a clear filename and an appropriate existing directory.

Include extracted requirements, a compact candidate table, official datasheet
links, package and lifecycle notes, risks, required validation, and one exact
recommended MPN.

Do not edit the BOM, KiCad sources, or CAD libraries. Return the selected MPN
to the primary agent; a separate explicit implementation task performs imports
or KiCad changes.
