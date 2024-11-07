vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    callback = function()
        vim.cmd("silent !deno fmt")
    end,
})
