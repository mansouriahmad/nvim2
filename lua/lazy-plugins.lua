local plugins = {
  require('plugins.colorschemes'),
  require('plugins.treesitter'),
  require('plugins.nvim-tree'),
  require('plugins.telescope'),
  require('plugins.lsp'),
  require('plugins.vim-tmux-navigator'),
  require('plugins.blink'),
  require('plugins.conform'),
  require('plugins.autopairs'),
  require('plugins.trouble'),
  require('plugins.misc'),
  require('plugins.lualine')
}

local opts = {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    --icons =  {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  }
}
require("lazy").setup(plugins, opts);
