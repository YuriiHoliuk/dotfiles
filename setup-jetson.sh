#!/bin/bash
set -e

echo "=== Jetson Orin NX Setup ==="
echo ""

# --- 1. Install Nix (multi-user daemon mode) ---
if ! command -v nix &> /dev/null; then
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    echo "Nix installed. You may need to restart your shell or source the daemon script."
    echo "Run: . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'"
    echo "Then re-run this script."
    exit 0
fi

# --- 2. Enable flakes ---
echo "Enabling Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# --- 3. Clone dotfiles if not present ---
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/YuriiHoliuk/dotfiles.git ~/dotfiles
fi

cd ~/dotfiles/nix

# --- 4. Install home-manager and apply Jetson config ---
echo "Running home-manager switch..."
nix run home-manager/master -- switch --flake .#jetson

# --- 5. Stow dotfiles ---
echo "Stowing dotfiles..."
cd ~/dotfiles
stow --target="$HOME" home-files home-files-jetson

# --- 6. Set zsh as default shell ---
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Setting zsh as default shell..."
    # Add nix zsh to /etc/shells if not already there
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to zsh. Will take effect on next login."
fi

# --- 7. Clone neovim config ---
if [ ! -d "$HOME/.config/nvim" ]; then
    echo "Cloning neovim config..."
    git clone https://github.com/YuriiHoliuk/nvim.git ~/.config/nvim
else
    echo "Neovim config already exists, skipping clone."
fi

# --- 8. Generate SSH key for GitHub ---
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "yurii.holiuk@mate.academy" -f ~/.ssh/id_ed25519 -N ""
    echo ""
    echo "=== Add this SSH key to GitHub ==="
    cat ~/.ssh/id_ed25519.pub
    echo ""
    echo "Go to: https://github.com/settings/ssh/new"
else
    echo "SSH key already exists, skipping."
fi

# --- 9. Add docker group ---
if ! groups | grep -q docker; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Added to docker group. Log out and back in for it to take effect."
fi

echo ""
echo "=== Setup complete! ==="
echo "Next steps:"
echo "  1. Log out and back in (for zsh + docker group)"
echo "  2. Open tmux: tmux new-session -s main"
echo "  3. Install tmux plugins: prefix + I"
echo "  4. Open neovim to trigger plugin install: nvim"
echo "  5. Install Claude Code: npm install -g @anthropic-ai/claude-code"
echo "  6. Auth Claude: claude login"
