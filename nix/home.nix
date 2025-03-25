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

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;
}
