# Kiln

A warm clarity color theme for terminals, editors, and apps. Designed in OKLCH color space with Anthropic-inspired warm neutrals, broad accent coverage, and WCAG AA contrast.

## Palette

27 colors per variant (dark + light): 9 base/surface, 4 text, 14 accents.

Peach (`#E08A50`) is the signature accent — used for properties, parameters, inline code, and UI focus indicators.

## Targets

| App | File | Install |
|-----|------|---------|
| Ghostty | `dist/ghostty/{variant}/ghostty.conf` | Copy to `~/Library/Application Support/com.mitchellh.ghostty/themes/kiln-dark` |
| Fish | `dist/fish/{variant}/fish.conf` | `fish -c "source dist/fish/dark/fish.conf"` |
| Tide | `dist/tide/{variant}/tide.conf` | `fish -c "source dist/tide/dark/tide.conf"` |
| Neovim | `dist/nvim/{variant}/kiln.lua` | Copy to `~/.config/nvim/colors/kiln-dark.lua` |
| tmux | `dist/tmux/{variant}/tmux.conf` | `source-file` from your tmux.conf |
| delta | `dist/delta/{variant}/delta.gitconfig` | Add `[delta]` section to `~/.gitconfig` |
| VS Code | `dist/vscode/{variant}/kiln.json` | Copy dir to `~/.vscode/extensions/tobias.kiln-theme-0.1.0/` |
| Obsidian | `dist/obsidian/` | Copy to `{vault}/.obsidian/themes/Kiln/` |
| Web | `dist/web/{variant}/variables.css` | `@import` the CSS file |

## Generate

```bash
# All targets, both variants
python -m kiln.generate

# Single target
python -m kiln.generate --target ghostty

# Single variant
python -m kiln.generate --variant dark

# Validate WCAG contrast
python -m kiln.validate
```

## Setup

```bash
uv venv && uv pip install -e ".[dev]"
```

## Project structure

```
palette.yaml          # Source of truth — OKLCH + hex for all 27 colors × 2 variants
generate.py           # CLI: palette.yaml + Jinja2 templates → dist/
templates/            # One template per target app
dist/                 # Generated output (gitignored)
preview/index.html    # Browser-based palette + code preview
```

## Installation notes

### Ghostty

On macOS, the config file is at `~/Library/Application Support/com.mitchellh.ghostty/config`, **not** `~/.config/ghostty/config`. Add:

```
theme = kiln-dark
split-divider-color = #3C372E
unfocused-split-fill = #121110
```

Reload with Cmd+Shift+, (no full restart needed for color changes).

### Fish + Tide

Both use Fish universal variables (`set -U`), so sourcing the config once persists across all sessions:

```fish
fish -c "source dist/fish/dark/fish.conf"
fish -c "source dist/tide/dark/tide.conf"
```

Do **not** run `tide configure` after applying — it resets all colors to Tide defaults.

### Neovim (LazyVim)

Copy the **single-file** colorscheme (not the subdirectory):

```bash
cp dist/nvim/dark/kiln.lua ~/.config/nvim/colors/kiln-dark.lua
```

In `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
{
  "LazyVim/LazyVim",
  opts = {
    colorscheme = "kiln-dark",
  },
}
```

The colorscheme includes highlight groups for LazyVim's ecosystem: Lazy.nvim, Snacks dashboard, Neo-tree, Noice, Mini, Flash, Notify, Telescope, Which-key, and indent-blankline.

### VS Code

The extension directory **must** follow the `publisher.name-version` naming convention:

```bash
mkdir -p ~/.vscode/extensions/tobias.kiln-theme-0.1.0/themes
cp dist/vscode/dark/kiln.json ~/.vscode/extensions/tobias.kiln-theme-0.1.0/themes/kiln-dark.json
cp dist/vscode/light/kiln.json ~/.vscode/extensions/tobias.kiln-theme-0.1.0/themes/kiln-light.json
cp dist/vscode/dark/package.json ~/.vscode/extensions/tobias.kiln-theme-0.1.0/
```

A **full quit + reopen** is required for VS Code to discover a new extension (Reload Window is not enough the first time).

### Obsidian

Kiln is a proper Obsidian theme (not a CSS snippet). Both dark and light variants are in a single `theme.css`:

```bash
mkdir -p {vault}/.obsidian/themes/Kiln
cp dist/obsidian/manifest.json dist/obsidian/theme.css {vault}/.obsidian/themes/Kiln/
```

Select "Kiln" in Settings → Appearance → Themes. Obsidian's dark/light toggle switches variants automatically.

### delta (git diff)

Replace or add to the `[delta]` section in `~/.gitconfig`:

```ini
[delta]
    syntax-theme = none
    minus-style = "#F8F4F0 #E8665E"
    plus-style = "#F8F4F0 #86BE60"
    file-style = "#6098DB bold"
    hunk-header-style = "#E08A50"
    line-numbers-minus-style = "#E8665E"
    line-numbers-plus-style = "#86BE60"
    line-numbers-zero-style = "#7A6F5E"
```

## Design

- **OKLCH-first**: All accents at uniform perceptual lightness (~0.65 dark, ~0.43 light)
- **WCAG AA**: 17/18 color pairs pass (comment is intentionally low-contrast at 3.6:1)
- **Warm neutrals**: Base hue at 70° OKLCH (red-orange bias), carried by backgrounds not text
- **Text at #F8F4F0**: Near-white for maximum readability; warmth in the background, clarity in the foreground
