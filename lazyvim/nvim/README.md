# Lazy vim setup notes

## Debugging

Log file locations: `~/.local/state/nvim/lsp.log`

## LSP Support

### TypeScript: tsserver

Need to have latest global install of neovim client and of TypeScript in order for it to work.

```
$ npm install -g neovim

$ npm install -g typescript
```

Also install nvm and use that to install node

```
$ curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

$ nvm install node
```

## Plugins

### leap.nvim

Keybindings:

"s{c1}{c2}": Search for a two character sequence and jump to the search result that you want.
"S{c1}{c2}": Same as previous, but search backwards
