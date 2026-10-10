local function vsc(lhs, cmd, mode)
  vim.keymap.set(mode or 'n', lhs, function() vim.fn.VSCodeNotify(cmd) end, { silent = true })
end

vsc('gd', 'editor.action.revealDefinition')
vsc('K',  'editor.action.showHover')
vsc('<leader>vws', 'workbench.action.showAllSymbols')
vsc('<leader>vca', 'editor.action.quickFix')
vsc('<leader>vrr', 'editor.action.referenceSearch.trigger')
vsc('<leader>vrn', 'editor.action.rename')

vsc('<leader>h', 'workbench.action.moveActiveEditorGroupLeft')
vsc('<leader>j', 'workbench.action.moveActiveEditorGroupDown')
vsc('<leader>k', 'workbench.action.moveActiveEditorGroupUp')
vsc('<leader>l', 'workbench.action.moveActiveEditorGroupRight')

vsc(']d', 'editor.action.marker.next')

vim.keymap.set('n', '[d', function()
        vim.cmd.normal({ args = { 'b' } })
        vim.cmd.normal({ args = { 'h' } })
        vim.fn.VSCodeNotify('editor.action.marker.prev')
        vim.fn.VSCodeNotify('closeMarkersNavigation')
    end, { silent = true })
vim.keymap.set('n', ']d', function()
        vim.cmd.normal({ args = { 'w' } })
        vim.cmd.normal({ args = { 'l' } })
        vim.fn.VSCodeNotify('editor.action.marker.next') -- idee du k
        vim.fn.VSCodeNotify('closeMarkersNavigation')
    end, { silent = true })
