if vim.g.vscode then
    return
end

local ok_mason, mason = pcall(require, 'mason')
if not ok_mason then
    return
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not ok_mason_lspconfig then
    return
end

local ok_null_ls, null_ls = pcall(require, 'null-ls')
if not ok_null_ls then
    return
end

local ok_cmp, cmp = pcall(require, 'cmp')
if not ok_cmp then
    return
end

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local ok_luasnip, luasnip = pcall(require, 'luasnip')
if not ok_luasnip then
    return
end

local ok_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if not ok_cmp_lsp then
    return
end

mason.setup()
mason_lspconfig.setup({
    ensure_installed = { 'ts_ls', 'eslint' },
})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
    }),
})

local capabilities = cmp_lsp.default_capabilities()

local function on_attach(_, bufnr)
    local opts = { buffer = bufnr, remap = false }

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
end

vim.lsp.config('*', {
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.diagnostic.config({
    signs = false,
})

vim.lsp.config('ts_ls', {
    root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, { 'package.json' })
        if root ~= nil then
            on_dir(root)
        end
    end,
    workspace_required = true,
})

vim.lsp.enable({ 'ts_ls', 'eslint' })

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier.with({
            command = "npx",
            args = { "prettier", "--stdin-filepath", "$FILENAME" },
        }),
    },
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
