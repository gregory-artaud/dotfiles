local ok, gitblame = pcall(require, 'gitblame')
if not ok then
    return
end

gitblame.setup {
    enabled = true,
    message_template = "\t\t<author>, <date> • <summary>",
    date_format = "%r",
}
