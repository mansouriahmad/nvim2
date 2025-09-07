return {
  'nvim-telescope/telescope.nvim',
  --keys = {
  --  {"<leader>sfkVjj", "<cmd>Telescope find_files<cr>"},
  -- {"<leader>sg", "<cmd>Telescope live_grep<cr>"},

  --},
  tag = '0.1.8',
  lazy = false,
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' },
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<CR>"] = "select_default",
          },
          n = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<CR>"] = "select_default",
          },
        },
      },
    })
    
    require("telescope").load_extension("ui-select")
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sg', builtin.live_grep)
    vim.keymap.set('n', '<leader>sf', builtin.find_files)
  end
}
