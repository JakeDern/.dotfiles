vim.pack.add({
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/nvim-treesitter/nvim-treesitter',
})

require("nvim-treesitter").setup {
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },

  ensure_installed = {
    "bash",
    -- "c",
    -- "diff",
    -- "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "regex",
    "toml",
    -- "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
    "go",
    "c_sharp",
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' },
  callback = function() pcall(vim.treesitter.start) end,
})
