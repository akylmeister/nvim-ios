# Neovim for iOS / Swift development

My personal [LazyVim](https://github.com/LazyVim/LazyVim)-based Neovim config, set
up as a full iOS/macOS Swift IDE: sourcekit-lsp, build/run/test on simulators &
devices, formatting, linting, debugging, and an Xcode-accurate colorscheme.

## Install on a new machine

```bash
# 1. Back up any existing config
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true

# 2. Clone this repo into place
git clone <YOUR_REPO_URL> ~/.config/nvim

# 3. Install the external CLI tools (Homebrew, Xcode tooling, gems)
~/.config/nvim/scripts/bootstrap.sh

# 4. Launch Neovim — lazy.nvim installs all plugins pinned in lazy-lock.json
nvim
```

Requirements: macOS with **Xcode** installed, **Neovim ≥ 0.11**, and **Homebrew**.

## What's included

| Area | Plugin / tool | Notes |
|---|---|---|
| LSP | `sourcekit-lsp` (ships with Xcode) | Swift/ObjC completion, `gd`, diagnostics |
| Project ↔ LSP | `xcode-build-server` | generates `buildServer.json` so the LSP understands `.xcodeproj`/`.xcworkspace` |
| Build/run/test | [`xcodebuild.nvim`](https://github.com/wojciech-kulik/xcodebuild.nvim) | simulators & devices, test explorer, coverage, SwiftUI previews, debugging |
| Formatting | `swiftformat` via `conform.nvim` | |
| Linting | `swiftlint` via `nvim-lint` | |
| Syntax | `nvim-treesitter` (swift parser) | |
| Debugging | `nvim-dap` (+ Xcode 16+ built-in lldb-dap) | |
| Theme | [`vim-colors-xcode`](https://github.com/arzg/vim-colors-xcode) + custom overrides | Xcode "Default (Dark)" palette, incl. semantic-token colors |

The iOS-specific configuration lives in:

- [`lua/plugins/ios.lua`](lua/plugins/ios.lua) — LSP, xcodebuild.nvim, formatting, linting
- [`lua/plugins/ui.lua`](lua/plugins/ui.lua) — Xcode Dark theme + semantic highlight overrides

## Usage

### Swift Package (`Package.swift`)

Just open Neovim in the package directory — sourcekit-lsp works immediately.

### Xcode project / Tuist

sourcekit-lsp needs a build-server config to understand an `.xcodeproj`/`.xcworkspace`:

```bash
# Tuist: generate the project first
tuist generate --no-open

nvim .
:XcodebuildSetup        # pick the .xcworkspace, then scheme / config / device
                        # (this also writes buildServer.json automatically)
```

Then **build once** (`<leader>xb`) so the LSP has index/compile info. Now
completion, `gd`, and diagnostics work across files.

> Tip: if your scheme isn't listed, choose **`[Reload Schemes]`** in the picker
> (Tuist often stores schemes at the workspace level).

### Key bindings

Quick reference below; the **full cheatsheet is in [`CHEATSHEET.md`](CHEATSHEET.md)**
(build/run/test, debugging, LSP navigation, files, diagnostics).

| Key | Action |
|---|---|
| `<leader>X` | Xcodebuild action picker (everything) |
| `<leader>xb` / `<leader>xr` | Build / Build & Run |
| `<leader>xt` / `<leader>xT` | Run tests / current test class |
| `<leader>xd` | Select device |
| `<leader>xl` | Toggle build logs |
| `<leader>xe` | Toggle test explorer |
| `<leader>dd` / `<leader>d;` | Build & debug / toggle breakpoint |

Run `:checkhealth xcodebuild` if anything misbehaves.

## Updating plugins

```bash
nvim  # then :Lazy sync   (updates plugins and re-pins lazy-lock.json)
git add lazy-lock.json && git commit -m "chore: bump plugins"
```

See [`CLAUDE.md`](CLAUDE.md) for how this setup is structured (also used by
Claude Code to help maintain it).
