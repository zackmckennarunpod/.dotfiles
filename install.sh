#!/bin/bash
# Dotfiles installation script
# Works non-interactively on devpod, interactively on macOS.
#
# Usage:
#   ./install.sh              # auto-detects environment
#   ./install.sh --headless   # force non-interactive (CI, devpod)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect environment
IS_DEVPOD=false
IS_MACOS=false
INTERACTIVE=true

[[ -f ~/.devbox-env ]] && IS_DEVPOD=true
[[ "$(uname)" == "Darwin" ]] && IS_MACOS=true
$IS_DEVPOD && INTERACTIVE=false
[[ "${1:-}" == "--headless" ]] && INTERACTIVE=false
[[ ! -t 0 ]] && INTERACTIVE=false  # no tty = non-interactive

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
section() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

create_symlink() {
    local source="$1"
    local target="$2"

    if [[ -f "$target" ]] && [[ ! -L "$target" ]]; then
        warn "Backing up $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi

    [[ -L "$target" ]] && rm "$target"
    ln -s "$source" "$target"
    info "Linked: $target -> $source"
}

echo "========================================="
echo "  Dotfiles Installation"
$IS_DEVPOD && echo "  (devpod mode — non-interactive)"
$IS_MACOS && ! $IS_DEVPOD && echo "  (macOS mode)"
echo "========================================="

# ── Core dotfiles (always) ───────────────────────────────────
section "Core Dotfiles"
DOTFILES=(
    "zshrc"
    "tmux.conf"
    "gitconfig"
    "gitignore_global"
    "p10k.zsh"
)

for file in "${DOTFILES[@]}"; do
    source_file="$DOTFILES_DIR/.$file"
    target_file="$HOME/.$file"
    if [[ -f "$source_file" ]]; then
        create_symlink "$source_file" "$target_file"
    else
        warn "Not found: $source_file, skipping"
    fi
done

if [[ -f "$DOTFILES_DIR/CLAUDE.md" ]]; then
    create_symlink "$DOTFILES_DIR/CLAUDE.md" "$HOME/.CLAUDE.md"
fi

# ── TPM (tmux plugin manager) ────────────────────────────────
section "Tmux Plugin Manager"
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    info "Installing TPM..."
    git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null \
        && info "TPM installed. Run 'prefix + I' in tmux to install plugins." \
        || warn "TPM clone failed (no network?)"
else
    info "TPM already installed"
fi

# ── macOS-only: Ghostty, Karabiner ───────────────────────────
if $IS_MACOS; then
    section "Ghostty Terminal"
    GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
    if [[ -d "/Applications/Ghostty.app" ]] || command -v ghostty &> /dev/null; then
        mkdir -p "$GHOSTTY_CONFIG_DIR"
        if [[ -f "$DOTFILES_DIR/.config/ghostty/config" ]]; then
            create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
        fi
    else
        info "Ghostty not found, skipping"
    fi

    section "Karabiner Elements"
    KARABINER_CONFIG_DIR="$HOME/.config/karabiner"
    if [[ -d "$KARABINER_CONFIG_DIR" ]] || command -v karabiner_cli &> /dev/null; then
        mkdir -p "$KARABINER_CONFIG_DIR"
        if [[ -f "$DOTFILES_DIR/.config/karabiner/karabiner.json" ]]; then
            create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$KARABINER_CONFIG_DIR/karabiner.json"
            info "Caps Lock = Ctrl (hold) / Escape (tap), Caps+A = tmux prefix"
        fi
    else
        info "Karabiner not found, skipping"
    fi
fi

# ── Neovim config ─────────────────────────────────────────────
section "Neovim"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [[ ! -d "$NVIM_CONFIG_DIR" ]]; then
    if $INTERACTIVE; then
        read -p "Install LazyVim starter config? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
            rm -rf "$NVIM_CONFIG_DIR/.git"
            info "LazyVim installed"
        fi
    else
        # Headless/devpod: install LazyVim non-interactively if nvim is present
        if command -v nvim &>/dev/null; then
            info "Installing LazyVim (headless)..."
            git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR" 2>/dev/null \
                && rm -rf "$NVIM_CONFIG_DIR/.git" \
                && info "LazyVim installed — plugins will load on first nvim launch" \
                || warn "LazyVim clone failed (no network?)"
        else
            info "nvim not found, skipping"
        fi
    fi
else
    info "Neovim config already exists"
fi

# ── Interactive-only: Beads ───────────────────────────────────
if $INTERACTIVE; then
    section "Beads (AI Agent Memory)"
    if ! command -v bd &> /dev/null; then
        read -p "Install Beads? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v brew &> /dev/null; then
                brew install steveyegge/beads/bd
            elif command -v npm &> /dev/null; then
                npm install -g @beads/bd
            else
                curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
            fi
        fi
    else
        info "Beads already installed"
    fi
fi

# ── Local override files ─────────────────────────────────────
section "Local Overrides"
if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" << 'EOF'
# Personal/work-specific zsh configuration
# Sourced at the end of .zshrc
EOF
    info "Created ~/.zshrc.local"
else
    info "~/.zshrc.local already exists"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    cat > "$HOME/.gitconfig.local" << 'EOF'
# Personal git config — included at the end of .gitconfig
[user]
    name = Your Name
    email = your.email@example.com
EOF
    info "Created ~/.gitconfig.local (update with your name and email)"
else
    info "~/.gitconfig.local already exists"
fi

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "========================================="
echo "  Done!"
echo "========================================="
if $INTERACTIVE; then
    echo ""
    info "Next steps:"
    echo "  1. Edit ~/.gitconfig.local with your name and email"
    echo "  2. Edit ~/.zshrc.local for personal aliases"
    echo "  3. source ~/.zshrc"
fi
echo ""
