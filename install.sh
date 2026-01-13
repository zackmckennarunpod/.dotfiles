#!/bin/bash

# Dotfiles installation script
# Creates symlinks from home directory to dotfiles in this repo
# Backs up existing files before overwriting

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
section() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

# Dotfiles to symlink (without leading dot - will be added)
DOTFILES=(
    "zshrc"
    "tmux.conf"
    "gitconfig"
    "gitignore_global"
    "p10k.zsh"
)

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"

    # Backup existing file if it exists and isn't a symlink
    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        warn "Backing up existing $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi

    # Remove existing symlink
    if [[ -L "$target" ]]; then
        rm "$target"
    fi

    # Create new symlink
    ln -s "$source" "$target"
    info "Created symlink: $target -> $source"
}

echo "========================================="
echo "  Dotfiles Installation"
echo "========================================="

section "Core Dotfiles"
for file in "${DOTFILES[@]}"; do
    source_file="$DOTFILES_DIR/.$file"
    target_file="$HOME/.$file"

    if [[ -f "$source_file" ]]; then
        create_symlink "$source_file" "$target_file"
    else
        warn "Source file not found: $source_file, skipping..."
    fi
done

# Install CLAUDE.md
if [[ -f "$DOTFILES_DIR/CLAUDE.md" ]]; then
    create_symlink "$DOTFILES_DIR/CLAUDE.md" "$HOME/.CLAUDE.md"
fi

# Note: Claude Code and Claude Desktop configs are not included
# as they contain API keys. Configure those manually.

section "Ghostty Terminal"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
if [[ -d "/Applications/Ghostty.app" ]] || command -v ghostty &> /dev/null; then
    mkdir -p "$GHOSTTY_CONFIG_DIR"
    if [[ -f "$DOTFILES_DIR/.config/ghostty/config" ]]; then
        create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
        info "Ghostty configured with Nerd Font and dark theme"
    fi
else
    warn "Ghostty not installed, skipping config..."
    info "Install with: brew install --cask ghostty"
fi

section "Karabiner Elements (Caps Lock → Ctrl/Escape + tmux shortcut)"
KARABINER_CONFIG_DIR="$HOME/.config/karabiner"
if [[ -d "$KARABINER_CONFIG_DIR" ]] || command -v karabiner_cli &> /dev/null; then
    mkdir -p "$KARABINER_CONFIG_DIR"
    if [[ -f "$DOTFILES_DIR/.config/karabiner/karabiner.json" ]]; then
        create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$KARABINER_CONFIG_DIR/karabiner.json"
        info "Karabiner: Caps Lock = Ctrl (hold) / Escape (tap)"
        info "Karabiner: Caps+A = Ctrl+B (tmux prefix shortcut)"
    fi
else
    warn "Karabiner Elements not installed, skipping..."
    info "Install with: brew install --cask karabiner-elements"
fi

section "Neovim (LazyVim)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    read -p "Install LazyVim starter config? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
        rm -rf "$NVIM_CONFIG_DIR/.git"
        info "LazyVim installed! Open nvim to complete setup."
    else
        info "Skipping Neovim config"
    fi
else
    info "Neovim config already exists at $NVIM_CONFIG_DIR"
fi

section "Beads (AI Agent Memory System)"
if command -v bd &> /dev/null; then
    info "Beads already installed: $(bd --version 2>/dev/null || echo 'installed')"
else
    read -p "Install Beads (git-backed issue tracker for AI agents)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v brew &> /dev/null; then
            info "Installing Beads via Homebrew..."
            brew install steveyegge/beads/bd
        elif command -v npm &> /dev/null; then
            info "Installing Beads via npm..."
            npm install -g @beads/bd
        elif command -v go &> /dev/null; then
            info "Installing Beads via Go..."
            go install github.com/steveyegge/beads/cmd/bd@latest
        else
            info "Installing Beads via shell script..."
            curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
        fi
        info "Beads installed! Run 'bd init' in a git repo to get started."
    else
        info "Skipping Beads"
    fi
fi

section "Local Override Files"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" << 'EOF'
# Personal/work-specific zsh configuration
# This file is sourced at the end of .zshrc
# Add your custom aliases, functions, and environment variables here

# Example:
# export REPO_BASE_DIR="$HOME/work/repos"
# alias myproject="cd ~/work/myproject"

# RunPod developers: uncomment to load helpers
# source ~/.dotfiles/extras/runpod-helpers.sh
EOF
    info "Created ~/.zshrc.local (add your personal config here)"
else
    info "~/.zshrc.local already exists"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    cat > "$HOME/.gitconfig.local" << 'EOF'
# Personal git configuration
# This file is included at the end of .gitconfig

[user]
    name = Your Name
    email = your.email@example.com

# Add any personal git settings here
EOF
    info "Created ~/.gitconfig.local (update with your name and email)"
else
    info "~/.gitconfig.local already exists"
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
info "Next steps:"
echo "  1. Edit ~/.gitconfig.local with your name and email"
echo "  2. Edit ~/.zshrc.local for personal aliases/config"
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo ""
info "Optional:"
echo "  - Update Claude config with API keys"
echo "  - Install Karabiner Elements for Caps Lock remapping"
echo "  - Customize your Neovim setup"
echo ""
