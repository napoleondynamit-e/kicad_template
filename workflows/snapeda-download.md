# SnapEDA Component Download

This project uses the project-local `datasheet-cli` installed by
`bootstrap.sh`.

## Login

```bash
.tools/bin/datasheet snapeda login
```

or use the deterministic alias:

```bash
make snapeda_login
```

The login session is cached outside version control. Do not place credentials
in command history, tracked files, or agent prompts.

## Download

```bash
.tools/bin/datasheet snapeda download INA240A2DR --format kicad --out lib/snapeda/INA240A2DR-kicad.zip
```

or:

```bash
make snapeda_download PART=INA240A2DR FORMAT=kicad
```

Downloaded CAD is untrusted until symbol pins, footprint pads, package geometry,
and orientation are validated against the manufacturer datasheet.
