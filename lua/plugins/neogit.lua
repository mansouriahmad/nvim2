return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  keys = {
    { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit (Magit-like)" },
    { "<leader>gNc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
    { "<leader>gNp", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
    { "<leader>gNl", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
  },
  opts = {
    integrations = {
      telescope = true,
      diffview = true,
    },
    signs = {
      hunk = { "", "" },
      item = { "▸", "▾" },
      section = { "▸", "▾" },
    },
  },
}
