local lsps = {
  'gopls',
  'jsonls',
  'lua_ls',
  'rust_analyzer',
  'yamlls',
}

-- Enable all LSPs. This used to be provided by mason-lspconfig but this was
-- pretty much the last piece of functionality I need out of that. I can do
-- without the LspInstall command figuring out the lsp automatically.
for _, lsp in ipairs(lsps) do
  vim.lsp.enable(lsp)
end


-- Set the symbols for diagnostics in the lane
local ds = vim.diagnostic.severity
vim.diagnostic.config({
  signs = {
    text = {
      [ds.ERROR] = '✘',
      [ds.WARN] = '▲',
      [ds.INFO] = '»',
      [ds.HINT] = '⚑'
    }
  }
})


-- Main lsp attach function. Sets up all the keybindings and some augroups
-- that do stuff like formatting
local group = vim.api.nvim_create_augroup('jakedern.lsp', {})
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(args)
    local key_set = function(mode, key, func, bufnr)
      vim.keymap.set(mode, key, func, { buffer = bufnr })
    end

    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    local bufnr = args.buf
    local fzf = require('fzf-lua')
    key_set("n", "gt", vim.lsp.buf.type_definition, bufnr)
    key_set("n", "K", vim.lsp.buf.hover, bufnr)
    key_set("n", "<leader>r", vim.lsp.buf.rename, bufnr)
    key_set("n", "<leader>.", vim.lsp.buf.code_action, bufnr)

    -- Diagnostics
    key_set("n", "<leader>dj", function()
      vim.diagnostic.jump({ count = 1 })
    end, bufnr)
    key_set("n", "<leader>dk", function()
      vim.diagnostic.jump({ count = -1 })
    end, bufnr)
    key_set("n", "<leader>dh", vim.diagnostic.open_float, bufnr)
    key_set("n", "<leader>dl", fzf.diagnostics_document, bufnr)
    key_set("n", "<leader>dw", fzf.diagnostics_workspace, bufnr)

    -- References, definitions
    key_set("n", "gr", fzf.lsp_references, bufnr)
    key_set("n", "gd", vim.lsp.buf.definition, bufnr)
    key_set("n", "gi", fzf.lsp_implementations, bufnr)

    -- Auto-format on save.
    --
    -- Below comment is from `h: lsp`, not sure if it's accurate or if we should
    -- remove the first condition here...
    --
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
