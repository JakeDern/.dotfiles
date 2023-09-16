
require("lazy").setup("vscode_lua.plugins", {
  spec = {
    -- Anything in the plugins folder is automatically loaded
    -- { "", import = "lazyvim.plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { missing = true },     -- Install missing plugins on startup
  checker = { enabled = false },    -- Automatically check for plugin updates
  performance = {
  },
})

