# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

A personal **LazyVim** (Neovim distribution) config on macOS, specialized for
**iOS / Swift development**. Neovim ≥ 0.11. It is meant to be cloned into
`~/.config/nvim` on any Mac. Plugins are managed by **lazy.nvim** and pinned in
`lazy-lock.json`; external CLI tools are installed by `scripts/bootstrap.sh`.

## Layout

- `init.lua` → loads `lua/config/lazy.lua` (LazyVim bootstrap).
- `lua/config/` → `options.lua`, `keymaps.lua`, `autocmds.lua`, `lazy.lua`.
- `lua/plugins/` → plugin specs; each file returns a lazy.nvim spec table.
  - `ios.lua` — **the iOS toolchain**: sourcekit-lsp, `xcodebuild.nvim`,
    `conform.nvim` (swiftformat), `nvim-lint` (swiftlint), treesitter swift.
  - `ui.lua` — **theme**: `vim-colors-xcode` (`xcodedark`) plus highlight
    overrides that reproduce Xcode's semantic-token colors.
  - `example.lua` — inert LazyVim sample (guarded by `if true then return {} end`).

## How the iOS setup works (important context)

- **sourcekit-lsp** ships with Xcode (`xcrun --find sourcekit-lsp`); no Mason.
  nvim-lspconfig's bundled `lsp/sourcekit.lua` provides the correct
  `root_dir` for Neovim 0.11 — **do not** override it with an old
  `function(fname)`-style root_dir; that breaks project-root detection and
  disables cross-file completion / `gd`.
- For **Xcode projects / Tuist**, the LSP needs `buildServer.json`, produced by
  `xcode-build-server`. `xcodebuild.nvim` is configured with
  `integrations.xcode_build_server = { enabled = true, guess_scheme = true }`,
  so selecting a scheme regenerates it automatically.
- **Tuist** flow: `tuist generate --no-open` → `:XcodebuildSetup` (pick the
  `.xcworkspace`) → build once. If schemes are missing, `[Reload Schemes]`
  falls back to `xcodebuild -list` (Tuist often stores schemes at the workspace
  level, which the default `find`-based discovery misses).
- **Debugging**: `nvim-dap`; Xcode 16+ uses built-in lldb-dap, so codelldb is
  not required. `require("xcodebuild.integrations.dap").setup()` takes no path.

## Theme / colors

`ui.lua` maps Neovim highlight groups to Xcode's exact "Default (Dark)" palette.
Values come from Xcode itself:

```
/Applications/Xcode.app/Contents/SharedFrameworks/SourceEditor.framework/Versions/A/Resources/Default (Dark).xccolortheme
```

Read it with `plutil -convert xml1 -o - "<file>"`; convert the `r g b a` floats
to hex (`round(x*255)`). Key semantic rules (matching Xcode):

- declarations (`@lsp.typemod.*.declaration`, `@function`) → blue `#5DD8FF`
- function/method calls in your code (`@lsp.type.function`) → green `#67B7A4`
- SDK symbols (`…defaultLibrary` modifier) → purple (`#A167E6` / `#D0A8FF`)
- type usage → teal `#9EF1DD`; parameters → blue `#41A1C0`;
  enum cases/constants → green `#67B7A4`
- keyword `#FC5FA3`, string `#FC6A5D`, number `#D0BF69`, comment `#6C7986`

Green-vs-purple (your code vs SDK) only appears once sourcekit-lsp emits
semantic tokens (i.e. project resolved). Treesitter fallbacks cover the rest.

Overrides are re-applied via a `ColorScheme` autocmd (pattern `xcode*`), so they
survive `:colorscheme` reloads.

## Conventions for changes

- Every file in `lua/plugins/` must `return` a lazy.nvim spec (table).
- Extend LazyVim defaults via `opts` merging; don't fork whole plugin configs.
- Keep `lazy-lock.json` committed — it pins reproducible plugin versions.
- After editing plugin specs, verify headless:
  `nvim --headless "+Lazy! sync" +qa` and
  `nvim --headless "+checkhealth" +qa` (no errors).
- Prefer the built-in LazyVim stack (blink.cmp, conform, nvim-lint, snacks,
  treesitter) over adding parallel plugins.

## Common tasks

- Add a formatter/linter: extend `formatters_by_ft` / `linters_by_ft` in
  `ios.lua`, and add the CLI tool to `scripts/bootstrap.sh`.
- Adjust a symbol color: put the cursor on it in Neovim, run `:Inspect` to see
  its `@lsp…`/treesitter group, then map that group in `ui.lua`.
