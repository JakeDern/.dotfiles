-- Bunch of small plugins with minimal configuration in this file
return {
    'numToStr/Comment.nvim',
    opts = {
        -- add any options here
    },
    config = function()
        require('Comment').setup()
    end,
    lazy = false,
}
