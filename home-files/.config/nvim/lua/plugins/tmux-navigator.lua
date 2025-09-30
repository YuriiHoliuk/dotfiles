return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Navigate Left" },
    { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Navigate Down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Navigate Up" },
    { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Navigate Right" },
    { "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", desc = "Navigate Previous" },
  },
}
