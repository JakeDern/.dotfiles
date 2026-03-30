vim.pack.add({
  'https://github.com/zbirenbaum/copilot.lua',
})

-- Old lazy.nvim options in case we need them after migrating
-- cmd = "Copilot",
-- build = ":Copilot auth",
-- event = "InsertEnter",

require("copilot").setup({
  panel = {
    enabled = false,
    auto_refresh = true,
  },
  suggestion = {
    enabled = false,
    auto_trigger = true,
    auto_refresh = true,
    accept = false, -- disable built-in keymapping
  },
  filetypes = {
    help = false,
    gitcommit = false,
    gitrebase = false,
    bicep = false
  }
})
