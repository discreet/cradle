local group = vim.api.nvim_create_augroup("config", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- Return to last edit position when opening files
autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Line length per filetype (also positions the colorcolumn)
local textwidth = { markdown = 80, python = 88 }
autocmd("FileType", {
  group = group,
  pattern = vim.tbl_keys(textwidth),
  callback = function(args)
    vim.bo[args.buf].textwidth = textwidth[args.match]
  end,
})

autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})
