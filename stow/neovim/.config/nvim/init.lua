-- Map leader first thing
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.shell = "zsh"

-- Make sure plugin manager is available, second thing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
-- require("config")
require("lazy").setup("plugins", {})
