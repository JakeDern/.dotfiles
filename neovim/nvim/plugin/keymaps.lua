vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down one" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up one" })

vim.keymap.set("n", "Y", "yg$")

vim.keymap.set("v", "<leader>y", "\",+y")
vim.keymap.set("n", "<leader>y", "\",+y")
vim.keymap.set("n", "<leader>Y", "\",+Y")

-- IF YOU HAVEN'T NOTICED THESE GONE, DELETE THEM
-- vim.keymap.set("n", "<leader>d", "\",_d")
-- vim.keymap.set("v", "<leader>d", "\",_d")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>w", vim.cmd.Ex)

vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader>X", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Remap split window right and down
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })
