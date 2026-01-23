-- This is merged in after anything from 'neovim/lsp-config'.
-- It's possible to specify overrides in multiple places, check ':h lsp' for
-- the merge order.
-- Can check the final config for the server with ':checkhealth vim.lsp'
return {
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
