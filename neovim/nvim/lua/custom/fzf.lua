local fzf = require('fzf-lua')
local actions = fzf.actions
fzf.setup({
  winopts = {
    preview = {
      layout = 'horizontal'
    }
  },
  actions = {
    files = {
      ["enter"]  = actions.file_edit_or_qf,
      ["alt-s"]  = actions.file_split,
      ["alt-v"]  = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["ctrl-q"] = actions.file_sel_to_qf,
      ["ctrl-Q"] = actions.file_sel_to_ll,
    }
  }
})

vim.keymap.set('n', '<leader><leader>', fzf.files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fh', fzf.oldfiles, { desc = 'File history' })
vim.keymap.set('n', '<C-f>', fzf.lgrep_curbuf, { desc = 'Ctrl f buffer' })
vim.keymap.set('n', '<leader>fs', fzf.live_grep, { desc = 'Live grep project' })
vim.keymap.set('n', '<leader>fw', fzf.grep_cword, { desc = 'Grep word under cursor' })
vim.keymap.set('n', '<leader>fW', fzf.grep_cWORD, { desc = 'Grep WORD under cursor' })
vim.keymap.set('n', '<leader>fd', function()
  fzf.files({
    cwd = '~/repos/.dotfiles'
  })
end, { desc = 'Find files in dotfiles' })
