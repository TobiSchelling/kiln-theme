#!/usr/bin/env bash
# Fetch theme blueprint files from Dracula, Catppuccin, and Tokyo Night.
# Re-run this script to refresh examples after upstream changes.
set -euo pipefail
cd "$(dirname "$0")/.."

fetch() {
  local dest="$1" url="$2"
  mkdir -p "$(dirname "$dest")"
  if curl -sSL --fail -o "$dest" "$url"; then
    echo "  ✓ $dest"
  else
    echo "  ✗ FAILED: $dest  ($url)"
    rm -f "$dest"
    return 1
  fi
}

FAIL=0

# ─── Catppuccin (Mocha) ──────────────────────────────────────────────

echo "=== Catppuccin (Mocha) ==="

fetch examples/catppuccin/palette.json \
  "https://raw.githubusercontent.com/catppuccin/palette/main/palette.json" || ((FAIL++))

# Ghostty
fetch examples/catppuccin/ghostty/ghostty.conf \
  "https://raw.githubusercontent.com/catppuccin/ghostty/main/themes/catppuccin-mocha.conf" || ((FAIL++))

# Fish
fetch examples/catppuccin/fish/fish.theme \
  "https://raw.githubusercontent.com/catppuccin/fish/main/themes/catppuccin-mocha.theme" || ((FAIL++))

# Neovim
fetch examples/catppuccin/nvim/mocha.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/palettes/mocha.lua" || ((FAIL++))
fetch examples/catppuccin/nvim/editor.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/groups/editor.lua" || ((FAIL++))
fetch examples/catppuccin/nvim/syntax.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/groups/syntax.lua" || ((FAIL++))
fetch examples/catppuccin/nvim/treesitter.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/groups/treesitter.lua" || ((FAIL++))
fetch examples/catppuccin/nvim/semantic_tokens.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/groups/semantic_tokens.lua" || ((FAIL++))
fetch examples/catppuccin/nvim/terminal.lua \
  "https://raw.githubusercontent.com/catppuccin/nvim/main/lua/catppuccin/groups/terminal.lua" || ((FAIL++))

# Tmux
fetch examples/catppuccin/tmux/tmux.conf \
  "https://raw.githubusercontent.com/catppuccin/tmux/main/themes/catppuccin_mocha_tmux.conf" || ((FAIL++))

# Delta
fetch examples/catppuccin/delta/delta.gitconfig \
  "https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig" || ((FAIL++))

# VS Code
fetch examples/catppuccin/vscode/tokenColors.ts \
  "https://raw.githubusercontent.com/catppuccin/vscode/main/packages/catppuccin-vsc/src/theme/tokenColors.ts" || ((FAIL++))
fetch examples/catppuccin/vscode/uiColors.ts \
  "https://raw.githubusercontent.com/catppuccin/vscode/main/packages/catppuccin-vsc/src/theme/uiColors.ts" || ((FAIL++))
fetch examples/catppuccin/vscode/semanticTokens.ts \
  "https://raw.githubusercontent.com/catppuccin/vscode/main/packages/catppuccin-vsc/src/theme/semanticTokens.ts" || ((FAIL++))

# Obsidian
fetch examples/catppuccin/obsidian/manifest.json \
  "https://raw.githubusercontent.com/catppuccin/obsidian/main/manifest.json" || ((FAIL++))
fetch examples/catppuccin/obsidian/theme.css \
  "https://raw.githubusercontent.com/catppuccin/obsidian/main/theme.css" || ((FAIL++))

# ─── Dracula ─────────────────────────────────────────────────────────

echo ""
echo "=== Dracula ==="

# Ghostty
fetch examples/dracula/ghostty/ghostty.conf \
  "https://raw.githubusercontent.com/dracula/ghostty/main/dracula" || ((FAIL++))

# Fish
fetch examples/dracula/fish/fish.theme \
  "https://raw.githubusercontent.com/dracula/fish/master/themes/Dracula%20Official.theme" || ((FAIL++))

# Neovim (VimScript)
fetch examples/dracula/nvim/dracula.vim \
  "https://raw.githubusercontent.com/dracula/vim/master/colors/dracula.vim" || ((FAIL++))
fetch examples/dracula/nvim/palette.vim \
  "https://raw.githubusercontent.com/dracula/vim/master/autoload/dracula.vim" || ((FAIL++))

# Tmux (bash plugin)
fetch examples/dracula/tmux/dracula.sh \
  "https://raw.githubusercontent.com/dracula/tmux/master/scripts/dracula.sh" || ((FAIL++))

# VS Code
fetch examples/dracula/vscode/dracula.yml \
  "https://raw.githubusercontent.com/dracula/visual-studio-code/main/src/dracula.yml" || ((FAIL++))

# Obsidian
fetch examples/dracula/obsidian/manifest.json \
  "https://raw.githubusercontent.com/dracula/obsidian/main/manifest.json" || ((FAIL++))
fetch examples/dracula/obsidian/theme.css \
  "https://raw.githubusercontent.com/dracula/obsidian/main/theme.css" || ((FAIL++))

# ─── Tokyo Night (Night) ─────────────────────────────────────────────

echo ""
echo "=== Tokyo Night (Night) ==="

# Ghostty
fetch examples/tokyonight/ghostty/ghostty.conf \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/ghostty/tokyonight_night" || ((FAIL++))

# Fish
fetch examples/tokyonight/fish/fish.fish \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/fish/tokyonight_night.fish" || ((FAIL++))

# Neovim
fetch examples/tokyonight/nvim/night.lua \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/lua/tokyonight/colors/night.lua" || ((FAIL++))
fetch examples/tokyonight/nvim/storm.lua \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/lua/tokyonight/colors/storm.lua" || ((FAIL++))
fetch examples/tokyonight/nvim/base.lua \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/lua/tokyonight/groups/base.lua" || ((FAIL++))
fetch examples/tokyonight/nvim/semantic_tokens.lua \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/lua/tokyonight/groups/semantic_tokens.lua" || ((FAIL++))

# Tmux
fetch examples/tokyonight/tmux/tmux.conf \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/tmux/tokyonight_night.tmux" || ((FAIL++))

# Delta
fetch examples/tokyonight/delta/delta.gitconfig \
  "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/delta/tokyonight_night.gitconfig" || ((FAIL++))

# VS Code
fetch examples/tokyonight/vscode/tokyo-night-color-theme.json \
  "https://raw.githubusercontent.com/enkia/tokyo-night-vscode-theme/master/themes/tokyo-night-color-theme.json" || ((FAIL++))

# Obsidian
fetch examples/tokyonight/obsidian/manifest.json \
  "https://raw.githubusercontent.com/tcmmichaelb139/obsidian-tokyonight/main/manifest.json" || ((FAIL++))
fetch examples/tokyonight/obsidian/theme.css \
  "https://raw.githubusercontent.com/tcmmichaelb139/obsidian-tokyonight/main/theme.css" || ((FAIL++))

# ─── Summary ─────────────────────────────────────────────────────────

echo ""
echo "=== Summary ==="
echo "Catppuccin: $(find examples/catppuccin -type f | wc -l | tr -d ' ') files"
echo "Dracula:    $(find examples/dracula -type f | wc -l | tr -d ' ') files"
echo "TokyoNight: $(find examples/tokyonight -type f | wc -l | tr -d ' ') files"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "⚠  $FAIL download(s) failed — check URLs above."
  exit 1
fi

echo ""
echo "All downloads succeeded."
