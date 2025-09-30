-- Temporary fix for blink.cmp v1.7.0 breaking change
-- This overrides the LazyVim configuration to remove the deprecated sources.cmdline
return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      -- Remove the deprecated cmdline configuration from sources
      if opts.sources and opts.sources.cmdline then
        opts.sources.cmdline = nil
      end

      -- Ensure cmdline configuration is properly set at the top level
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.enabled = true
      opts.cmdline.sources = { "buffer", "cmdline" }

      return opts
    end,
  },
}