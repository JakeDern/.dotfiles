return {
    {
      -- LSP Configuration & Plugins
      'neovim/nvim-lspconfig',
      dependencies = {
          -- Automatically install LSPs to stdpath for neovim
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',

          -- Automatically configures lua language server for your neovim config
          { 'folke/neodev.nvim', opts = {} },
    },
  },
}
