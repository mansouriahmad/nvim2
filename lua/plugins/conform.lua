return {
  'stevearc/conform.nvim',
  opts = {},
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        -- Ruff handles both formatting and import sorting for Python
        python = { "ruff_format", "ruff_organize_imports" },
        -- You can customize some of the format options for the filetype (:help conform.format
        rust = { "rustfmt", lsp_format = "fallback" },
        -- C# formatting via LSP (OmniSharp handles formatting)
        cs = { lsp_format = "prefer" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    })
  end

}
