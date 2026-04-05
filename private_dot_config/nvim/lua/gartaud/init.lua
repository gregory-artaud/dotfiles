local is_vscode = vim.g.vscode ~= nil

require('gartaud.remap')
require('gartaud.set')
require('gartaud.packer')

if is_vscode then
  require('gartaud.remap_vscode')
end

