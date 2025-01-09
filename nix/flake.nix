{
  description = "Bionicus's Mac configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, nixpkgs, home-manager }:
    let
      configuration = { pkgs, config, ... }: {

        nixpkgs.config.allowUnfree = true;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          neovim
          mkalias
          argocd
          aws-iam-authenticator
          bat
          curl
          fzf
          git
          gitAndTools.git-lfs
          jq
          kubeseal
          postgresql_14
          rsync
          tmux
          watch
          wget
          zoxide
          nushell
          eza
          yazi
          rustup
          tmuxinator
          fd
          delta
          pgcli
          gtypist
        ];

        homebrew = {
          enable = true;
          brews = [
            "allure"
            "lsusb"
            "helm"
            "kubernetes-cli"
            "powerlevel10k"
          ];
          casks = [
            "ngrok"
            "raycast"
            "wezterm"
            "font-meslo-lg-nerd-font"
            "karabiner-elements"
          ];
          onActivation.cleanup = "zap";
        };

        system.activationScripts.applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in
          pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done;
          '';

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        services.nix-daemon.enable = true;
        programs.zsh.enable = true;
        security.pam.enableSudoTouchIdAuth = true;

        users.users.yuriiholiuk.home = "/Users/yuriiholiuk";
        home-manager.backupFileExtension = "backup";
        nix.configureBuildUsers = true;
        nix.useDaemon = true;
        system.defaults = {
          dock.autohide = true;
          dock.mru-spaces = false;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          screensaver.askForPasswordDelay = 10;
        };
      };
    in
      {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#MacBook-Pro-2
      darwinConfigurations."MacBook-Pro-2" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "yuriiholiuk";

              # Optional: Declarative tap management
              taps = {
                "homebrew/core" = homebrew-core;
                "homebrew/cask" = homebrew-cask;
                "homebrew/bundle" = homebrew-bundle;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          home-manager.darwinModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.yuriiholiuk = import ./home.nix;
          }
        ];
      };

      darwinPackages = self.darwinConfigurations."MacBook-Pro-2".pkgs;
    };
}
