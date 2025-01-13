return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy", -- Or `LspAttach`
  priority = 1000,    -- needs to be loaded in first
  config = function()
    require('tiny-inline-diagnostic').setup({
      preset = "simple",
      options = {
        --
        -- Display all diagnostic messages on the cursor line
        show_all_diags_on_cursorline = true,

        -- Show all diagnostics under the cursor if multiple diagnostics exist on the same line
        -- If set to false, only the diagnostics under the cursor will be displayed
        multiple_diag_under_cursor = true,

        multilines = {
          enabled = true,
        }
      }
    })
  end
}
