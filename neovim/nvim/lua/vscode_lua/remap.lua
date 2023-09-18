-- Misc
-- Command Pallet
vim.keymap.set("n", "<leader>cp", "<cmd>call VSCodeNotify('workbench.action.showCommands')<CR>")
vim.keymap.set("n", "<leader><leader>", "<cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
vim.keymap.set("n", "<leader>ps", "<cmd>call VSCodeNotify('workbench.action.findInFiles')<CR>")
vim.keymap.set("n", "<leader>pr", "<cmd>call VSCodeNotify('workbench.action.replaceInFiles')<CR>")

-- Close window and close group
vim.keymap.set("n", "<leader>w", "<cmd>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>")
vim.keymap.set("n", "<leader>W", "<cmd>call VSCodeNotify('workbench.action.closeEditorsInGroup')<CR>")

-- Quick swap editor tabs
vim.keymap.set("n", "<C-j>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex2')<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>call VSCodeNotify('workbench.action.openEditorAtIndex3')<CR>")

-- Swap tabs left or right
vim.keymap.set("n", "<S-l>", "<cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
vim.keymap.set("n", "<S-h>", "<cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
-- Swap windows left or right
vim.keymap.set("n", "<C-l>", "<cmd>call VSCodeNotify('workbench.action.focusNextGroup')<CR>")
vim.keymap.set("n", "<C-h>", "<cmd>call VSCodeNotify('workbench.action.focusPreviousGroup')<CR>")

-- Split editor right and down
vim.keymap.set("n", "<leader>-", "<cmd>call VSCodeNotify('workbench.action.splitEditorDown')<CR>")
vim.keymap.set("n", "<leader>|", "<cmd>call VSCodeNotify('workbench.action.splitEditorRight')<CR>")

-- Open file explorer
vim.keymap.set("n", "<leader>e", "<cmd>call VSCodeNotify('workbench.view.explorer')<CR>")
-- vim.keymap.set("n", "<leader>e", "<cmd>call VSCodeNotify('workbench.action.toggleSidebarVisibility')<CR>")

-- Code actions
-- vim.keymap.set("n", "<leader>cr", "<cmd>call VSCodeNotifyVisual('editor.action.rename')<CR>")
