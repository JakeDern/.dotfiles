vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/oil.nvim',
})

require("oil").setup {
  columns = { "icon" },
  keymaps = {
    ["<C-h>"] = false,
    ["<M-h>"] = "actions.select_split",
  },
  view_options = {
    show_hidden = true,
  },
}

-- Open parent directory in current window
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
