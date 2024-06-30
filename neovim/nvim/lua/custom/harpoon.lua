local harpoon = require('harpoon')

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = 'Harpoon add' })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon open' })

vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = 'Harpoon go to 1' })
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = 'Harpoon go to 2' })
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = 'Harpoon go to 3' })
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = 'Harpoon go to 4' })

vim.keymap.set("n", "<C-n>", function() harpoon:list():prev() end, { desc = 'Harpoon next' })
vim.keymap.set("n", "<C-p>", function() harpoon:list():next() end, { desc = 'Harpoon prev' })
