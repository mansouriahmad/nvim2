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
      delay = 500,          -- delay before showing which-key popup (ms)
      plugins = {
        marks = true,       -- shows a list of your marks on ' and `
        registers = true,   -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        spelling = {
          enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
          suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
          operators = true,    -- adds help for operators like d, y, ...
          motions = true,      -- adds help for motions
          text_objects = true, -- help for text objects triggered after entering an operator
          windows = true,      -- default bindings on <c-w>
          nav = true,          -- misc bindings to work with windows
          z = true,            -- bindings for folds, spelling and others prefixed with z
          g = true,            -- bindings for prefixed with g
        },
      },
      win = {
        border = "rounded",
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
      },
      layout = {
        spacing = 6,    -- spacing between columns
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
      { "<leader>t", group = "theme" },
      { "<leader>x", group = "trouble" },
      { "<leader>a", group = "actions" },
      { "<leader>j", group = "move" },
      { "<leader>k", group = "move" },
      { "<leader>m", group = "modify" },
      { "<leader>,", group = "toggle" },
    })

    -- Basic keymaps from keymaps.lua
    wk.add({
      { "<leader>e", desc = "Toggle NvimTree" },
      { "<leader>a", desc = "Save all files" },
      { "<leader>j", desc = "Move line down" },
      { "<leader>k", desc = "Move line up" },
      { "<leader>m", desc = "Delete until next _" },
      { "<leader>,", desc = "Toggle list mode" },
      { "H",         desc = "Go to beginning of line" },
      { "L",         desc = "Go to end of line" },
      { "<left>",    desc = "Previous buffer" },
      { "<right>",   desc = "Next buffer" },
      { "<C-p>",     desc = "Files (fzf)" },
      { "<F1>",      desc = "Escape" },
    })

    -- LSP-specific keymaps (these will show when LSP is attached)
    wk.add({
      { "g",          group = "goto" },
      { "gd",         desc = "Go to definition" },
      { "gD",         desc = "Go to declaration" },
      { "gi",         desc = "Go to implementation" },
      { "gr",         desc = "Go to references" },
      { "K",          desc = "Hover documentation" },
      { "<leader>ca", desc = "Code actions" },
      { "<leader>rn", desc = "Rename symbol" },
      { "<leader>f",  desc = "Format code" },
      { "<leader>d",  desc = "Open float diagnostic" },
      { "<leader>D",  desc = "Go to type definition" },
      { "<leader>ls", desc = "Document symbols" },
      { "<leader>lw", desc = "Workspace symbols" },
    })

    -- Telescope keymaps
    wk.add({
      { "<leader>sf", desc = "Find files" },
      { "<leader>sg", desc = "Live grep" },
      { "<leader>sh", desc = "Help tags" },
      { "<leader>sk", desc = "Keymaps" },
      { "<leader>sF", desc = "Filetypes" },
      { "<leader>sn", desc = "Find Neovim config files" },
      { "<leader>egS", desc = "Enhanced Git Status with Telescope" },
      { "<leader>th", desc = "Theme selector with live preview" },
      { "<leader>tn", desc = "Cycle to next theme" },
      { "<leader>tf", desc = "Theme selector (favorites only)" },
    })

    -- Git/Fugitive keymaps
    wk.add({
      { "<leader>gS",   desc = "Git Status (fugitive)" },
      { "<leader>gC",   desc = "Git Commit" },
      { "<leader>gP",   desc = "Git Push" },
      { "<leader>gL",   desc = "Git Pull" },
      { "<leader>gD",   desc = "Git Diff split" },
      { "<leader>gB",   desc = "Git Blame" },
      { "<leader>gBr",  desc = "Git Branch" },
      { "<leader>gCo",  desc = "Git Checkout" },
      { "<leader>gLog", desc = "Git Log" },
      { "<leader>gdf",  desc = "Git Diff all Files" },
      { "<leader>gdc",  desc = "Git Diff Cached files" },
      { "<leader>gdh",  desc = "Git Diff vs HEAD" },
      { "<leader>gdm",  desc = "Git Diff vs Main branch" },
      { "<leader>gcc",  desc = "Git Commit with Custom message" },
      { "<leader>gM",   desc = "Git Merge" },
      { "<leader>gR",   desc = "Git Rebase" },
      { "<leader>gSt",  desc = "Git Stash" },
      { "<leader>gSp",  desc = "Git Stash Pop" },
      { "<leader>gSl",  desc = "Git Stash List" },
      { "<leader>gV",   desc = "Open diff split (VS Code-like diff)" },
      { "<leader>gH",   desc = "File history" },
      { "<leader>ga",   desc = "Stage all files" },
      { "<leader>gu",   desc = "Unstage all files" },
      { "<leader>gA",   desc = "Stage current file" },
      { "<leader>gU",   desc = "Unstage current file" },
    })

    -- Trouble keymaps
    wk.add({
      { "<leader>xx", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", desc = "Symbols (Trouble)" },
      { "<leader>cl", desc = "LSP Definitions / references / ... (Trouble)" },
      { "<leader>xL", desc = "Location List (Trouble)" },
      { "<leader>xQ", desc = "Quickfix List (Trouble)" },
    })

    -- Visual mode keymaps
    wk.add({
      { "p",         desc = "Paste without yanking" },
      { "<leader>j", desc = "Move selection down" },
      { "<leader>k", desc = "Move selection up" },
    })

    -- Search keymaps
    wk.add({
      { "n",  desc = "Next search result (centered)" },
      { "N",  desc = "Previous search result (centered)" },
      { "*",  desc = "Search word under cursor (centered)" },
      { "#",  desc = "Search word under cursor backwards (centered)" },
      { "g*", desc = "Search word under cursor (partial match, centered)" },
    })
  end,
}
