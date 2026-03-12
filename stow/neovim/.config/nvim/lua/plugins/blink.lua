return {
  'saghen/blink.cmp',
  -- use a release tag to download pre-built binaries
  version = '1.*',
  dependencies = {
    'Exafunction/codeium.nvim'
  },
  config = function()
    require('custom.blink')
  end,
  opts_extend = { "sources.default" }
}
