local setup = function()
    local cmp = require('cmp')
    cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  -- Add an entry for every lsp server in here
  -- TODO: This seems to break/override my lsp setup for gopls. keymaps
  -- stop working when I fill this out. Not sure why
  require('lspconfig')[''].setup {
    capabilities = capabilities
  }
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
            
          -- Snippet plugin for actually doing the completion
          'L3MON4D3/LuaSnip',
          -- Actually integrates the snippet plugin with lsp stuff
          'saadparwaiz1/cmp_luasnip',
    },
    config = function()
        setup()
        keymaps()
    end,
  },
}
