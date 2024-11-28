local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { { 'prettierd', "prettier" } },
    typescript = { 'prettierd', "prettier", stop_after_first = true },
    typescriptreact = { 'prettierd', "prettier", stop_after_first = true },
    json = { 'prettierd', "prettier", stop_after_first = true },
    html = { 'prettierd', "prettier", stop_after_first = true },
    css = { 'prettierd', "prettier", stop_after_first = true },
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    conform.format({ bufnr = args.buf })
  end,
})
