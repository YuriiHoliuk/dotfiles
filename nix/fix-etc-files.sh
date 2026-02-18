#!/bin/bash
# Fix nix-darwin setup issues
# Run with: sudo bash ~/dotfiles/nix/fix-etc-files.sh

set -e

echo "=== Fixing nix-darwin setup issues ==="

# 1. Fix /etc/zshrc and /etc/zprofile
echo ""
echo "1. Removing /etc/zshrc and /etc/zprofile..."

if [ -f /etc/zshrc ]; then
    rm -f /etc/zshrc
    echo "   Removed /etc/zshrc"
fi

if [ -f /etc/zprofile ]; then
    rm -f /etc/zprofile
    echo "   Removed /etc/zprofile"
fi

# 2. Setup Intel Homebrew directory structure for Rosetta
echo ""
echo "2. Setting up Intel Homebrew at /usr/local..."

mkdir -p /usr/local/Homebrew/Library
chown -R yuriiholiuk:admin /usr/local/Homebrew
echo "   Created /usr/local/Homebrew/Library"

echo ""
echo "=== Done! ==="
echo "Now run: cd ~/dotfiles/nix && darwin-rebuild switch --flake .#Yuriis-MacBook-Pro"
