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
