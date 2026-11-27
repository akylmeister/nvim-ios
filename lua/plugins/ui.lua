-- Xcode Default Dark theme + accurate SourceKit-style semantic highlighting.
--
-- Xcode colors symbols by *semantics* (declaration vs. call, your code vs. SDK),
-- which in Neovim comes from LSP semantic tokens (`@lsp.type.*` / `@lsp.typemod.*`)
-- and Treesitter (`@function`, `@function.call`, ...). The base colorscheme
-- doesn't map those to Xcode's palette, so we do it here.
--
-- Hex values were read straight from Xcode's "Default (Dark).xccolortheme".

-- Exact Xcode Default Dark palette
local xc = {
  decl = "#5DD8FF", -- func/type DECLARATION name (blue)
  decl_other = "#41A1C0", -- variable declaration (darker blue)
  fn = "#67B7A4", -- function/method CALL, project (green)
  fn_sdk = "#A167E6", -- function/method from SDK (purple)
  type = "#9EF1DD", -- type/class/enum usage, project (teal)
  type_sdk = "#D0A8FF", -- SDK types: String, Int, ... (light purple)
  member = "#67B7A4", -- instance property/member, project (green)
  member_sdk = "#A167E6", -- SDK property/member (purple)
  parameter = "#41A1C0", -- function parameter (blue, declaration.other)
  enum_case = "#67B7A4", -- enum case / constant, project (green)
  enum_case_sdk = "#A167E6", -- enum case from SDK (purple)
  keyword = "#FC5FA3", -- pink
  string = "#FC6A5D", -- salmon
  number = "#D0BF69", -- yellow
  comment = "#6C7986", -- gray
  attribute = "#BF8555", -- tan
  macro = "#FD8F3F", -- orange
}

local function set(groups, opts)
  for _, g in ipairs(groups) do
    vim.api.nvim_set_hl(0, g, opts)
  end
end

-- Make the snacks.nvim file explorer look like Xcode's Project Navigator:
-- background matches the editor, dim tree guides, neutral file/dir text, and a
-- blue selected row.
local function apply_explorer_theme()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local panel_bg = normal.bg and string.format("#%06X", normal.bg) or "#292A30"

  set({
    "SnacksPicker",
    "SnacksPickerList",
    "SnacksPickerBox",
    "SnacksPickerInput",
    "SnacksPickerPreview",
  }, { bg = panel_bg })

  set({ "SnacksPickerListCursorLine" }, { bg = "#2C4A6E" }) -- Xcode nav selection (blue)
  set({ "SnacksPickerTree" }, { fg = "#4A5563" }) -- dim tree guides
  set({ "SnacksPickerDir" }, { fg = "#7F8489" }) -- dim path segments
  set({ "SnacksPickerFile", "SnacksPickerDirectory" }, { fg = "#DFDFE0" }) -- file text
  set({ "SnacksPickerMatch" }, { fg = "#5DD8FF", bold = true }) -- fuzzy match
  set({ "SnacksPickerSelected" }, { fg = "#FC5FA3" }) -- multi-select marker

  -- Also style the classic Directory group used by netrw / other trees.
  set({ "Directory" }, { fg = "#DFDFE0" })
end

local function apply_xcode_semantics()
  -- ---- LSP semantic tokens (exact Xcode behaviour when sourcekit is attached) ----

  -- Declarations: `func doThing()`, `class Foo`, ... → blue
  set({
    "@lsp.typemod.function.declaration",
    "@lsp.typemod.method.declaration",
    "@lsp.typemod.class.declaration",
    "@lsp.typemod.struct.declaration",
    "@lsp.typemod.enum.declaration",
    "@lsp.typemod.protocol.declaration",
    "@lsp.typemod.type.declaration",
  }, { fg = xc.decl })

  -- Function / method CALLS in your code → green
  set({ "@lsp.type.function", "@lsp.type.method" }, { fg = xc.fn })
  -- ...from the SDK / stdlib → purple
  set({
    "@lsp.typemod.function.defaultLibrary",
    "@lsp.typemod.method.defaultLibrary",
  }, { fg = xc.fn_sdk })

  -- Type / class / enum USAGE → teal ; from SDK → light purple
  set({
    "@lsp.type.class",
    "@lsp.type.struct",
    "@lsp.type.enum",
    "@lsp.type.type",
    "@lsp.type.namespace",
  }, { fg = xc.type })
  set({
    "@lsp.typemod.class.defaultLibrary",
    "@lsp.typemod.struct.defaultLibrary",
    "@lsp.typemod.enum.defaultLibrary",
    "@lsp.typemod.type.defaultLibrary",
  }, { fg = xc.type_sdk })

  -- Instance properties / members → green ; from SDK → purple
  set({ "@lsp.type.property" }, { fg = xc.member })
  set({ "@lsp.typemod.property.defaultLibrary" }, { fg = xc.member_sdk })
  -- (local variables stay plain white, exactly like Xcode)

  -- Function parameters → blue (Xcode's declaration.other)
  set({
    "@lsp.type.parameter",
    "@lsp.typemod.parameter.declaration",
  }, { fg = xc.parameter })

  -- Enum cases / constants → green ; from SDK (.leading, .blue) → purple
  set({ "@lsp.type.enumMember" }, { fg = xc.enum_case })
  set({ "@lsp.typemod.enumMember.defaultLibrary" }, { fg = xc.enum_case_sdk })

  -- ---- Treesitter fallbacks (used before sourcekit attaches) ----
  set({ "@function", "@function.method", "@constructor" }, { fg = xc.decl })
  set({ "@function.call", "@function.method.call" }, { fg = xc.fn })
  set({ "@variable.parameter", "@parameter" }, { fg = xc.parameter })
  set({ "@constant", "@constant.macro", "@variable.member" }, { fg = xc.enum_case })
  set({ "@type", "@type.builtin" }, { fg = xc.type })
  set({ "@keyword", "@keyword.function", "@conditional", "@repeat" }, { fg = xc.keyword })
  set({ "@boolean", "@constant.builtin" }, { fg = xc.keyword }) -- true/false/nil
  set({ "@string" }, { fg = xc.string })
  set({ "@number", "@number.float" }, { fg = xc.number })
  set({ "@comment" }, { fg = xc.comment })
  set({ "@attribute", "@variable.builtin" }, { fg = xc.attribute })
  set({ "@macro", "@keyword.directive" }, { fg = xc.macro })

  -- Argument labels at call sites (`foo(with: x)`) are plain text in Xcode.
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  set({ "XcodeArgLabel" }, { fg = normal.fg })

  apply_explorer_theme()
end

-- sourcekit-lsp emits argument labels (`func f(person name: String)`,
-- `f(person: x)`) as plain `function` semantic tokens — the same type as a
-- real function call — so they'd get the green "call" color. Use Treesitter
-- to tell them apart and recolor: declaration labels → parameter blue,
-- call-site labels → plain text.
local function fix_swift_argument_labels(args)
  local token = args.data.token
  if token.type ~= "function" or next(token.modifiers) ~= nil then
    return
  end
  if vim.bo[args.buf].filetype ~= "swift" then
    return
  end
  local hl
  for _, cap in ipairs(vim.treesitter.get_captures_at_pos(args.buf, token.line, token.start_col)) do
    local c = cap.capture
    if c:find("^function") then
      return -- a real call/declaration — keep the LSP color
    elseif c == "variable.parameter" then
      hl = "@variable.parameter"
    elseif c == "variable.member" then
      hl = "XcodeArgLabel"
    end
  end
  if hl then
    -- 128 > default semantic-token priorities (125–127)
    vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, hl, { priority = 128 })
  end
end

return {
  -- Xcode-accurate colorschemes: xcodedark / xcodedarkhc / xcodewwdc / xcodelight
  {
    "arzg/vim-colors-xcode",
    lazy = false,
    priority = 1000,
    init = function()
      -- Reapply our semantic overrides every time the colorscheme loads,
      -- so they survive `:colorscheme` reloads and lazy loading order.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "xcode*",
        callback = apply_xcode_semantics,
      })
      vim.api.nvim_create_autocmd("LspTokenUpdate", {
        group = vim.api.nvim_create_augroup("xcode_swift_arg_labels", { clear = true }),
        callback = fix_swift_argument_labels,
      })
    end,
  },

  -- Make it LazyVim's active theme.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "xcodedark",
    },
  },
}
