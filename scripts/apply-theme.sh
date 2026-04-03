#!/usr/bin/env bash
# Apply a kiln-theme variant to one or more target applications.
#
# Usage:
#   scripts/apply-theme.sh <variant> [target...]
#   scripts/apply-theme.sh ember                     # apply to all targets
#   scripts/apply-theme.sh glow ghostty fish tide    # apply to specific targets
#   scripts/apply-theme.sh --list                    # show available variants
#   scripts/apply-theme.sh --dry-run ember ghostty   # preview without changes
#
# Environment:
#   OBSIDIAN_VAULT  Path to Obsidian vault (for obsidian target)
#   KILN_DARK       Dark variant for combined targets (default: same as variant)
#   KILN_LIGHT      Light variant for combined targets (default: light/glow/dawn)

set -euo pipefail
cd "$(dirname "$0")/.."

PROJECT_ROOT="$(pwd)"
DIST="$PROJECT_ROOT/dist"
DRY_RUN=false
TARGETS=(ghostty fish tide nvim tmux delta vscode obsidian)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}  ✓${NC} $*"; }
warn() { echo -e "${YELLOW}  !${NC} $*"; }
skip() { echo -e "${BLUE}  ○${NC} $*"; }
err() { echo -e "${RED}  ✗${NC} $*" >&2; }

# ── List available variants ──────────────────────────────────────

list_variants() {
  echo "Available variants:"
  .venv/bin/python3 -c "
import yaml
with open('palette.yaml') as f:
    p = yaml.safe_load(f)
for name, v in p['variants'].items():
    print(f'  {name:25s} {v[\"display_name\"]}')
"
}

# ── Parse arguments ──────────────────────────────────────────────

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: scripts/apply-theme.sh [--dry-run] <variant> [target...]"
  echo "       scripts/apply-theme.sh --list"
  echo ""
  echo "Targets: ${TARGETS[*]}"
  echo ""
  echo "Examples:"
  echo "  scripts/apply-theme.sh ember                  # all targets"
  echo "  scripts/apply-theme.sh glow ghostty fish tide  # specific targets"
  echo "  scripts/apply-theme.sh --dry-run forge         # preview"
  exit 0
fi

if [ "$1" = "--list" ]; then
  list_variants
  exit 0
fi

if [ "$1" = "--dry-run" ]; then
  DRY_RUN=true
  shift
fi

VARIANT="$1"
shift

# If specific targets given, use those; otherwise all
if [ $# -gt 0 ]; then
  TARGETS=("$@")
fi

# ── Ensure variant is generated ──────────────────────────────────

if [ ! -d "$DIST/ghostty/$VARIANT" ]; then
  echo "Generating $VARIANT..."
  .venv/bin/python -m kiln.generate --variant "$VARIANT"
fi

echo ""
echo "Applying variant: $VARIANT"
echo "Targets: ${TARGETS[*]}"
if $DRY_RUN; then echo "(dry run — no changes will be made)"; fi
echo ""

# ── Per-target apply functions ───────────────────────────────────

apply_ghostty() {
  local src="$DIST/ghostty/$VARIANT/ghostty.conf"
  # macOS uses ~/Library/Application Support; Linux uses ~/.config
  local ghostty_dir="$HOME/.config/ghostty"
  if [ -d "$HOME/Library/Application Support/com.mitchellh.ghostty" ]; then
    ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  fi
  local config="$ghostty_dir/config"

  if $DRY_RUN; then
    skip "ghostty: would inline colors from $src into $config"
    return
  fi

  if [ ! -f "$config" ]; then
    warn "ghostty: no config at $config"
    return
  fi

  # Remove any existing theme = line (we inline instead)
  sed -i '' '/^theme = /d' "$config"

  # Build the color block from the generated theme file (skip comments)
  local color_block
  color_block=$(grep -v '^#' "$src" | grep -v '^$')

  local begin_marker="# ── kiln-theme:begin ──"
  local end_marker="# ── kiln-theme:end ──"

  if grep -q "$begin_marker" "$config"; then
    # Replace existing managed block
    local tmp in_block=false
    tmp=$(mktemp)
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ "$line" == *"kiln-theme:begin"* ]]; then
        echo "$begin_marker ($VARIANT)" >>"$tmp"
        echo "$color_block" >>"$tmp"
        in_block=true
      elif [[ "$line" == *"kiln-theme:end"* ]]; then
        echo "$line" >>"$tmp"
        in_block=false
      elif ! $in_block; then
        echo "$line" >>"$tmp"
      fi
    done <"$config"
    mv "$tmp" "$config"
  else
    # Append managed block
    printf '\n%s\n%s\n%s\n' "$begin_marker ($VARIANT)" "$color_block" "$end_marker" >>"$config"
  fi

  info "ghostty: inlined $VARIANT colors in $config"
  warn "ghostty: reload with Cmd+Shift+, or restart"
}

apply_fish() {
  local src="$DIST/fish/$VARIANT/fish.conf"

  if $DRY_RUN; then
    skip "fish: would source $src"
    return
  fi

  fish -c "source $src"
  info "fish: applied colors (universal variables set)"
}

apply_tide() {
  local src="$DIST/tide/$VARIANT/tide.conf"

  if $DRY_RUN; then
    skip "tide: would source $src"
    return
  fi

  fish -c "source $src"
  info "tide: applied prompt colors (universal variables set)"
}

apply_nvim() {
  local src="$DIST/nvim/$VARIANT/kiln.lua"
  local dest="$HOME/.config/nvim/colors/kiln-$VARIANT.lua"

  if $DRY_RUN; then
    skip "nvim: would copy $src → $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  info "nvim: installed colorscheme to $dest"
  warn "nvim: run :colorscheme kiln-$VARIANT to activate"
}

apply_tmux() {
  local src="$DIST/tmux/$VARIANT/tmux.conf"

  if $DRY_RUN; then
    skip "tmux: would source $src"
    return
  fi

  if tmux info &>/dev/null; then
    tmux source-file "$src"
    info "tmux: sourced $src"
  else
    warn "tmux: not running — source manually: tmux source-file $src"
  fi
}

apply_delta() {
  local src="$DIST/delta/$VARIANT/delta.gitconfig"

  if $DRY_RUN; then
    skip "delta: would print include instructions for $src"
    return
  fi

  info "delta: config generated at $src"
  warn "delta: add to ~/.gitconfig:"
  echo "         [include]"
  echo "           path = $src"
  echo "         [delta]"
  echo "           features = kiln-$VARIANT"
}

apply_vscode() {
  local src_theme="$DIST/vscode/$VARIANT/kiln.json"
  local src_pkg="$DIST/vscode/$VARIANT/package.json"
  local ext_dir="$HOME/.vscode/extensions/kiln-$VARIANT-1.0.0"

  if $DRY_RUN; then
    skip "vscode: would install extension to $ext_dir"
    return
  fi

  mkdir -p "$ext_dir/themes"
  # Write a corrected package.json with the right name and path
  local display_name
  display_name=$(.venv/bin/python3 -c "
import yaml
with open('palette.yaml') as f:
    p = yaml.safe_load(f)
print(p['variants']['$VARIANT']['display_name'])
")
  local ui_theme="vs-dark"
  # Detect light variants
  case "$VARIANT" in light | glow | dawn | catppuccin_latte) ui_theme="vs" ;; esac

  cat >"$ext_dir/package.json" <<EOFPKG
{
  "name": "kiln-$VARIANT",
  "displayName": "$display_name",
  "description": "Kiln theme — $display_name variant",
  "version": "1.0.0",
  "publisher": "tobias",
  "engines": { "vscode": "^1.80.0" },
  "categories": ["Themes"],
  "contributes": {
    "themes": [{ "label": "$display_name", "uiTheme": "$ui_theme", "path": "./themes/kiln.json" }]
  }
}
EOFPKG
  cp "$src_theme" "$ext_dir/themes/kiln.json"
  info "vscode: installed extension to $ext_dir"
  warn "vscode: restart VSCode, then Cmd+K Cmd+T → $display_name"
}

apply_obsidian() {
  local vault="${OBSIDIAN_VAULT:-}"
  if [ -z "$vault" ]; then
    # Try to find the vault
    vault="$HOME/GIT_ROOT/GIT_LAB/Tobias.Schelling/Obsidian_Vault"
  fi

  if [ ! -d "$vault/.obsidian" ]; then
    err "obsidian: vault not found at $vault — set OBSIDIAN_VAULT env var"
    return 1
  fi

  local display_name
  display_name=$(.venv/bin/python3 -c "
import yaml
with open('palette.yaml') as f:
    p = yaml.safe_load(f)
print(p['variants']['$VARIANT']['display_name'])
")
  local dest="$vault/.obsidian/themes/$display_name"

  if $DRY_RUN; then
    skip "obsidian: would render and install to $dest"
    return
  fi

  # Determine dark+light pair for combined CSS
  local dark_v="$VARIANT"
  local light_v=""
  case "$VARIANT" in
    dark | forge | ember | catppuccin_mocha | catppuccin_macchiato | catppuccin_frappe)
      dark_v="$VARIANT"
      light_v="${KILN_LIGHT:-light}"
      ;;
    light | glow | dawn | catppuccin_latte)
      dark_v="${KILN_DARK:-dark}"
      light_v="$VARIANT"
      ;;
  esac

  # Render combined obsidian theme via Python
  .venv/bin/python3 -c "
import yaml, json
from jinja2 import Environment, FileSystemLoader

with open('palette.yaml') as f:
    palette = yaml.safe_load(f)

def strip_hash(h): return h.lstrip('#')
def flatten(variant_name):
    variant = palette['variants'][variant_name]
    colors = {}
    for cat in ('base', 'text', 'accents'):
        for name, data in variant[cat].items():
            colors[name] = {'hex': data['hex'], 'hex_stripped': strip_hash(data['hex']),
                           'oklch': data.get('oklch',{}), 'role': data.get('role',''), 'category': cat}
    # Resolve heading mapping
    hmap = palette.get('heading_mapping', {})
    headings_raw = hmap.get(variant_name, hmap.get('default', {}))
    headings = {}
    for level, cref in headings_raw.items():
        if cref in colors: headings[level] = colors[cref]
    colors['_headings'] = headings
    return colors

env = Environment(loader=FileSystemLoader('templates'), keep_trailing_newline=True, trim_blocks=True, lstrip_blocks=True)
env.filters['strip_hash'] = strip_hash

t = env.get_template('obsidian/theme.css.j2')
css = t.render(version=palette['version'], dark=flatten('$dark_v'), light=flatten('$light_v'))

import pathlib
dest = pathlib.Path('$dest')
dest.mkdir(parents=True, exist_ok=True)
(dest / 'theme.css').write_text(css)
(dest / 'manifest.json').write_text(json.dumps({'name': '$display_name', 'version': '1.0.0', 'minAppVersion': '1.9.0', 'author': 'Tobias Schelling'}, indent=2))
"
  info "obsidian: installed theme to $dest"
  warn "obsidian: dark=$dark_v, light=$light_v — select '$display_name' in Settings → Appearance"
}

# ── Apply to each target ─────────────────────────────────────────

for target in "${TARGETS[@]}"; do
  case "$target" in
    ghostty) apply_ghostty ;;
    fish) apply_fish ;;
    tide) apply_tide ;;
    nvim) apply_nvim ;;
    tmux) apply_tmux ;;
    delta) apply_delta ;;
    vscode) apply_vscode ;;
    obsidian) apply_obsidian ;;
    *) err "Unknown target: $target" ;;
  esac
done

echo ""
echo "Done."
