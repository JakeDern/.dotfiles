return {
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/cmp-nvim-lsp",
      'VonHeikemen/lsp-zero.nvim',
    },
    opts = function()
        local metals_config = require("metals").bare_config()

        -- Example of settings
        -- metals_config.settings = {
        --   showImplicitArguments = true,
        --   excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
        -- }

        -- *READ THIS*
        -- I *highly* recommend setting statusBarProvider to true, however if you do,
        -- you *have* to have a setting to display this in your statusline or else
        -- you'll not see any messages from metals. There is more info in the help
        -- docs about this
        -- metals_config.init_options.statusBarProvider = "on"

        -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
        metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
        metals_config.on_attach = function(_, bufnr)
          local opts = {buffer = bufnr}
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

          -- Mapping these telescope ones here so that it's only mapped on_attach
          local telescope = require('telescope.builtin')
          vim.keymap.set("n", "gr", telescope.lsp_references, opts)
          vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)

          -- diagnostics
          vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "<leader>dl", telescope.diagnostics, opts)

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
}
