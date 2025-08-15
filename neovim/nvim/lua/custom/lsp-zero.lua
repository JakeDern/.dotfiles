local key_set = function(mode, key, func, bufnr)
  vim.keymap.set(mode, key, func, { buffer = bufnr })
end

-- Prints out a table
function Dump(tbl, indent, level)
  if not indent then indent = 0 end
  if not level then level = 0 end
  if level > 3 then return end

  for k, v in pairs(tbl) do
    local formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      Dump(v, indent + 1, level + 1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    elseif type(v) == 'function' then
      print("Function")
    elseif v ~= nil then
      print(formatting .. tostring(v))
    end
  end
end

local override_keymaps = {
  ['omnisharp'] = function(_, bufnr)
    local omnisharp_extended = require('omnisharp_extended')
    key_set("n", "gd", omnisharp_extended.lsp_definitions, bufnr)
    key_set("n", "gr", omnisharp_extended.telescope_lsp_references, bufnr)
    key_set("n", "gi", omnisharp_extended.telescope_lsp_implementation, bufnr)
  end
}

local apply_keymaps = function(_, bufnr)
  local fzf = require('fzf-lua')
  key_set("n", "gt", vim.lsp.buf.type_definition, bufnr)
  key_set("n", "K", vim.lsp.buf.hover, bufnr)
  key_set("n", "<leader>r", vim.lsp.buf.rename, bufnr)
  key_set("n", "<leader>.", vim.lsp.buf.code_action, bufnr)

  -- Diagnostics
  key_set("n", "<leader>dj", function() vim.diagnostic.goto_next({ float = false }) end, bufnr)
  -- key_set("n", "<leader>dk", vim.diagnostic.goto_prev, bufnr)
  key_set("n", "<leader>dk", function() vim.diagnostic.goto_prev({ float = false }) end, bufnr)
  key_set("n", "<leader>dh", vim.diagnostic.open_float, bufnr)
  -- TODO: Configure this in FZF
  -- key_set("n", "<leader>dl", telescope.diagnostics, bufnr)
  key_set("n", "<leader>dl", fzf.diagnostics_document, bufnr)
  key_set("n", "<leader>dw", fzf.diagnostics_workspace, bufnr)

  -- References, definitions
  -- key_set("n", "gr", telescope.lsp_references, bufnr)
  key_set("n", "gr", fzf.lsp_references, bufnr)
  key_set("n", "gd", vim.lsp.buf.definition, bufnr)
  -- key_set("n", "gi", telescope.lsp_implementations, bufnr)
  key_set("n", "gi", fzf.lsp_implementations, bufnr)
end

-- For some reason bicepparam files are not properly detected
vim.filetype.add({
  extension = {
    bicepparam = "bicep-params",
    bicep = "bicep",
  }
})

-- Neodev setup must be done before lspconfig, so putting it first so that
-- whatever lsp_zero does will be accounted for
require("neodev").setup({})
local lsp_zero = require('lsp-zero')


-- This configures the on_attach function for lsp-zero, this function
-- will be called when lsp_zero calls lsp-config to do setup
lsp_zero.on_attach(function(client, bufnr)
  apply_keymaps(client, bufnr)
  local overrides = override_keymaps[client.name]
  if overrides then
    overrides(client, bufnr)
  end

  -- Some day should try the other formatting options:
  -- https://lsp-zero.netlify.app/v3.x/reference/lua-api.html#async-autoformat-client-bufnr-opts
  -- https://lsp-zero.netlify.app/v3.x/reference/lua-api.html#format-on-save-opts
  lsp_zero.buffer_autoformat()

  -- Organize imports on save if the client supports it
  local augroup = vim.api.nvim_create_augroup("JD_LSP", { clear = true })

  -- Enable inlay hints
  if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(false, { 0 })
  end

  if client.supports_method("source.organize_imports_on_format") then
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      desc = ("Organize imports for '%s'"):format(client.name),
      pattern = { "*.go", "*.mod", "*.sum" },

      -- Implementation copied from Go docs:
      -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
      callback = function(_)
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end
      end,
    })
  end
end)


-- Technically these are "diagnostic signs", neovim enables them by default.
-- Here we are just changing them to fancy icons.
lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

-- Mason docs state to set up 'mason' before 'mason-lspconfig'
-- There isn't really any configuration for mason except for
-- UI symbols and registries which we don't want to override
-- anyways.
--
-- mason-lspconfig gives all the nice things like LspInstall,
-- automatic setup of servers, etc.
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",
    "jsonls",
    "yamlls"
  },
  handlers = {
    -- Default handler is the first one
    lsp_zero.default_setup,
    ["rust_analyzer"] = function()
      require('lspconfig').rust_analyzer.setup {
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
              allFeatures = true,
            },
            procMacro = {
              enable = true
            },
            checkOnSave = true
          }
        }
      }
    end,
    ["omnisharp"] = function()
      -- at this point lsp-zero has already applied
      -- the "capabilities" options to lspconfig's defaults.
      -- so there is no need to add them here manually.
      require('lspconfig').omnisharp.setup({
        handlers = {
          ["textDocument/definition"] = require('omnisharp_extended').handler,
        },
        organize_imports_on_format = true,
        enable_import_completion = true,
        complete_using_metadata = true
      })
    end
  }
})

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
