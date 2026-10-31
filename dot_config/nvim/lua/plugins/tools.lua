return {
  -- Fuzzy finding and ripgrep search (replaces ack.vim / vim-ripgrep)
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>g", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
      { "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
    },
    opts = {},
  },
}
