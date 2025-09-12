return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "artemave/workspace-diagnostics.nvim",
    },
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              check = {
                command = "clippy",
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
        ruff = {
          init_options = {
            settings = {
              -- Any extra CLI arguments for `ruff` go here.
              args = {},
            }
          }
        },
        omnisharp = {
          settings = {
            FormattingOptions = {
              -- Enables support for reading code style, naming convention and analyzer
              -- settings from .editorconfig.
              EnableEditorConfigSupport = true,
              -- Specifies whether 'using' directives should be grouped and sorted during
              -- document formatting.
              OrganizeImports = true,
            },
            MsBuild = {
              -- If true, MSBuild project system will only load projects for files that
              -- were opened in the editor. This setting is useful for big C# codebases
              -- and allows for faster initialization of code navigation features only
              -- for projects that are relevant to code that is being edited.
              LoadProjectsOnDemand = false,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "ruff", "omnisharp" },
        automatic_installation = true,
      })

      for server, config in pairs(opts.servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      -- Virtual lines toggle state
      local virtual_lines_enabled = false
      
      -- Function to toggle virtual lines
      local function toggle_virtual_lines()
        virtual_lines_enabled = not virtual_lines_enabled
        vim.diagnostic.config({
          virtual_lines = virtual_lines_enabled,
        })
      end

      vim.diagnostic.config({
        --virtual_text = true,
        virtual_lines = virtual_lines_enabled,
        --underline = true
      })

      -- Set up LSP keymaps using LspAttach autocommand (recommended approach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Setup workspace-diagnostics for this client
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            require("workspace-diagnostics").setup({
              workspace_files = function()
                -- Cross-platform file finding
                if vim.fn.has('win32') == 1 then
                  -- Windows PowerShell command
                  return vim.fn.systemlist(
                    'powershell -Command "Get-ChildItem -Recurse -Include *.rs,*.lua,*.py,*.js,*.ts,*.tsx | Select-Object -First 1000 | ForEach-Object { $_.FullName }"'
                  )
                else
                  -- Unix/Linux/macOS command
                  return vim.fn.systemlist(
                    "find . -name '*.rs' -o -name '*.lua' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' | head -1000"
                  )
                end
              end
            })
            -- Auto-populate workspace diagnostics when LSP attaches
            require("workspace-diagnostics").populate_workspace_diagnostics(client, ev.buf)
          end

          -- Navigation with Telescope (live preview)
          local telescope = require('telescope.builtin')
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Go to declaration' })
          vim.keymap.set("n", "gd", telescope.lsp_definitions, { buffer = ev.buf, desc = 'Go to definition' })
          vim.keymap.set("n", "gi", telescope.lsp_implementations, { buffer = ev.buf, desc = 'Go to implementation' })
          vim.keymap.set("n", "<leader>D", telescope.lsp_type_definitions,
            { buffer = ev.buf, desc = 'Go to type definition' })
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename buffer' })
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code actions' })
          vim.keymap.set("n", "gr", telescope.lsp_references, { buffer = ev.buf, desc = 'Go to references' })

          -- Additional LSP Telescope commands with live preview
          vim.keymap.set("n", "<leader>ls", telescope.lsp_document_symbols,
            { buffer = ev.buf, desc = 'Document symbols' })
          vim.keymap.set("n", "<leader>lw", telescope.lsp_workspace_symbols,
            { buffer = ev.buf, desc = 'Workspace symbols' })

          -- Documentation
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = 'Hover Documentation' })
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = ev.buf, desc = 'Format the source' })

          vim.keymap.set("n", "<leader>d", function()
            vim.diagnostic.open_float({
              border = "rounded",
            })
          end, { buffer = ev.buf, desc = 'Open float diagnostic' })

          -- Toggle virtual lines diagnostics
          vim.keymap.set("n", "<leader>vl", toggle_virtual_lines, { buffer = ev.buf, desc = 'Toggle virtual lines diagnostics' })
        end,
      })
    end
  }
}
