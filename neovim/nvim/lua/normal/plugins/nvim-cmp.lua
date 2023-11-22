-- todo
local setup = function()

end

local keymaps = function()

end

return {
    {
      -- nvim-cmp is the completion engine   
      'hrsh7th/nvim-cmp',

      dependencies = {
          -- These are all of the completion sources
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
