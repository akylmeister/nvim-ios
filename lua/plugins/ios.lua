-- iOS / Swift development for LazyVim
--
-- External tools (install via Homebrew / Xcode):
--   xcode-build-server  -> makes sourcekit-lsp understand .xcodeproj/.xcworkspace
--   xcbeautify          -> prettifies xcodebuild logs
--   swiftformat         -> formatting (conform)
--   swiftlint           -> linting (nvim-lint)
--   sourcekit-lsp       -> ships with Xcode (no Mason needed)
--   xcodeproj (gem)     -> project file management
--
-- After opening a project run `:XcodebuildSetup`, then `:XcodebuildPicker`
-- (or <leader>X) for all build / run / test / device actions.

return {
  -- 1. Swift / Objective-C LSP via sourcekit-lsp (ships with Xcode, no Mason).
  --    nvim-lspconfig already ships a correct `lsp/sourcekit.lua` for Neovim
  --    0.11 (root markers: buildServer.json, .bsp, *.xcodeproj, *.xcworkspace,
  --    Package.swift, .git). We just enable it — do NOT override root_dir with
  --    the old `function(fname)` signature, that breaks project-root detection.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {},
      },
    },
  },

  -- 2. Treesitter: Swift parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "swift" })
    end,
  },

  -- 3. Formatting: swiftformat via conform.nvim (LazyVim's formatter)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- 4. Linting: swiftlint via nvim-lint (LazyVim's linter)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },

  -- 5. The iOS workhorse: build / run / test on simulators & devices,
  --    test explorer, code coverage, SwiftUI previews, debugging.
  --    Xcode 16+ debugs via the built-in lldb-dap, so no codelldb needed.
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim", -- picker + SwiftUI/snapshot previews (LazyVim default)
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    ft = { "swift", "objc", "objcpp" },
    cmd = {
      "XcodebuildSetup",
      "XcodebuildPicker",
      "XcodebuildBuild",
      "XcodebuildBuildRun",
      "XcodebuildTest",
      "XcodebuildSelectDevice",
    },
    config = function()
      require("xcodebuild").setup({
        integrations = {
          -- Auto-run `xcode-build-server config` when the scheme changes, so
          -- sourcekit-lsp always has a fresh buildServer.json. Essential for
          -- Tuist, where `tuist generate` recreates the .xcodeproj/.xcworkspace.
          xcode_build_server = {
            enabled = true,
            guess_scheme = true, -- match the scheme to the current file's target
          },
        },
      })

      -- Enable nvim-dap debugging (Xcode 16+ uses the built-in lldb-dap).
      require("xcodebuild.integrations.dap").setup()

      -- Auto open/close the dap-ui panels around a debug session.
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
    keys = {
      { "<leader>X", "<cmd>XcodebuildPicker<cr>", desc = "Xcodebuild Actions" },
      { "<leader>xf", "<cmd>XcodebuildProjectManager<cr>", desc = "Project Manager" },

      { "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Build Project" },
      { "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", desc = "Build For Testing" },
      { "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },

      { "<leader>xt", "<cmd>XcodebuildTest<cr>", desc = "Run Tests" },
      { "<leader>xt", "<cmd>XcodebuildTestSelected<cr>", mode = "v", desc = "Run Selected Tests" },
      { "<leader>xT", "<cmd>XcodebuildTestClass<cr>", desc = "Run Current Test Class" },
      { "<leader>x.", "<cmd>XcodebuildTestRepeat<cr>", desc = "Repeat Last Test Run" },
      { "<leader>xe", "<cmd>XcodebuildTestExplorerToggle<cr>", desc = "Toggle Test Explorer" },
      { "<leader>xs", "<cmd>XcodebuildFailingSnapshots<cr>", desc = "Failing Snapshots" },

      { "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Logs" },
      { "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Code Coverage" },
      { "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", desc = "Code Coverage Report" },

      { "<leader>xp", "<cmd>XcodebuildPreviewGenerateAndShow<cr>", desc = "Generate SwiftUI Preview" },
      { "<leader>x<cr>", "<cmd>XcodebuildPreviewToggle<cr>", desc = "Toggle Preview" },

      { "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
      { "<leader>xa", "<cmd>XcodebuildCodeActions<cr>", desc = "Show Code Actions" },

      -- Debugging (nvim-dap driven by xcodebuild)
      { "<leader>d;", function() require("xcodebuild.integrations.dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>d:", function() require("xcodebuild.integrations.dap").toggle_message_breakpoint() end, desc = "Message Breakpoint" },
      { "<leader>dd", "<cmd>XcodebuildBuildDebug<cr>", desc = "Build & Debug" },
      { "<leader>dr", "<cmd>XcodebuildDebug<cr>", desc = "Debug (no build)" },
      { "<leader>dt", function() require("xcodebuild.integrations.dap").debug_tests() end, desc = "Debug Tests" },
      { "<leader>dx", function() require("xcodebuild.integrations.dap").terminate_session() end, desc = "Terminate Debug" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle Debug UI" },
    },
  },
}
