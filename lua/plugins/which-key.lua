return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function()
    local wk = require("which-key")
    
    wk.setup({
      preset = "modern",
      delay = 500, -- delay before showing which-key popup (ms)
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
          enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true, -- adds help for operators like d, y, ...
          motions = true, -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
      },
      win = {
        border = "rounded",
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      },
      layout = {
        spacing = 6, -- spacing between columns
      },
      show_help = true, -- show a help message in the command line for using WhichKey
      show_keys = true, -- show the currently pressed key and its label as a message in the command line
    })

    -- Define key groups for better organization
    wk.add({
      { "<leader>f", group = "file/find" },
      { "<leader>s", group = "search" },
      { "<leader>g", group = "git" },
      { "<leader>l", group = "lsp" },
      { "<leader>w", group = "workspace" },
      { "<leader>d", group = "diagnostics" },
      { "<leader>c", group = "code" },
      { "<leader>r", group = "rename/refactor" },
    })

    -- LSP-specific keymaps (these will show when LSP is attached)
    wk.add({
      { "g", group = "goto" },
      { "gd", desc = "Go to definition" },
      { "gD", desc = "Go to declaration" },
      { "gi", desc = "Go to implementation" },
      { "gr", desc = "Go to references" },
      { "K", desc = "Hover documentation" },
      { "<leader>ca", desc = "Code actions" },
      { "<leader>rn", desc = "Rename symbol" },
      { "<leader>f", desc = "Format code" },
      { "<leader>d", desc = "Show diagnostics" },
      { "<leader>D", desc = "Type definition" },
      { "<leader>wd", desc = "Workspace diagnostics" },
      { "<leader>wD", desc = "Open workspace diagnostics list" },
    })

    -- Telescope keymaps
    wk.add({
      { "<leader>sf", desc = "Find files" },
      { "<leader>sg", desc = "Live grep" },
    })
  end,
}
