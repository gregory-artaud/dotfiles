local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()
local IN_VSCODE = vim.g.vscode ~= nil

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- OK dans VS Code
  use { 'nvim-telescope/telescope.nvim', tag = '0.1.x', requires = { { 'nvim-lua/plenary.nvim' } } }
  use 'folke/tokyonight.nvim'
  use 'tpope/vim-fugitive'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- ❌ Désactiver sous VS Code (conflits / sans effet utile)
  if not IN_VSCODE then
    use {
      'windwp/nvim-ts-autotag',
      requires = { 'nvim-treesitter/nvim-treesitter' },
      config = function() require('nvim-ts-autotag').setup() end
    }

    use { "nvimtools/none-ls.nvim", requires = { "nvim-lua/plenary.nvim" } }

    use { "windwp/nvim-autopairs", config = function() require("nvim-autopairs").setup {} end }

    use { 'neovim/nvim-lspconfig' }
    use {
      'williamboman/mason.nvim',
      run = function() pcall(vim.cmd, 'MasonUpdate') end,
    }
    use { 'williamboman/mason-lspconfig.nvim' }

    -- Autocomplétion
    use { 'hrsh7th/nvim-cmp' }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-path' }
    use { 'saadparwaiz1/cmp_luasnip' }
    use { 'hrsh7th/cmp-nvim-lua' }

    -- Snippets
    use { 'L3MON4D3/LuaSnip' }
    use { 'rafamadriz/friendly-snippets' }
  end

  if packer_bootstrap then require('packer').sync() end
end)
