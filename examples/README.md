# Theme Blueprint Examples

Actual theme configuration files from three established themes, fetched for
structural comparison with Kiln's generated output in `dist/`.

## Purpose

Compare file formats, key names, highlight groups, and color slot conventions
across themes to ensure Kiln's templates produce structurally compatible output.
The best structural match becomes the "master blueprint" — we swap Kiln colors
into an already-proven structure rather than inventing from scratch.

## Variants Fetched

| Theme | Variants | Source |
|-------|----------|--------|
| Catppuccin | All four: Mocha, Macchiato, Frappé, Latte | Multiple repos under `github.com/catppuccin/` |
| Dracula | Default (dark-only) | Multiple repos under `github.com/dracula/` |
| Tokyo Night | Night (dark) | `folke/tokyonight.nvim` extras + companion repos |

Catppuccin's four flavors share identical structure (same 26 color names, same
key ordering) — only the hex values differ. This makes them the ideal reference
for validating that Kiln's "same structure, different colors" approach works.

## Coverage Matrix

| Target | Kiln | Catppuccin | Dracula | Tokyo Night |
|--------|:----:|:----------:|:-------:|:-----------:|
| ghostty | yes | yes | yes | yes |
| fish | yes | yes | yes | yes |
| tide | yes | — | — | — |
| nvim | yes (Lua) | yes (Lua) | yes (VimScript) | yes (Lua) |
| tmux | yes (conf) | yes (conf) | yes (bash plugin) | yes (conf) |
| delta | yes | yes | — | yes |
| vscode | yes (JSON) | yes (TypeScript src) | yes (YAML src) | yes (JSON) |
| obsidian | yes | yes | yes | yes |
| web | yes | — | — | — |

## Structural Match Assessment

**Catppuccin is the recommended master blueprint:**

1. **Color naming** — 24 of 27 Kiln color names are identical to Catppuccin
   (crust, mantle, base, surface0-2, overlay0-2, text, subtext0-1, red, maroon,
   peach, yellow, green, teal, sky, sapphire, blue, lavender, mauve, pink).
   Kiln adds `gold`, `comment`, `rose`; Catppuccin has `rosewater`, `flamingo`.
2. **Lua nvim** — Both use separate palette + highlight group files.
3. **Broadest coverage** — Repos for 7 of 9 targets (tide and web are Kiln-only).
4. **Identical obsidian/delta/ghostty structure**.

## Re-fetch

```bash
bash scripts/fetch-examples.sh
```

## Licenses

All fetched files are from MIT-licensed repositories. They are included here
as reference material for structural comparison only. See each theme's
repository for full license terms.
