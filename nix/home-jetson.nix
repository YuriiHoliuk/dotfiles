{ config, pkgs, ... }:

{
  home.username = "bionicuss";
  home.homeDirectory = "/home/bionicuss";
  home.stateVersion = "22.11";

  home.packages = with pkgs; [
    # Shell
    zsh
    # Editor
    neovim
    # Terminal multiplexer
    tmux
    tmuxinator
    # Git
    git
    git-lfs
    delta
    lazygit
    gh
    # Search & navigation
    fzf
    fd
    ripgrep
    zoxide
    # File management
    eza
    bat
    yazi
    # Data tools
    jq
    pgcli
    nushell
    # Basics
    curl
    wget
    rsync
    stow
    # Node version manager
    fnm
    # Media
    ffmpeg
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
    "$HOME/.local/bin"
  ];

  programs.home-manager.enable = true;
}
