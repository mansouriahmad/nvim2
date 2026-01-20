return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    {
      "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
      opts = {},
    },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "gemini",
        },
        inline = {
          adapter = "gemini",
        },
        agent = {
          adapter = "gemini",
        },
      },
      adapters = {
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "GEMINI_API_KEY", -- Set this in your environment or shell config
            },
            schema = {
              model = {
                default = "gemini-2.0-flash-thinking-exp", -- Latest: gemini-2.0-flash-thinking-exp, gemini-2.0-flash-exp, or gemini-1.5-pro
              },
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            layout = "vertical", -- vertical|horizontal|float|buffer
            width = 0.5,
            height = 0.5,
            relative = "editor",
            border = "rounded",
            position = "right",
          },
          show_settings = true, -- Show model settings in chat buffer
          show_token_count = true, -- Show token count in chat buffer
        },
        diff = {
          provider = "mini_diff", -- default|mini_diff
        },
      },
      opts = {
        log_level = "ERROR", -- TRACE|DEBUG|ERROR|INFO
        send_code = true, -- Send code context to the LLM
        use_default_actions = true, -- Use default actions
        use_default_prompt_library = true, -- Use default prompt library
      },
      prompt_library = {
        ["Custom Prompt"] = {
          strategy = "chat",
          description = "Create a custom prompt",
          opts = {
            index = 1,
            is_default = true,
            is_slash_cmd = false,
            user_prompt = true,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert programmer assistant.",
            },
          },
        },
        ["Code Review"] = {
          strategy = "chat",
          description = "Review the selected code",
          opts = {
            modes = { "v" },
            short_name = "review",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = [[You are an expert code reviewer. Review the provided code for:
- Potential bugs and errors
- Performance issues
- Security vulnerabilities
- Code style and best practices
- Suggestions for improvement]],
            },
            {
              role = "user",
              content = function(context)
                return "Please review this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
              end,
            },
          },
        },
        ["Explain Code"] = {
          strategy = "chat",
          description = "Explain the selected code",
          opts = {
            modes = { "v" },
            short_name = "explain",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert programmer. Explain code in a clear and concise way.",
            },
            {
              role = "user",
              content = function(context)
                return "Please explain this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
              end,
            },
          },
        },
        ["Generate Tests"] = {
          strategy = "chat",
          description = "Generate tests for the selected code",
          opts = {
            modes = { "v" },
            short_name = "tests",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert at writing comprehensive test cases.",
            },
            {
              role = "user",
              content = function(context)
                return "Please generate comprehensive tests for this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
              end,
            },
          },
        },
        ["Fix Code"] = {
          strategy = "chat",
          description = "Fix issues in the selected code",
          opts = {
            modes = { "v" },
            short_name = "fix",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert at debugging and fixing code issues.",
            },
            {
              role = "user",
              content = function(context)
                return "Please identify and fix any issues in this code:\n\n```" .. context.filetype .. "\n" .. context.selection .. "\n```"
              end,
            },
          },
        },
      },
    })
  end,
  keys = {
    -- Chat commands
    {
      "<leader>ia",
      "<cmd>CodeCompanionActions<cr>",
      mode = { "n", "v" },
      desc = "CodeCompanion - Actions",
    },
    {
      "<leader>ic",
      "<cmd>CodeCompanionChat Toggle<cr>",
      mode = { "n", "v" },
      desc = "CodeCompanion - Toggle chat",
    },
    {
      "<leader>iq",
      function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          vim.cmd("CodeCompanionChat " .. input)
        end
      end,
      desc = "CodeCompanion - Quick chat",
    },
    {
      "<leader>ip",
      "<cmd>CodeCompanion<cr>",
      mode = { "n", "v" },
      desc = "CodeCompanion - Open prompt library",
    },
    -- Inline commands
    {
      "<leader>ii",
      "<cmd>CodeCompanionChat Add<cr>",
      mode = "v",
      desc = "CodeCompanion - Add to chat",
    },
    -- Quick actions (with visual selection)
    {
      "<leader>ie",
      function()
        vim.cmd("CodeCompanionChat Explain Code")
      end,
      mode = "v",
      desc = "CodeCompanion - Explain code",
    },
    {
      "<leader>ir",
      function()
        vim.cmd("CodeCompanionChat Code Review")
      end,
      mode = "v",
      desc = "CodeCompanion - Review code",
    },
    {
      "<leader>if",
      function()
        vim.cmd("CodeCompanionChat Fix Code")
      end,
      mode = "v",
      desc = "CodeCompanion - Fix code",
    },
    {
      "<leader>it",
      function()
        vim.cmd("CodeCompanionChat Generate Tests")
      end,
      mode = "v",
      desc = "CodeCompanion - Generate tests",
    },
  },
}
