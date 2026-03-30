-- Map leader first thing
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.shell = "zsh"

-- Colorscheme
vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
})
require("tokyonight.colors").setup()
vim.cmd([[colorscheme tokyonight]])
