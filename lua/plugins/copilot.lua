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
        copilot_node_command = "node", -- Node.js version must be > 18.x
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

      -- Agent-like experience settings
      question_header = '## User ',
      answer_header = '## Copilot ',
      error_header = '## Error ',

      prompts = {
        Explain = {
          prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
        },
        Review = {
          prompt = '/COPILOT_REVIEW Review the selected code.',
        },
        Fix = {
          prompt = '/COPILOT_FIX There is a problem in this code. Rewrite the code to show it with the bug fixed.',
        },
        Optimize = {
          prompt = '/COPILOT_REFACTOR Optimize the selected code to improve performance and readability.',
        },
        Docs = {
          prompt = '/COPILOT_DOCS Please add documentation comment for the selection.',
        },
        Tests = {
          prompt = '/COPILOT_TESTS Please generate tests for my code.',
        },
        FixDiagnostic = {
          prompt = 'Please assist with the following diagnostic issue in file:',
          selection = function(source)
            return require('CopilotChat.select').diagnostics(source)
          end,
        },
        Commit = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          selection = function(source)
            return require('CopilotChat.select').gitdiff(source)
          end,
        },
        CommitStaged = {
          prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          selection = function(source)
            return require('CopilotChat.select').gitdiff(source, true)
          end,
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
      local select = require("CopilotChat.select")

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
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
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
