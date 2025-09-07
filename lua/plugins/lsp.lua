return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig"
    },
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = {"lua_ls", "rust_analyzer"},
        automatic_installation = true,
      })

      -- Configure diagnostics to show immediately
      vim.diagnostic.config({
        virtual_text = {
          enabled = true,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Override the default publish_diagnostics handler for immediate display
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          -- Enable underline, use virtual text for errors only
          underline = true,
          virtual_text = {
            spacing = 2,
            prefix = "●",
          },
          signs = true,
          update_in_insert = false,
        }
      )

      -- Force diagnostics to show immediately when opening files
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.rs",
        callback = function(args)
          local bufnr = args.buf
          -- Wait for LSP to attach, then request diagnostics
          vim.defer_fn(function()
            local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
            for _, client in ipairs(clients) do
              if client.name == "rust_analyzer" then
                -- Request diagnostics from rust-analyzer
                vim.lsp.buf_request(bufnr, "textDocument/diagnostic", {
                  textDocument = vim.lsp.util.make_text_document_params(bufnr)
                })
                break
              end
            end
          end, 1500)
        end,
      })

      -- Common on_attach function
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        
        -- Force immediate diagnostic request when LSP attaches
        if client.name == "rust_analyzer" then
          vim.defer_fn(function()
            vim.lsp.buf_request(bufnr, "textDocument/diagnostic", {
              textDocument = vim.lsp.util.make_text_document_params(bufnr)
            })
          end, 500)
        end
      end

      -- LSP server configurations
      local lspconfig = require("lspconfig")
      
      -- Configure rust-analyzer
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_dir = lspconfig.util.root_pattern("Cargo.toml", "rust-project.json"),
        settings = {
          ["rust-analyzer"] = {
            -- Enable immediate diagnostics
            diagnostics = {
              enable = true,
              experimental = {
                enable = true,
              },
            },
            -- Enable cargo check without save requirement
            cargo = {
              buildScripts = {
                enable = true,
              },
              features = "all",
            },
            -- Disable checkOnSave and enable real-time checking
            checkOnSave = false,
            -- Enable proc macros
            procMacro = {
              enable = true,
            },
          },
        },
        -- Reduce debounce for faster feedback
        flags = {
          debounce_text_changes = 50,
        },
      })

      -- Configure Lua LSP
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = {"vim"},
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end
  }
}
