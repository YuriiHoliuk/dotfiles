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
# Remove nix.conf created in step 2 (stow will link the one from home-files)
rm -f ~/.config/nix/nix.conf
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

# --- 8. Install ghostty terminfo (for SSH from Ghostty/cmux) ---
if ! infocmp xterm-ghostty &> /dev/null; then
    echo "Installing ghostty terminfo..."
    if [ -f "$HOME/dotfiles/ghostty.terminfo" ]; then
        tic -x "$HOME/dotfiles/ghostty.terminfo"
        echo "ghostty terminfo installed."
    else
        echo "WARNING: ghostty.terminfo not found in dotfiles. Copy it from Mac:"
        echo "  scp /tmp/ghostty.terminfo jetson:~/dotfiles/ghostty.terminfo"
    fi
else
    echo "ghostty terminfo already installed, skipping."
fi

# --- 9. Generate SSH key for GitHub ---
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

# --- 10. Add docker group ---
if ! groups | grep -q docker; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Added to docker group. Log out and back in for it to take effect."
fi

# --- 11. Fix iptables for Docker + Tailscale ---
# Tegra kernel lacks nftables modules (xt_connmark, xt_conntrack, addrtype).
# Docker and Tailscale both need iptables-legacy on Jetson.
CURRENT_IPTABLES=$(readlink -f /usr/sbin/iptables 2>/dev/null || true)
if [[ "$CURRENT_IPTABLES" == *"nft"* ]]; then
    echo "Switching iptables to legacy (Tegra kernel lacks nftables modules)..."
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi

# --- 12. Configure Docker DNS ---
# Tailscale overwrites /etc/resolv.conf with 100.100.100.100 which Docker's
# internal DNS can't use as upstream. Explicit DNS in daemon.json fixes this.
if [ -f /etc/docker/daemon.json ]; then
    if ! grep -q '"dns"' /etc/docker/daemon.json; then
        echo "Adding DNS servers to Docker daemon config..."
        # Use jq if available, otherwise python3
        if command -v jq &> /dev/null; then
            sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
            jq '. + {"dns": ["1.1.1.1", "1.0.0.1"]}' /etc/docker/daemon.json.bak | sudo tee /etc/docker/daemon.json > /dev/null
        else
            echo "WARNING: jq not available, manually add '\"dns\": [\"1.1.1.1\", \"1.0.0.1\"]' to /etc/docker/daemon.json"
        fi
    fi
else
    echo "Docker daemon.json not found. If Docker is installed, create it manually."
fi

# --- 13. Fix Tailscale DNS ---
# Tailscale's DNS relay (100.100.100.100) can't forward queries due to iptables
# issues on Tegra. Disable Tailscale DNS management and use systemd-resolved
# with Pi-hole + Cloudflare fallback instead.
if command -v tailscale &> /dev/null; then
    echo "Configuring Tailscale (disable DNS, disable serve)..."
    sudo tailscale set --accept-dns=false

    SERVE_STATUS=$(sudo tailscale serve status 2>&1 || true)
    if echo "$SERVE_STATUS" | grep -q "proxy"; then
        sudo tailscale serve off
    fi
fi

# --- 14. Configure system DNS ---
if systemctl is-active --quiet systemd-resolved; then
    echo "Configuring systemd-resolved DNS..."
    sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
    MAIN_IFACE=$(ip route show default | awk '{print $5}' | head -1)
    if [[ -n "$MAIN_IFACE" ]]; then
        sudo resolvectl dns "$MAIN_IFACE" 192.168.1.100 1.1.1.1
        echo "DNS: Pi-hole (192.168.1.100) + Cloudflare (1.1.1.1) on $MAIN_IFACE"
    fi
fi

echo ""
echo "=== Setup complete! ==="
echo "Next steps:"
echo "  1. Log out and back in (for zsh + docker group)"
echo "  2. Open tmux: tmux new-session -s main"
echo "  3. Install tmux plugins: prefix + I"
echo "  4. Open neovim to trigger plugin install: nvim"
echo "  5. Install Claude Code: npm install -g @anthropic-ai/claude-code && claude login"
echo "  6. Set up homelab: cd ~/homelab/repo && bash scripts/bootstrap.sh"
echo "  7. Add SSH key to GitHub: https://github.com/settings/ssh/new"
