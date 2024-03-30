local key_set = function(mode, key, func)
  vim.keymap.set(mode, key, func, { buffer = 0 })
end

local setup = function(_, opts)
  -- Neodev setup must be done before lspconfig, so putting it first so that
  -- whatever lsp_zero does will be accounted for
  require("neodev").setup({})
  -- Mason docs state to set up 'mason' before 'mason-lspconfig'
  -- There isn't really any configuration for mason except for
  -- UI symbols and registries which we don't want to override
  -- anyways.
  require("mason").setup()

  -- local lsp_zero = require('lsp_zero')

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local lsp_setup = function(server)
    require('lspconfig')[server].setup({
      capabilities = capabilities,
    })
  end

  -- mason-lspconfig gives all the nice things like LspInstall,
  -- automatic setup of servers, etc.
  require("mason-lspconfig").setup({
    ensure_installed = {
      "gopls",
      "jsonls",
      "yamlls"
    },
    -- Register handlers for each Lsp. Default handler is the
    -- first one
    -- :h mason-lspconfig-automatic-server-setup
    handlers = {
      lsp_setup,
      ["omnisharp"] = function()
        require('lspconfig').omnisharp.setup({
          -- on_attach = function() end,
          capabilities = capabilities,
          -- handlers = {
          --   ["textDocument/definition"] = require('omnisharp_extended').handler,
          -- },
          organize_imports_on_format = true,
          enable_import_completion = true,
          complete_using_metadata = true
        })
      end
    }
  })

  -- :h LspAttach
  local telescope = require('telescope.builtin')
  local lsp_group = vim.api.nvim_create_augroup("JDLSP", { clear = true })
  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'Lsp Keymaps',
    group = lsp_group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then return end
      if client.name == 'omnisharp' then
        omnisharp_extended = require('omnisharp_extended')
        key_set("n", "gd", omnisharp_extended.lsp_definitions)
        key_set("n", "gr", omnisharp_extended.telescope_lsp_references)
        key_set("n", "gi", omnisharp_extended.telescope_lsp_implementation)
      else
        key_set("n", "gd", vim.lsp.buf.definition)
        key_set("n", "gr", telescope.lsp_references)
        key_set("n", "gi", telescope.lsp_implementations)
      end
      -- General Lsp stuff
      key_set("n", "gt", vim.lsp.buf.type_definition)
      key_set("n", "K", vim.lsp.buf.hover)
      key_set("n", "<leader>r", vim.lsp.buf.rename)
      key_set("n", "<leader>.", vim.lsp.buf.code_action)

      -- Diagnostics
      key_set("n", "<leader>dj", vim.diagnostic.goto_next)
      key_set("n", "<leader>dk", vim.diagnostic.goto_prev)
      key_set("n", "<leader>dh", vim.diagnostic.open_float)
      key_set("n", "<leader>dl", telescope.diagnostics)
    end
  })
  ---
  -- LSP setup
  --
  --   -- Auto formatting on save
  --   if client.supports_method("textDocument/formatting") then
  --     vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       group = augroup,
  --       buffer = bufnr,
  --       callback = function()
  --         vim.lsp.buf.format()
  --       end,
  --     })
  --   end
  -- end)


  ---
  -- CMP setup
  ---
  local cmp = require('cmp')
  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
  local lspkind = require('lspkind')
  cmp.setup({
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = function(fallback)
        fallback()
      end,
      ['<C-y>'] = cmp.mapping.confirm({ select = true })
    }),
    formatting = {
      format = lspkind.cmp_format({
        preset = 'default',
        mode = "symbol_text",
      })
    },
    sources = {
      { name = "nvim_lsp", group_index = 2 },
      { name = "copilot",  group_index = 2 },
      { name = "path",     group_index = 2 },
      { name = "luasnip",  group_index = 2 },
    }
  })
end

return {
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = setup,
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      -- Adds symbols to completion items
      { 'onsails/lspkind.nvim' },
      { 'zbirenbaum/copilot-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          { 'L3MON4D3/LuaSnip' },
        },
      },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'folke/neodev.nvim',                opts = {} },
      { 'Hoffs/omnisharp-extended-lsp.nvim' }
    },
  },
}
