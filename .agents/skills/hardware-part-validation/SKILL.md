---
name: hardware-part-validation
description: Validate a local electronic component symbol, footprint, pin-to-pad mapping, package geometry, and optional 3D model against authoritative manufacturer documentation. Use after importing CAD assets and before trusting them in KiCad.
---

# Hardware Part Validation

## Workflow

1. Identify the exact MPN, package suffix, and intended assembly variant.
2. Read the manufacturer datasheet and package drawing. Do not treat library-provider metadata as authoritative.
3. Inspect local files under `lib/` and the component record under `bom/` when present.
4. Use `.tools/bin/datasheet snapeda part`, `symbol`, and `footprint` commands as supporting evidence.
5. Check symbol pin numbers and names, footprint pad mapping, pitch, body and exposed-pad dimensions, courtyard, pin-1 orientation, and 3D alignment when available.
6. Classify the result as `PASS`, `WARN`, or `FAIL`, with evidence for every discrepancy.

## Output

Answer in chat by default. When a durable result is requested, write
`docs/reviews/part-validation/<MPN>.md`.

Never mark an imported asset trusted solely because it opens successfully. Do
not silently repair an asset; report the issue and edit it only when asked.
