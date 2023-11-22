-- On_attach function which will set keymaps only when an lsp is attached to a
-- buffer. These keymaps are wiped out when the buffer un-attaches.
local on_attach = function() print("On attach func")
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
end

-- Configure plugin settings and load extensions here 
local setup = function()

    -- Each language server will need to have its own on_attach configured
   require('lspconfig').gopls.setup({
        on_attach = on_attach
    }) 
end

-- Configure keymaps that should apply globally all the time here
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
