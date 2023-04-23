
vim.keymap.set("n", "<leader>pp", "<cmd>call VSCodeNotifyVisual('workbench.action.showCommands', 1)<CR>")
vim.keymap.set("n", "<leader>w", "<cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>")
vim.keymap.set("n", "<leader>g", "<cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
vim.keymap.set("n", "<leader>ps", "<cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>")
vim.keymap.set("n", "<leader>pr", "<cmd>call VSCodeNotify('workbench.action.replaceInFiles')<CR>")

vim.keymap.set("n", "<C-h>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex1')<CR>")
vim.keymap.set("n", "<C-j>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex2')<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex3')<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex4')<CR>")

vim.keymap.set("n", "<leader>fk", "<cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
vim.keymap.set("n", "<leader>fj", "<cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")