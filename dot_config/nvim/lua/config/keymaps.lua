local map = vim.keymap.set

-- Fast saving (only writes if the buffer changed)
map("n", "<leader>w", "<cmd>update<cr>")

-- No arrow keys
for _, key in ipairs({ "<Left>", "<Right>", "<Up>", "<Down>" }) do
  map({ "n", "x", "o" }, key, '<cmd>echo "ಠ_ಠ"<cr>')
end

-- Clear search highlight (Ctrl-L, Neovim's default for this, changes pane below)
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")

-- Change pane
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Trim trailing whitespace
map("n", "<leader>W", [[m`:%s/\s\+$//e<cr>``]])
