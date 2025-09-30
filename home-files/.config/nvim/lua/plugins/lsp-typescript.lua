return {
  -- Disable the built-in TypeScript servers
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        -- Disable all TypeScript servers
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        vtsls = {
          enabled = false,
        },
      },
    },
  },

  -- Use typescript-tools.nvim instead for better monorepo support
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      tsserver_plugins = {},
      -- on_attach = function(client, bufnr)
      --   require("lazyvim.lsp").on_attach(client, bufnr)

      --   -- Add TypeScript specific keymaps
      --   vim.keymap.set("n", "<leader>co", function()
      --     vim.cmd("TypescriptOrganizeImports")
      --   end, { buffer = bufnr, desc = "Organize Imports" })

      --   vim.keymap.set("n", "<leader>cR", function()
      --     vim.cmd("TypescriptRenameFile")
      --   end, { buffer = bufnr, desc = "Rename File" })
      -- end,
      settings = {
        separate_diagnostic_server = true,
        tsserver_max_memory = "4096",
      },
    },
  },
}