vim.keymap.set("n", "<leader>w", vim.cmd.Ex)

vim.keymap.set("n", "<leader>u", ":UndertreeShow<CR>")

vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
end)
