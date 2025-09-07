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
              checkOnSave = {
                command = "clippy",
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer" },
        automatic_installation = true,
      })

      for server, config in pairs(opts.servers) do
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.diagnostic.config({
        --virtual_text = true,
        virtual_lines = true,
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
                return vim.fn.systemlist("find . -name '*.rs' -o -name '*.lua' -o -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.tsx' | head -1000")
              end
            })
            -- Auto-populate workspace diagnostics when LSP attaches
            require("workspace-diagnostics").populate_workspace_diagnostics(client, ev.buf)
          end

          -- Buffer local mappings
          local opts = { buffer = ev.buf }

          -- Navigation
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = 'Go to declaration' })
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = 'Go to definition' })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = ev.buf, desc = 'Go to implementation' })
          vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition,
            { buffer = ev.buf, desc = 'Go to type definition' })
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename buffer' })
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code actions' })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = ev.buf, desc = 'Go to references' })

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

          -- Workspace diagnostics keymap
          vim.keymap.set("n", "<leader>wD", function()
            vim.cmd("lopen")
          end, { buffer = ev.buf, desc = 'Open workspace diagnostics location list' })
        end,
      })
    end
  }
}
