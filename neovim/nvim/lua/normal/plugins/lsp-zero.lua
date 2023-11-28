local setup = function(_, opts)
    local lsp_zero = require('lsp-zero')

    lsp_zero.on_attach(function(client, bufnr)
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
    end)
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
                    {'hrsh7th/cmp-nvim-lsp'},
                },
            },
            {
                'hrsh7th/nvim-cmp'
                dependencies = {
                    {'L3MON4D3/LuaSnip'},
                },
            },
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
        }
    },
}
