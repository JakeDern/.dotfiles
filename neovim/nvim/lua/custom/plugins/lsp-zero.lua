return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = function()
      require('custom.lsp-zero')
    end,
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'kikito/inspect.lua' },
      { 'zbirenbaum/copilot-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          { 'L3MON4D3/LuaSnip' },
        },
      },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'folke/neodev.nvim',                opts = {} },
      { 'Hoffs/omnisharp-extended-lsp.nvim' }
    },
  },
}
