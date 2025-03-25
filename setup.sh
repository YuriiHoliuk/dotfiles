#!/bin/bash

# Installs git and many other dev tools.
xcode-select --install

# Installs nix.
sh <(curl -L https://nixos.org/nix/install)

# Generates ssh key.
ssh-keygen -t ed25519 -C "yurii.holiuk@mate.academy" -f ~/.ssh/id_ed25519 -N ""

# Adds ssh key to ssh agent.
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Create ~/.ssh/config if it doesn't exist
[ ! -f ~/.ssh/config ] && touch ~/.ssh/config
chmod 600 ~/.ssh/config

echo "\
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
" >> ~/.ssh/config

# Adds ssh key to github.
pbcopy < ~/.ssh/id_ed25519.pub
open https://github.com/settings/ssh/new

# Pause the script and wait for user confirmation
read -p "Press Enter after you've added the SSH key to GitHub..."

git clone git@github.com:YuriiHoliuk/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Get current machine's hostname
hostname=$(scutil --get LocalHostName)

# Get the hostname from flake.nix by looking at first darwinConfigurations line
default_hostname=$(grep 'darwinConfigurations\.' nix/flake.nix | head -n 1 | cut -d '"' -f2)

# Replace the hostname in flake.nix
sed -i '' "s/$default_hostname/$hostname/g" nix/flake.nix

cd nix

nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake .#$hostname

fnm install --lts
fnm use --lts

# Extract and install Cursor extensions
echo "Extracting Cursor extensions..."
jq -r '.[].identifier.id' ~/.cursor/extensions.json > ~/dotfiles/cursor/installed-extensions.txt

echo "Installing Cursor extensions..."
while read -r extension; do
    echo "Installing extension: $extension"
    open -a Cursor --args --install-extension "$extension"
done < ~/dotfiles/cursor/installed-extensions.txt

echo "Cursor configuration and extensions setup complete!"
