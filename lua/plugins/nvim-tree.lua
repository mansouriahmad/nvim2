return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function() 
    require("nvim-tree").setup {
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        
        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)
        
        -- Remove conflicting mappings if they exist
        pcall(vim.keymap.del, 'n', '<C-j>', { buffer = bufnr })
        pcall(vim.keymap.del, 'n', '<C-k>', { buffer = bufnr })
      end,
    }
  end 

}
