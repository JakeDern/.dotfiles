setup = function()
    require('telescope').setup({
    
    })

    -- Extension must be loaded after telescope setup is run
    require('telescope').load_extension('fzf')
end

return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            setup()
        end,
    },
    -- Provides faster and better matching methods. Written in C which is why
    -- we have to `make` to install
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
}


