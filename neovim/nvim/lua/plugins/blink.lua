return {
  'saghen/blink.cmp',
  -- use a release tag to download pre-built binaries
  version = '1.*',
  config = function()
    require('custom.blink')
  end,
  opts_extend = { "sources.default" }
}
