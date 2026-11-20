local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
  -- Start at the commit in lazy-lock.json, like every other plugin; `stable`
  -- can be older, and a restore would then write that into the lock file.
  local ok, lock = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  end)
  local commit = ok and lock["lazy.nvim"] and lock["lazy.nvim"].commit
  if commit then
    vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", commit })
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "gruvbox" } },
  change_detection = { notify = false },
})
