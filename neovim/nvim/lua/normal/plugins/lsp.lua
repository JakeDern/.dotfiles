-- Common options for each remap
local opts = {
    buffer = 0 -- Map this key only for the current buffer
}

-- On_attach function which will set keymaps only when an lsp is attached to a
-- buffer. These keymaps are wiped out when the buffer un-attaches.
local on_attach = function()
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    
    -- Mapping these telescope ones here so that it's only mapped on_attach
    local telescope = require('telescope.builtin') 
    vim.keymap.set("n", "gr", telescope.lsp_references, opts)
    vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)

    -- diagnostics
    vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>ds", telescope.diagnostics, opts)
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
