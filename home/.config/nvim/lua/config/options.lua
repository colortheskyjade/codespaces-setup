-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "fzf"
-- TypeScript/JS LSP: "tsgo" (native preview) vs default "vtsls"
vim.g.lazyvim_ts_lsp = "tsgo"

-- Zellij doesn't advertise OSC 52 support; force Neovim to use it anyway
vim.env.SSH_TTY = vim.env.SSH_TTY or "/dev/tty"

-- Force OSC 52 clipboard (works through SSH + Zellij → WezTerm)
local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}

vim.opt.clipboard = "unnamedplus"
