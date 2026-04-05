local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
    return
end

configs.setup {
    ensure_installed = { "javascript", "typescript", "tsx", "html", "css" }, -- Add other languages as needed
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    }
}
