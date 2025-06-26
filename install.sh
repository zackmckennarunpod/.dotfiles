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
    "CLAUDE.md"
)

# Claude config files with special handling
CLAUDE_CODE_CONFIG_DIR="$HOME/.config/claude-code"
CLAUDE_DESKTOP_CONFIG_DIR="$HOME/Library/Application Support/Claude"

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

# Handle Claude config files
echo "Setting up Claude configuration files..."

# Create Claude Code config directory if it doesn't exist
if [ ! -d "$CLAUDE_CODE_CONFIG_DIR" ]; then
    mkdir -p "$CLAUDE_CODE_CONFIG_DIR"
    echo "Created directory: $CLAUDE_CODE_CONFIG_DIR"
fi

# Symlink Claude Code settings
if [ -f "$DOTFILES_DIR/.config/claude-code/settings.json" ]; then
    if [ -f "$CLAUDE_CODE_CONFIG_DIR/settings.json" ] && [ ! -L "$CLAUDE_CODE_CONFIG_DIR/settings.json" ]; then
        echo "Backing up existing Claude Code settings to $CLAUDE_CODE_CONFIG_DIR/settings.json.backup"
        mv "$CLAUDE_CODE_CONFIG_DIR/settings.json" "$CLAUDE_CODE_CONFIG_DIR/settings.json.backup"
    fi
    
    if [ -L "$CLAUDE_CODE_CONFIG_DIR/settings.json" ]; then
        rm "$CLAUDE_CODE_CONFIG_DIR/settings.json"
    fi
    
    ln -s "$DOTFILES_DIR/.config/claude-code/settings.json" "$CLAUDE_CODE_CONFIG_DIR/settings.json"
    echo "Created symlink: $CLAUDE_CODE_CONFIG_DIR/settings.json -> $DOTFILES_DIR/.config/claude-code/settings.json"
fi

# Symlink Claude Desktop config
if [ -f "$DOTFILES_DIR/claude-desktop-config.json" ]; then
    if [ ! -d "$CLAUDE_DESKTOP_CONFIG_DIR" ]; then
        echo "Warning: Claude Desktop config directory not found at $CLAUDE_DESKTOP_CONFIG_DIR"
        echo "You may need to install Claude Desktop first."
    else
        if [ -f "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json" ] && [ ! -L "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json" ]; then
            echo "Backing up existing Claude Desktop config to $CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json.backup"
            mv "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json" "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json.backup"
        fi
        
        if [ -L "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json" ]; then
            rm "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
        fi
        
        ln -s "$DOTFILES_DIR/claude-desktop-config.json" "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
        echo "Created symlink: $CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json -> $DOTFILES_DIR/claude-desktop-config.json"
    fi
fi

echo "Dotfiles installation complete!"
echo "You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."
echo ""
echo "IMPORTANT: Remember to update the Claude config files with your actual API keys:"
echo "  - ~/.config/claude-code/settings.json"
echo "  - ~/Library/Application Support/Claude/claude_desktop_config.json"