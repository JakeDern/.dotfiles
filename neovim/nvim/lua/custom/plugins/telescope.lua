return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- config is run when the plugin is loaded
    config = function()
      require('custom.telescope')
    end,
  },
  -- Provides faster and better matching methods. Written in C which is why
  -- we have to `make` to install
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-ui-select.nvim' }
}
