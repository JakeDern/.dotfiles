-- Map leader first thing
print("Root init.lua")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Make sure plugin manager is available, second thing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("common")

-- Check for vscode mode and only setup packer
-- if we're in normal nvim
if vim.g.vscode then
  require("vscode_lua")
else
  require("normal")
end

