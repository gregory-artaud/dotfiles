local lsp = require('lsp-zero')
local null_ls = require('null-ls')
local lspconfig = require('lspconfig')

lsp.preset('recommended')

lsp.ensure_installed({
	'ts_ls',
	'eslint',
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	['<C-y>'] = cmp.mapping.confirm({ select = true }),
	['<C-Space>'] = cmp.mapping.complete(),
})

lsp.set_preferences({
	sign_icons = { }
})

lsp.setup_nvim_cmp({
	mapping = cmp_mappings
})

lsp.on_attach(function(client, bufnr)
	local opts = {buffer = bufnr, remap = false}

	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.configure('ts_ls', {
    root_dir = lspconfig.util.root_pattern("package.json"),
    single_file_support = false,
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
    end,
})

lsp.configure('eslint', {
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
    end,
})

lsp.configure('dprint', {
    on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
    end,
})

lsp.setup()

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      command = "npx",
      args = { "prettier", "--stdin-filepath", "$FILENAME" },
    }),
  },
})

vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format Code" })

