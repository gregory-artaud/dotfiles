require('nvim-treesitter').install({ 'javascript', 'typescript', 'tsx', 'html', 'css', 'markdown', 'markdown_inline' })

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('gartaud-treesitter', { clear = true }),
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'html', 'css', 'markdown' },
    callback = function(event) vim.treesitter.start(event.buf) end,
})
