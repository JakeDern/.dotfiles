
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

    -- Git plugin from tpope 
    -- Doesn't seem to work in vscode out of box
	--use('tpope/vim-fugitive')

    --  For surrounding text
    use('tpope/vim-surround')
end)
