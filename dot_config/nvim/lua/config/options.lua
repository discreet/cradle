-- Leader must be set before lazy.nvim loads plugins.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opt = vim.opt

opt.undofile = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Completion (LSP completion pops up as you type; see plugins/lsp.lua)
opt.wildmode = "longest:full,full"
opt.completeopt = { "menuone", "noselect", "popup" }

-- Indentation (vim-sleuth adjusts per file)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- Display
opt.number = true
opt.wrap = false
opt.colorcolumn = "+1" -- one past textwidth, set per filetype in autocmds.lua
opt.signcolumn = "yes"
opt.scrolloff = 3
opt.list = true
opt.listchars = { tab = "¦ ", trail = "·", nbsp = "␣" }
