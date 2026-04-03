# Kiln

A warm clarity color theme for terminals, editors, and apps. Designed in OKLCH color space with warm neutrals, broad accent coverage, and WCAG AA contrast.

## Variants

| Variant | Type | Description |
|---------|------|-------------|
| **Ember** | Dark | Deep, low-lightness backgrounds with vivid accents at L=0.65 |
| **Forge** | Dark | Slightly warmer and lighter than Ember, accents at L=0.68 |
| **Dawn** | Light | Warm parchment backgrounds, accents at L=0.43 |
| **Glow** | Light | Near-white editor with vivid accents at L=0.52, inverted depth (editor brightest) |

27 colors per variant: 9 base/surface, 4 text, 14 accents. Peach is the signature accent.

## Quick Start

```bash
# Setup
uv venv && uv pip install -e ".[dev]"

# Generate all targets (all variants)
python -m kiln.generate

# Apply a variant to your system
scripts/apply-theme.sh ember                     # all targets
scripts/apply-theme.sh glow ghostty fish tide    # specific targets
scripts/apply-theme.sh --list                    # show available variants
scripts/apply-theme.sh --dry-run forge           # preview without changes
```

## Targets

| App | Output | Notes |
|-----|--------|-------|
| Ghostty | `dist/ghostty/{variant}/ghostty.conf` | Inlined into config by apply script |
| Fish | `dist/fish/{variant}/fish.conf` | Sets universal variables |
| Tide | `dist/tide/{variant}/tide.conf` | Sets universal variables |
| Neovim | `dist/nvim/{variant}/kiln.lua` | Installs to `~/.config/nvim/colors/` |
| tmux | `dist/tmux/{variant}/tmux.conf` | Source from your tmux.conf |
| delta | `dist/delta/{variant}/delta.gitconfig` | Include in `~/.gitconfig` |
| VS Code | `dist/vscode/{variant}/` | Installs as extension |
| Obsidian | `dist/obsidian/` | Combined dark+light CSS theme |
| Web | `dist/web/{variant}/` | CSS variables + JSON tokens |

## Project Structure

```
palette.yaml           # Source of truth — OKLCH + hex for all 27 colors x 4 variants
src/kiln/generate.py   # CLI: palette.yaml + Jinja2 templates -> dist/
src/kiln/validate.py   # WCAG contrast validation
templates/             # One template per target app
dist/                  # Generated output (gitignored)
scripts/apply-theme.sh # Install variants to target apps
preview/               # Browser-based palette + code preview
```

## Design

- **OKLCH-first**: All accents at uniform perceptual lightness per variant
- **WCAG AA**: 17/18 color pairs pass (comment is intentionally low-contrast)
- **Warm neutrals**: Base hue at 70 OKLCH (red-orange bias)
- **27 colors per variant**: 9 base/surface + 4 text + 14 accents

## Adding a New Target

1. Create template(s) in `templates/{target}/` or `templates/{target}.ext.j2`
2. Add target name to `TARGETS` list in `generate.py`
3. Run `python -m kiln.generate --target {target}`
