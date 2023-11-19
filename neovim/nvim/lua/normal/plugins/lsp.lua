-- Configure plugin settings and load extensions here 
local setup = function()
   require('lspconfig').gopls.setup({
    
   }) 
end

-- Configure telescope specific keybindings here
local keymaps = function()
    
end

return {
    {
      -- LSP Configuration & Plugins
      -- basically pre-baked configurations for many lsp servers
      'neovim/nvim-lspconfig',
      dependencies = {
          -- Automatically install LSPs to stdpath for neovim
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',

          -- Automatically configures lua language server for your neovim config
          { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
        setup()
        keymaps()
    end,
  },
}
