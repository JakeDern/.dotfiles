local lsp_zero = require('lsp-zero')
-- This configures the on_attach function for lsp-zero, this function
-- will be called when lsp_zero calls lsp-config to do setup
lsp_zero.on_attach(function(client, bufnr)
  -- Enable inlay hints
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(false, { 0 })
  end
end)


-- Mason docs state to set up 'mason' before 'mason-lspconfig'
-- There isn't really any configuration for mason except for
-- UI symbols and registries which we don't want to override
-- anyways.
--
-- mason-lspconfig gives all the nice things like LspInstall,
-- automatic setup of servers, etc.
require("mason").setup()

-- TODO: Add this rust analyzer config and any other overrides to /lsp/*.lua
-- so that the configurations are merged in after the defaults.
-- require("mason-lspconfig").setup({
--   ensure_installed = {
--     "gopls",
--     "jsonls",
--     "yamlls"
--   },
--   handlers = {
--     -- Default handler is the first one
--     lsp_zero.default_setup,
--     ["rust_analyzer"] = function()
--       require('lspconfig').rust_analyzer.setup {
--         settings = {
--           ['rust-analyzer'] = {
--             imports = {
--               granularity = {
--                 group = "module",
--               },
--               prefix = "self",
--             },
--             cargo = {
--               buildScripts = {
--                 enable = true,
--               },
--               allFeatures = true,
--             },
--             procMacro = {
--               enable = true
--             },
--             checkOnSave = true
--           }
--         }
--       }
--     end
--   }
-- })

local cmp = require('cmp')
require('copilot_cmp').setup()
cmp.setup({
  experimental = {
    ghost_text = true
  },
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'copilot' },
    { name = 'luasnip', keyword_length = 2 },
    { name = 'buffer',  keyword_length = 3 },
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  -- lsp-kind is another plugin for changing the format of completions,
  -- but lsp-zero's is good
  formatting = lsp_zero.cmp_format({ details = true }),
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = function(fallback)
      fallback()
    end,
    ['<C-y>'] = function(fallback)
      -- TODO: What is the difference between current and active entry?
      -- print(cmp.get_active_entry().source.name)
      local selected = cmp.get_selected_entry()
      if not selected then
        local entries = cmp.get_entries()
        -- I don't know why this would be possible, but being defensive here
        if not entries then
          fallback()
          return
        else
          selected = entries[1]
        end
      end

      local opts = { select = true }
      if selected.source.name == 'copilot' then
        -- Documentation says this behavior is important, I don't know why.
        opts = { behavior = cmp.ConfirmBehavior.Replace, select = true }
      end

      cmp.mapping.confirm(opts)()
    end
  })
})
