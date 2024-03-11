local setup = function(_, opts)
  -- Neodev setup must be done before lspconfig, so putting it first so that
  -- whatever lsp_zero does will be accounted for
  require("neodev").setup({})

  ---
  -- LSP setup
  ---
  local lsp_zero = require('lsp-zero')
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
  lsp_zero.on_attach(function(client, bufnr)
    opts = { buffer = bufnr }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, opts)

    -- Mapping these telescope ones here so that it's only mapped on_attach
    local telescope = require('telescope.builtin')
    vim.keymap.set("n", "gr", telescope.lsp_references, opts)
    vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "<leader>dh", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>dl", telescope.diagnostics, opts)

    -- Auto formatting on save
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
  end)

  require('mason').setup({})
  require('mason-lspconfig').setup({
    handlers = {
      lsp_zero.default_setup,
    }
  })

  require('lspconfig').omnisharp.setup({
    on_attach = lsp_zero.on_attach,
    handlers = {
      ["textDocument/definition"] = require('omnisharp_extended').handler,
    },
    organize_imports_on_format = true,
    enable_import_completion = true,
    complete_using_metadata = true,
  })

  lsp_zero.setup_servers({ 'gopls', 'bicep' })

  ---
  -- CMP setup
  ---
  local cmp = require('cmp')
  local cmp_action = require('lsp-zero').cmp_action()
  local copilot = require('copilot.suggestion')
  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      -- ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      ['<C-e>'] = cmp.mapping.abort(),
      -- Based off of https://github.com/fredrikaverpil/dotfiles/blob/main/nvim-lazyvim/lua/plugins/cmp.lua
      ['<C-y>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          print("Accepting cmp")
          -- cmp.select_next_item()
          -- cmp.
          -- cmp.confirm()
          cmp.mapping.confirm({ select = false })()
        elseif copilot.is_visible() then
          print("Accepting copilot")
          copilot.accept()
        else
          print("Fallback")
          fallback()
        end
      end, { "i", "s" }),
      -- Based off of https://github.com/fredrikaverpil/dotfiles/blob/main/nvim-lazyvim/lua/plugins/cmp.lua
      -- ['<S-Tab>'] = cmp.mapping(function(fallback)
      --   if cmp.visible() then
      --     cmp.select_prev_item()
      --   else
      --     fallback()
      --   end
      -- end, { "i", "s" }),
      -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      -- ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
  })
end

return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = setup,
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          { 'hrsh7th/cmp-nvim-lsp' },
        },
      },
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          { 'L3MON4D3/LuaSnip' },
        },
      },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { "folke/neodev.nvim",                opts = {} },
      { "Hoffs/omnisharp-extended-lsp.nvim" }
    },
  },
}
