return {
  -- Keybindings using the new which-key spec
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>a", desc = " Augment" },
      { "<leader>as", "<cmd>Augment status<cr>", desc = "Status" },
      { "<leader>ai", "<cmd>Augment signin<cr>", desc = "Sign In" },
      { "<leader>ao", "<cmd>Augment signout<cr>", desc = "Sign Out" },
      { "<leader>al", "<cmd>Augment log<cr>", desc = "Log" },
      { "<leader>ac", "<cmd>Augment chat<cr>", desc = "Chat" },
      { "<leader>an", "<cmd>Augment chat-new<cr>", desc = "New Chat" },
      { "<leader>at", "<cmd>Augment chat-toggle<cr>", desc = "Toggle Chat Panel" },
    },
  },

  -- Plugin declaration (optional if managed elsewhere)
  { "augmentcode/augment.vim" },
}
