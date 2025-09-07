return {
  'nvim-telescope/telescope.nvim',
  --keys = {
  --  {"<leader>sfkVjj", "<cmd>Telescope find_files<cr>"},
  -- {"<leader>sg", "<cmd>Telescope live_grep<cr>"},

  --},
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sg', builtin.live_grep)
    vim.keymap.set('n', '<leader>sf', builtin.find_files) 

  end
}
