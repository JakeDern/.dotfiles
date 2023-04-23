function ApplyColors()
	vim.g.everforest_background = 'soft'
	vim.cmd.colorscheme("everforest")

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

if vim.g.vscode then
    ApplyColors()
end


