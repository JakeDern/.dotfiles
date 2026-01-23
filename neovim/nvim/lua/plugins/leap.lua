local setup = function()
  local leap = require('leap')
  vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
  vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')

  -- There's some race condition with highlight colors that this
  -- solves
  leap.init_highlight(true)

  -- Set the highlight groups
  vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'LeapMatch', {
    -- For light themes, set to 'black' or similar.
    fg = 'white',
    bold = true,
    nocombine = true,
  })
end

return {
  {
    "ggandor/leap.nvim",
    enabled = true,
    config = function()
      setup()
    end
  }
}
