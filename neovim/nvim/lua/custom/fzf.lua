local fzf = require('fzf-lua')
local actions = fzf.actions
fzf.setup({
  { "default-title" }, -- base profile
  fzf_colors = {
    ["fg"] = { "fg", "TelescopeNormal" },
    ["bg"] = { "bg", "TelescopeNormal" },
    ["hl"] = { "fg", "TelescopeMatching" },
    ["fg+"] = { "fg", "TelescopeSelection" },
    ["bg+"] = { "bg", "TelescopeSelection" },
    ["hl+"] = { "fg", "TelescopeMatching" },
    ["info"] = { "fg", "TelescopeMultiSelection" },
    ["border"] = { "fg", "TelescopeBorder" },
    ["gutter"] = "-1",
    ["query"] = { "fg", "TelescopePromptNormal" },
    ["prompt"] = { "fg", "TelescopePromptPrefix" },
    ["pointer"] = { "fg", "TelescopeSelectionCaret" },
    ["marker"] = { "fg", "TelescopeSelectionCaret" },
    ["header"] = { "fg", "TelescopeTitle" },
  },
  lsp        = {
    jump_to_single_result = true,
    jump_to_single_result_action = actions.file_edit,
  },
  keymap     = {
    builtin = {
      true,
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
    },
    fzf = {
      true,
      ["ctrl-d"] = "preview-page-down",
      ["ctrl-u"] = "preview-page-up",
      ["ctrl-q"] = "select-all+accept",
    },
  },
  actions    = {
    files = {
      ["enter"]  = actions.file_edit_or_qf,
      ["ctrl-x"] = actions.file_split,
      ["ctrl-v"] = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["alt-q"]  = actions.file_sel_to_qf,
    },
  },
  buffers    = {
    keymap = { builtin = { ["<C-d>"] = false } },
    actions = { ["ctrl-x"] = false, ["ctrl-d"] = { actions.buf_del, actions.resume } },
  },
  defaults   = { git_icons = false },
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
