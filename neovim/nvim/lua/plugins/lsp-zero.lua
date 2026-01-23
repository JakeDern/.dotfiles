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
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
  },
}
