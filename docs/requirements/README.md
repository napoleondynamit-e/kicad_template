# Requirements

Keep requirements compact, testable, and grouped by engineering domain under
`systems/`. Add software-specific requirements under `software/` only when the
project contains firmware-visible behavior.

Each requirement should have:

- a stable identifier;
- one normative statement;
- rationale or source when it is not obvious;
- verification method;
- explicit `TBD` values instead of invented limits.

Separate prototype or validation constraints from production requirements when
the selected hardware differs between development stages.
