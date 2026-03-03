return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
  keys = {
    { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Diff View Open" },
    { "<leader>gdH", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (Diffview)" },
    { "<leader>gdC", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    { "<leader>gdR", "<cmd>DiffviewFileHistory<cr>", desc = "Repo History (Diffview)" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_horizontal" },
      file_history = { layout = "diff2_horizontal" },
    },
    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 35 },
    },
  },
}
