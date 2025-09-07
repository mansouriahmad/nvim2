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
        preview = {
          filesize_limit = 0.1, -- MB
          timeout = 250, -- ms
        },
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            preview_width = 0.6,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<CR>"] = "select_default",
            ["<C-u>"] = "preview_scrolling_up",
            ["<C-d>"] = "preview_scrolling_down",
          },
          n = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<CR>"] = "select_default",
            ["<C-u>"] = "preview_scrolling_up",
            ["<C-d>"] = "preview_scrolling_down",
          },
        },
      },
      pickers = {
        live_grep = {
          -- Uses default center popup style
        },
        grep_string = {
          -- Uses default center popup style
        },
        find_files = {
          -- Uses default center popup style
        },
      },
    })
    
    require("telescope").load_extension("ui-select")
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sg', builtin.live_grep)
    vim.keymap.set('n', '<leader>sf', builtin.find_files)
    
    -- ============================================
    -- THEME SWITCHER WITH REAL-TIME PREVIEW 
    -- ============================================
    
    -- Main theme switcher with live preview (like NvChad)
    vim.keymap.set('n', '<leader>th', function()
      builtin.colorscheme({
        enable_preview = true,  -- This enables real-time preview as you navigate!
      })
    end, { desc = '[T]heme selector with live preview' })

    -- Quick theme cycling through your favorites
    local favorite_themes = {
      'everforest',
      'gruvbox',
      'tokyonight',
      'tokyonight-night',
      'tokyonight-storm',
      'tokyonight-day',
      'tokyonight-moon',
      'github_dark',
      'github_dark_default',
      'github_dark_dimmed',
      'github_light',
      'github_light_default',
      'rose-pine',
      'catppuccin',
    }
    
    local current_theme_index = 1
    
    -- Cycle to next theme with notification
    vim.keymap.set('n', '<leader>tn', function()
      current_theme_index = current_theme_index % #favorite_themes + 1
      local theme = favorite_themes[current_theme_index]
      vim.cmd.colorscheme(theme)
      vim.notify('Theme: ' .. theme, vim.log.levels.INFO)
    end, { desc = 'Cycle to [N]ext theme' })
    
    -- Show only favorite themes
    vim.keymap.set('n', '<leader>tf', function()
      builtin.colorscheme({
        enable_preview = true,
        -- Filter to show only your installed/favorite themes
        -- This function will be called for each available colorscheme
        filter = function(colorscheme_name)
          for _, theme in ipairs(favorite_themes) do
            if colorscheme_name == theme then
              return true
            end
          end
          return false
        end,
      })
    end, { desc = '[T]heme selector ([F]avorites only)' })

    -- Optional: Save theme selection persistently
    local function save_theme_selection(theme_name)
      local config_dir = vim.fn.stdpath('config')
      local theme_file = config_dir .. '/lua/selected-theme.lua'
      local file = io.open(theme_file, 'w')
      if file then
        file:write(string.format("-- Auto-generated theme selection\nvim.cmd.colorscheme('%s')\n", theme_name))
        file:close()
      end
    end

    -- Auto-save theme when changed
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function(args)
        -- Uncomment the next line if you want to persist theme selection
        save_theme_selection(args.match)
      end,
    })
  end
}
