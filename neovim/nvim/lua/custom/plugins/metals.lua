return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals_config = require("metals").bare_config()
    metals_config.on_attach = function(_, bufnr)
      local key_set = function(mode, key, func, bufnr)
        vim.keymap.set(mode, key, func, { buffer = bufnr })
      end

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

    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = self.ft,
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end
}
