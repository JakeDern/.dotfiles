-- todo
local setup = function()

end

local keymaps = function()

end

return {
    {
     'hrsh7th/nvim-cmp',
      dependencies = {
          -- Completion sources
          'hrsh7th/cmp-nvim-lsp',
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
    },
    config = function()
        setup()
        keymaps()
    end,
  },
}
