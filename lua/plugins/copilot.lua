return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = false, -- Manual trigger only, use Alt+\ to trigger
          debounce = 150, -- Delay before showing suggestions
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>",
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4,
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = true,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
          ["*"] = true, -- Enable for all other filetypes
        },
        copilot_node_command = "node", -- Node.js version must be v22+ for recent copilot.lua
        server_opts_overrides = {},
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = false, -- Enable debugging
      model = 'claude-sonnet-4.5', -- GPT-4, GPT-4o, o1-preview, o1-mini, claude-3.5-sonnet, or claude-sonnet-4.5
      temperature = 0.1,
      
      -- Enable agent mode - this is the key setting for tool calling
      agent = 'copilot',
      
      -- Additional context for better agent behavior
      context = 'buffer', -- Include current buffer content by default

      -- UX
      auto_insert_mode = true, -- Enter insert mode when opening chat

      -- Headers (modern config)
      headers = {
        user = '## User',
        assistant = '## Copilot',
        tool = '## Tool',
      },

      -- Keep prompt templates simple; rely on built-in prompts (Explain/Review/Fix/etc.)
      -- and add a dedicated "Change" prompt that encourages tool-calling edits.
      prompts = {
        Change = {
          prompt = '@copilot You are an expert coding agent with tool-calling abilities. Apply the requested change to the code. Use tools to make edits directly. Context: /COPILOT_GENERATE',
          description = "Apply requested change to code (uses agent mode)",
        },
        Agent = {
          prompt = '@copilot /COPILOT_GENERATE',
          description = "Agent mode with full tool access",
        },
      },

      -- Window configuration for agent-like experience
      window = {
        layout = 'vertical', -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.5, -- fractional width of parent, or absolute width in columns when > 1
        height = 0.5, -- fractional height of parent, or absolute height in rows when > 1
        -- Options for float layout
        relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
        border = 'rounded', -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
        row = nil, -- row position of the window, default is centered
        col = nil, -- column position of the window, default is centered
        title = 'Copilot Chat', -- title of chat window
        footer = nil, -- footer of chat window
        zindex = 1, -- determines if window is on top or below other floating windows
      },

      -- Mappings for agent interaction
      mappings = {
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<Tab>',
        },
        close = {
          normal = 'q',
          insert = '<C-c>',
        },
        reset = {
          normal = '<C-r>',
          insert = '<C-r>',
        },
        submit_prompt = {
          normal = '<CR>',
          insert = '<C-s>',
        },
        accept_diff = {
          normal = '<C-y>',
          insert = '<C-y>',
        },
        yank_diff = {
          normal = 'gy',
        },
        show_diff = {
          normal = 'gd',
        },
        show_info = {
          normal = 'gp',
        },
        show_context = {
          normal = 'gs',
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      -- Setup CopilotChat with options
      chat.setup(opts)

      -- Setup key mappings for agent-like workflow
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          -- Set local keymaps for chat buffer
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true
        end,
      })
    end,
    event = "VeryLazy",
    keys = {
      -- Quick chat
      {
        "<leader>aa",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").open()
            require("CopilotChat").ask("@copilot " .. input, {
              sticky = { "#buffer:active" },
            })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        "<leader>ax",
        function()
          local input = vim.fn.input("Change (applies to current file): ")
          if input ~= "" then
            require("CopilotChat").open()
            require("CopilotChat").ask("/Change\n#buffer:active\n" .. input, {
              -- Tools only become available when @copilot is used in the resolved prompt,
              -- which /Change includes.
            })
          end
        end,
        desc = "CopilotChat - Apply change to file",
      },
      {
        "<leader>ax",
        function()
          local input = vim.fn.input("Change (applies to selection): ")
          if input ~= "" then
            require("CopilotChat").open()
            require("CopilotChat").ask("/Change\n#selection\n" .. input)
          end
        end,
        mode = { "v" },
        desc = "CopilotChat - Apply change to selection",
      },
      -- Open chat
      {
        "<leader>ao",
        "<cmd>CopilotChatOpen<cr>",
        desc = "CopilotChat - Open chat window",
      },
      {
        "<leader>ac",
        "<cmd>CopilotChatClose<cr>",
        desc = "CopilotChat - Close chat window",
      },
      {
        "<leader>at",
        "<cmd>CopilotChatToggle<cr>",
        desc = "CopilotChat - Toggle chat window",
      },
      {
        "<leader>ar",
        "<cmd>CopilotChatReset<cr>",
        desc = "CopilotChat - Reset chat",
      },
      -- Code actions with visual selection
      {
        "<leader>ae",
        "<cmd>CopilotChatExplain<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Explain code",
      },
      {
        "<leader>aR",
        "<cmd>CopilotChatReview<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Review code",
      },
      {
        "<leader>af",
        "<cmd>CopilotChatFix<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Fix code",
      },
      {
        "<leader>aO",
        "<cmd>CopilotChatOptimize<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Optimize code",
      },
      {
        "<leader>ad",
        "<cmd>CopilotChatDocs<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Add docs",
      },
      {
        "<leader>aT",
        "<cmd>CopilotChatTests<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Generate tests",
      },
      {
        "<leader>aD",
        "<cmd>CopilotChatFixDiagnostic<cr>",
        desc = "CopilotChat - Fix diagnostic",
      },
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message",
      },
      {
        "<leader>aM",
        "<cmd>CopilotChatCommitStaged<cr>",
        desc = "CopilotChat - Generate commit message (staged)",
      },
      -- Custom prompts
      {
        "<leader>ap",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
        mode = { "n", "v" },
      },
    },
  },
}
