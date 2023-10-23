local setup = function()
    local leap = require('leap')
    leap.add_default_mappings()
    leap.init_highlight(true)
    vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'LeapMatch', {
      -- For light themes, set to 'black' or similar.
      fg = 'white', bold = true, nocombine = true,
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

