-- Bunch of small plugins with minimal configuration in this file
return {
  {'tpope/vim-fugitive'},
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    config = function()
      require('Comment').setup()

      -- Maps Ctrl+/ to toggle single line comments
      -- Ctrl+/ is interpreted as <C-_> by Neovim
      vim.keymap.set("n", "<C-_>", require('Comment.api').toggle.linewise.current, { noremap = true, silent = true })

      -- Maps Ctrl+/ to toggle multiple selected linewise
      -- This was taken from the Comments.Nvim api code
      -- https://github.com/numToStr/Comment.nvim/blob/master/lua/Comment/api.lua
      local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true) 
      vim.keymap.set('x', '<C-_>', function()
        vim.api.nvim_feedkeys(esc, 'nx', false)
        require('Comment.api').toggle.linewise(vim.fn.visualmode())
      end)
    end,
    lazy = false,
  }
}
