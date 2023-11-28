local setup = function()
    local leap = require('leap')
    leap.add_default_mappings()

    -- IMPORTANT: These will override cut functionality
    -- if you don't remove them
    vim.keymap.del({ "x", "o" }, "x")
    vim.keymap.del({ "x", "o" }, "X")

    -- There's some race condition with highlight colors that this
    -- solves
    leap.init_highlight(true)

    -- Set the highlight groups
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

