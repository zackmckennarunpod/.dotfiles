#!/bin/bash

# Dotfiles installation script
# This script creates symlinks from your home directory to the dotfiles in this repo

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Files to symlink
FILES=(
    "zshrc"
    "tmux.conf"
    "gitconfig"
    "gitignore_global"
    "p10k.zsh"
)

echo "Creating symlinks..."

for file in "${FILES[@]}"; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        # Backup existing file if it exists
        if [ -f "$HOME/.$file" ] && [ ! -L "$HOME/.$file" ]; then
            echo "Backing up existing ~/.$file to ~/.$file.backup"
            mv "$HOME/.$file" "$HOME/.$file.backup"
        fi
        
        # Remove existing symlink if it exists
        if [ -L "$HOME/.$file" ]; then
            rm "$HOME/.$file"
        fi
        
        # Create new symlink
        ln -s "$DOTFILES_DIR/$file" "$HOME/.$file"
        echo "Created symlink: ~/.$file -> $DOTFILES_DIR/$file"
    else
        echo "Warning: $DOTFILES_DIR/$file not found, skipping..."
    fi
done

echo "Dotfiles installation complete!"
echo "You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."