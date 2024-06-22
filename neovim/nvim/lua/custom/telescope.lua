require('telescope').setup({
  defaults = {
    mappings = {
      -- Loads these keybinds only inside telescope
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
-- require('telescope').load_extension('ui-select')

local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<leader><leader>', builtin.git_files, {})

vim.keymap.set('n', '<leader><leader>', function()
  builtin.find_files {
    -- Filter out .git folder and gitignore, but allow hidden files
    find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
  }
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>fd', function()
  builtin.find_files {
    -- Filter out .git folder and gitignore, but allow hidden files
    find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
    cwd = '~/repos/.dotfiles'
  }
end, { desc = 'Search dotfiles' })

-- General
vim.keymap.set('n', '<leader>ps', builtin.live_grep, {})
vim.keymap.set('n', '<C-f>', function()
  builtin.current_buffer_fuzzy_find({
    sorting_strategy = "ascending",
    layout_config = { prompt_position = "top" },
  })
end, { desc = 'Ctrl f buffer' })
