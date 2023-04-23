local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

-- Always import common
require("common")

-- Check for vscode mode and only setup packer
-- if we're in normal nvim
if vim.g.vscode then
    require("vscode_lua")
else
    require("normal")
    ensure_packer()
end
