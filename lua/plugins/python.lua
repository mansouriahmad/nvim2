return {
  {
    "linux-cultist/venv-selector.nvim",
    branch = "main",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    cmd = "VenvSelect",
    ft = "python",
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>", desc = "Select Python Venv" },
      { "<leader>pV", "<cmd>VenvSelectCached<cr>", desc = "Show Cached Venv" },
    },
    opts = {
      auto_refresh = false,
      search = true,
      name = { "venv", ".venv", "env", ".env" },
      anaconda_base_path = "/data/miniconda3",
      anaconda_envs_path = "/data/miniconda3/envs",
      dap_enabled = true,
      notify_user_on_venv_activation = true,
    },
  },
}
