-- Configure plugin settings and load extensions here 
local setup = function()
    require('telescope').setup({
       defaults = {
           mappings = {
                -- Loads these keybinds only inside telescope
                i = {
                    -- Select next/previous using ctrl j/k
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                }
            }
        }
    })

    -- Extension must be loaded after telescope setup is run
    require('telescope').load_extension('fzf')
end

-- Configure telescope specific keybindings here
local keymaps = function()
    builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader><leader>', builtin.git_files, {})
    -- Telescope grep_string search=foo 
    vim.keymap.set('n', '<leader>fs', builtin.grep_string, {})
    vim.keymap.set('n', '<leader>s', builtin.live_grep, {})
end

return {
    {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        dependencies = { 'nvim-lua/plenary.nvim' },

        -- config is run when the plugin is loaded
        config = function()
            setup()
            keymaps()
        end,
    },
    -- Provides faster and better matching methods. Written in C which is why
    -- we have to `make` to install
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
}

