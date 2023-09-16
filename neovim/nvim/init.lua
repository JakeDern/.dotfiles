require("common")

-- Check for vscode mode and only setup packer
-- if we're in normal nvim
if vim.g.vscode then
  require("vscode_lua")
else
  require("normal")
end

