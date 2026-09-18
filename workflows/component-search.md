# Component Search Workflow

Component search is an agent workflow, not a Make target.

Codex example:

```text
$hardware-component-search Compare two current-sense amplifiers against the project requirements.
```

Cursor users can select `hardware-component-search` from the `/` skill menu.
For larger isolated searches, ask the parent agent to delegate to
`component_researcher` when that custom agent is available.

Search results stay in chat by default. Write a durable report under
`docs/reviews/part-search/` only when requested.

## Completion Gate

A useful search result contains:

- extracted requirements and unresolved constraints;
- three to five realistic candidates when available;
- one exact recommended MPN or a clear blocker;
- official datasheet links;
- package, lifecycle, supplier, and CAD-asset notes;
- risks and required validation.

SnapEDA/SnapMagic is an import source and availability signal, not the source of
truth. Validate every imported symbol and footprint against manufacturer data.
