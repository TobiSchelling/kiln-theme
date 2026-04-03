# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Kiln is a warm-clarity color theme designed in OKLCH color space. A single palette definition generates configs for 9 target platforms via Jinja2 templates. The repo contains three theme families: **Kiln** (2 variants: dark, light), **Hearth** (4 variants: ember, forge, dawn, glow), and **Catppuccin** blueprints (4 variants: mocha, macchiato, frappé, latte).

## Commands

```bash
# Setup
uv venv && uv pip install -e ".[dev]"

# Generate all targets (all variants)
python -m kiln.generate

# Generate specific target/variant
python -m kiln.generate --target ghostty --variant ember
python -m kiln.generate --dry-run          # preview without writing

# Apply a variant to your system
scripts/apply-theme.sh ember                     # all targets
scripts/apply-theme.sh glow ghostty fish tide    # specific targets
scripts/apply-theme.sh --list                    # show available variants
scripts/apply-theme.sh --dry-run forge           # preview without changes

# Validate WCAG contrast ratios
python -m kiln.validate

# Tests and lint
pytest
ruff check src/
```

## Architecture

**Data flow:** `palette.yaml` → `generate.py` (build_context + Jinja2) → `dist/{target}/{variant}/`

### Source of Truth

`palette.yaml` defines all 27 colors per variant with hex + OKLCH values, plus semantic mappings (ANSI, syntax, UI). Every color change starts here. Contains 10 variants across 3 families: Kiln (dark/light), Hearth (ember/forge/dawn/glow), Catppuccin (mocha/macchiato/frappé/latte).

### Generator (`src/kiln/generate.py`)

- `load_palette()` → parses YAML
- `build_context(palette, variant)` → flattens colors into template-friendly dicts with `hex`, `hex_stripped`, `oklch`, `role`, `category` fields
- Resolves `ansi_mapping`, `syntax_mapping`, `ui_mapping` from color names to actual values
- Renders per-variant targets to `dist/{target}/{variant}/` and combined targets (obsidian) to `dist/{target}/`

### Templates (`templates/`)

Jinja2 templates receive a context with: `colors` (all 27 by name), `base_colors`/`text_colors`/`accent_colors` (pre-filtered), `ansi`/`syntax`/`ui` (resolved mappings), plus metadata (`variant`, `display_name`, `version`).

- **Single-file targets:** `ghostty.conf.j2`, `fish.conf.j2`, `tide.conf.j2`, `tmux.conf.j2`, `delta.gitconfig.j2`
- **Multi-file targets:** `nvim/` (4 files), `vscode/` (2 files), `web/` (2 files)
- **Combined targets** (`COMBINED_TARGETS`): `obsidian/` renders both variants into one file using `dark.*`/`light.*` access

### Targets

ghostty, fish, tide, nvim, tmux, delta, vscode, obsidian, web

## Design Constraints

- **OKLCH-first:** Accents at uniform perceptual lightness (~0.65 dark, ~0.43 light)
- **WCAG AA (4.5:1):** All text/accent colors except `comment` (intentionally low-contrast at ~3.6:1)
- **Signature accent:** Peach `#E08A50` — used for properties, parameters, inline code
- **Warm neutrals:** Base hue 70° (red-orange bias) carried by backgrounds
- **27 colors per variant:** 9 base/surface + 4 text + 14 accents

## Tools

- **`scripts/apply-theme.sh`** — Installs any variant to ghostty, fish, tide, nvim, tmux, delta, vscode, obsidian. Handles per-target config differences (copying files, setting universal variables, rendering combined CSS).
- **`scripts/fetch-examples.sh`** — Downloads reference theme files from Catppuccin, Dracula, Tokyo Night into `examples/`.
- **`preview/theme-tuner.html`** — Web-based variant browser showing palette, color mappings (syntax/UI/ANSI), per-app usage, and live mockups (LazyVim, Obsidian, Terminal). Loads from `dist/web/{variant}/tokens.json`.
- **`preview/hearth-selector.html`** — Interactive OKLCH-based theme designer with tuning sliders for creating new variants.

## Adding a New Target

1. Create template(s) in `templates/{target}/` or `templates/{target}.ext.j2`
2. Add target name to `TARGETS` list in `generate.py` (and `COMBINED_TARGETS` if it merges both variants)
3. Run `python -m kiln.generate --target {target}` — output lands in `dist/{target}/`
