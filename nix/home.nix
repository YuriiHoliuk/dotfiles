# home.nix
# home-manager switch 

{ config, pkgs, ... }:

{
  home.username = "yuriiholiuk";
  home.homeDirectory = "/Users/yuriiholiuk";
  home.stateVersion = "23.05"; # Please read the comment before changing.

# Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".zshrc".source = ../zsh/zshrc;
    ".zsh_aliases".source = ../zsh/zsh_aliases;
    ".p10k.zsh".source =  ../p10k/p10k.zsh;
    ".wezterm.lua".source = ../wezterm/wezterm.lua;
    ".gitconfig".source = ../git/gitconfig;
    ".config/pgcli/config".source = ../pgcli/config;
    ".config/tmuxinator".source = ../tmuxinator;
    # ".config/skhd".source = ~/dotfiles/skhd;
    # ".config/starship".source = ~/dotfiles/starship;
    # ".config/zellij".source = ~/dotfiles/zellij;
    ".config/nvim".source = ../nvim;
    # ".config/nix".source = ~/dotfiles/nix;
    # ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
    ".tmux.conf".source = ../tmux/tmux.conf;
    # ".config/ghostty".source = ~/dotfiles/ghostty;
    # ".config/aerospace".source = ~/dotfiles/aerospace;
    # ".config/sketchybar".source = ~/dotfiles/sketchybar;
    ".cursor/extensions.json".source = ../cursor/extensions.json;
    "Library/Application Support/Cursor/User/settings.json".source = ../cursor/settings.json;
    "Library/Application Support/Cursor/User/keybindings.json".source = ../cursor/keybindings.json;
    # ".config/nushell".source = ~/dotfiles/nushell;
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
  ];
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Add any additional configurations here
      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
