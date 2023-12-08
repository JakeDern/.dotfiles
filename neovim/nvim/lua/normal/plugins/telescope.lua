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
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
          -- even more opts
        }
      }
    }
  })

  -- Extension must be loaded after telescope setup is run
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('ui-select')
end

-- Configure telescope specific keybindings here
local keymaps = function()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader><leader>', builtin.git_files, {})
  -- Telescope grep_string search=foo
  vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
  vim.keymap.set('n', '<C-f>', function()
    builtin.current_buffer_fuzzy_find({
      sorting_strategy = "ascending",
      layout_config = { prompt_position = "top" },
    })
  end, {})
end

return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },

    -- config is run when the plugin is loaded
    config = function()
      setup()
      keymaps()
    end,
  },
  -- Provides faster and better matching methods. Written in C which is why
  -- we have to `make` to install
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope-ui-select.nvim' }
}
