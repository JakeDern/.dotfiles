-- Configuration for all of this taken from
-- https://github.com/fredrikaverpil/dotfiles/blob/main/nvim-lazyvim/lua/plugins/ai.lua
return {
  -- custom config which piggybacks on the copilot extras in lazy.lua.
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
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
    end,
  },
}
