# iOS / Swift Neovim Cheatsheet

`<leader>` = **Space**. Everything is discoverable: press `<leader>` and wait for
which-key, or hit `<leader>X` for the full Xcodebuild action menu.

---

## 0. First time in a project

```bash
# Tuist projects: generate first
tuist generate --no-open
```

| Step | Command |
|---|---|
| Configure project (project file → scheme → config → device → test plan) | `:XcodebuildSetup` |
| If your scheme isn't listed | pick **`[Reload Schemes]`** in the list |
| Build once so the LSP indexes the code | `<leader>xb` |

> Swift packages (`Package.swift`) need none of this — the LSP just works.

---

## 1. Build · Run · Test  (most used, prefix `<leader>x`)

| Key | Action |
|---|---|
| `<leader>X` | **Action picker — everything** |
| `<leader>xb` | Build |
| `<leader>xr` | Build & Run |
| `<leader>xt` | Run tests (in Visual mode: run selected tests) |
| `<leader>xT` | Run current test class |
| `<leader>x.` | Repeat last test run |
| `<leader>xe` | Toggle test explorer |
| `<leader>xl` | Toggle build logs |
| `<leader>xc` / `<leader>xC` | Toggle / show code coverage |
| `<leader>xd` | Select device / simulator |
| `<leader>xp` / `<leader>x⏎` | Generate / toggle SwiftUI preview |
| `<leader>xf` | Project manager (add/rename/delete files) |
| `<leader>xa` | Show code actions |

---

## 2. Debugging  (prefix `<leader>d`)

| Key | Action |
|---|---|
| `<leader>d;` | Toggle breakpoint |
| `<leader>d:` | Toggle log/message breakpoint |
| `<leader>dd` | Build & Debug |
| `<leader>dr` | Debug (no build) |
| `<leader>dt` | Debug tests |
| `<leader>dc` | Continue |
| `<leader>do` / `<leader>di` / `<leader>dO` | Step over / into / out |
| `<leader>du` | Toggle debug UI |
| `<leader>dx` | Terminate session |

---

## 3. Code navigation & LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover docs |
| `gK` | Signature help |
| `]]` / `[[` | Next / previous reference of symbol |
| `<leader>ss` / `<leader>sS` | Document / workspace symbols |
| `<C-o>` / `<C-i>` | Jump back / forward (after `gd`) |

---

## 4. Edit · refactor · format

| Key | Action |
|---|---|
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cA` | Source action |
| `<leader>co` | Organize imports |
| `<leader>cc` | Run codelens |
| `<leader>cf` | Format buffer (swiftformat) |
| `<leader>cR` | Rename file (updates imports) |

> Linting (swiftlint) and formatting run automatically; `<leader>cf` forces it.

---

## 5. Diagnostics (errors / warnings)

| Key | Action |
|---|---|
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `]w` / `[w` | Next / previous warning |
| `<leader>cd` | Line diagnostics (float) |
| `<leader>sd` | List all diagnostics |
| `<leader>xx` | Diagnostics panel (Trouble) |

---

## 6. Files · search · windows

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files (project root) |
| `<leader>fF` | Find files (cwd) |
| `<leader>fg` | Find git-tracked files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Open buffers |
| `<leader>sg` | Live grep (project) |
| `<leader>sw` | Grep word/selection under cursor |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Close buffer |
| `<leader>bb` | Switch to other buffer |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>qq` | Quit all |

---

## 7. Handy commands

| Command | What it does |
|---|---|
| `:XcodebuildSetup` | (Re)configure the project |
| `:XcodebuildPicker` | Same as `<leader>X` |
| `:XcodebuildSelectScheme` | Change scheme (regenerates `buildServer.json`) |
| `:XcodebuildCleanDerivedData` | Clean DerivedData |
| `:checkhealth xcodebuild` | Diagnose the iOS setup |
| `:LspInfo` | Confirm sourcekit is attached (+ root dir) |
| `:Inspect` | Show the highlight group under the cursor (for theming) |
| `:Lazy sync` | Update plugins |
| `:Mason` | Manage LSP/tool binaries |

---

### If completion / `gd` stops working

1. `:LspInfo` → is `sourcekit` attached with the right root dir?
2. Xcode/Tuist project → is there a `buildServer.json`? Re-run
   `:XcodebuildSelectScheme` (it regenerates it), then build once.
3. `:checkhealth xcodebuild` and fix anything red.
