-- Configuration for tmux integration
-- This file contains settings to ensure seamless navigation between NeoVim and tmux

-- Ensure vim-tmux-navigator plugin is properly configured
-- These settings help ensure that Ctrl+hjkl keys work for navigating between NeoVim and tmux panes

-- Disable navigation when zoomed
vim.g.tmux_navigator_disable_when_zoomed = 0

-- Preserve zoom when navigating (if tmux window is zoomed, keep it zoomed when moving from Vim to another pane)
vim.g.tmux_navigator_preserve_zoom = 1

-- Don't save buffers when navigating away from Vim
-- Set to 1 to save current buffer, 2 to save all buffers
vim.g.tmux_navigator_save_on_switch = 0

-- Allow wrapping (navigating from the rightmost pane to the leftmost pane)
vim.g.tmux_navigator_no_wrap = 0

-- Don't disable the netrw workaround (this ensures <C-l> works in netrw buffers)
vim.g.tmux_navigator_disable_netrw_workaround = 0

-- Log a message to confirm this file is loaded (disabled to avoid startup noise)
-- vim.notify("Tmux navigation configuration loaded", vim.log.levels.INFO)
