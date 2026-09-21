---
name: kicad-hardware-review
description: Review KiCad schematic, PCB, BOM, libraries, and generated manufacturing artifacts for correctness and readiness. Use for design reviews, ERC/DRC interpretation, layout risks, library provenance, and release review.
---

# KiCad Hardware Review

This is an independent design-read-only skill normally executed by the
`kicad_reviewer` custom agent. It may write generated evidence under
`work/analysis/` and review reports under `work/reviews/`.

## Workflow

1. Read project requirements, component records, and relevant decisions before judging the design.
2. Locate the actual KiCad project and generated evidence. State clearly when expected inputs do not exist.
3. Run `kicad-cli` ERC, DRC, and exports when execution is permitted. Treat these as deterministic gates.
4. Use the project-local `kicad-happy` analyzers for higher-level inspection;
   do not treat them as a replacement for ERC, DRC, calculations, or datasheet
   checks.
5. Use `datasheet` and manufacturer documentation to verify component claims
   and imported libraries.
6. Report findings first, ordered by severity, with file and location
   references. Include missing tests and residual risks. Write a durable report
   under `work/reviews/` when requested.

Analyzer output is evidence, not ground truth. Do not call a claim verified
without manufacturer evidence, and distinguish confirmed defects from
heuristic risks. Do not approve unvalidated CAD assets or modify KiCad, BOM,
library, or fabrication source files during review. Generated analyzer output
belongs under `work/analysis/`; review reports belong under `work/reviews/`.
Fixes belong to a separate implementation task.
