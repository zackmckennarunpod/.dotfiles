# Dotfiles

A minimal, opinionated dotfiles setup for macOS developers using Zsh, Neovim, and tmux.

## How It Works

This repo uses **symlinks** to keep your config files in sync:

```
~/.zshrc → ~/.dotfiles/.zshrc          # Shared config (tracked)
~/.zshrc.local                          # Your personal config (not tracked)
```

**Key concept**: Shared configs are symlinked from this repo. Personal stuff (name, email, work aliases) goes in `.local` files that aren't tracked.

## What's Included

| File | Description |
|------|-------------|
| `.zshrc` | Zsh configuration with sensible defaults |
| `.tmux.conf` | Tmux with vim-style navigation |
| `.gitconfig` | Git settings (auto remote, main branch) |
| `.gitignore_global` | Common ignores (node_modules, .env, etc.) |
| `.p10k.zsh` | Powerlevel10k prompt theme |
| `CLAUDE.md` | AI dev guidelines (TDD, TypeScript, FP) |
| `karabiner.json` | Caps Lock → Ctrl (hold) / Escape (tap) |
| `extras/runpod-helpers.sh` | Optional RunPod-specific aliases |

## Quick Start

```bash
# 1. Install prerequisites
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install neovim tmux git gh starship zoxide fzf zsh-syntax-highlighting powerlevel10k
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 2. Clone and install
git clone https://github.com/zackmckennarunpod/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install.sh

# 3. Set your identity
nvim ~/.gitconfig.local
# Add your name and email

# 4. Restart terminal
source ~/.zshrc
```

## Key Features

### Karabiner Elements
**Caps Lock becomes a superpower:**
- **Hold** = Control (for tmux, vim keybindings)
- **Tap** = Escape (for vim mode switching)

Install: `brew install --cask karabiner-elements`

### Tmux
- **Prefix**: `Ctrl-b` (with Caps Lock remapped, just hold Caps + b)
- **Pane navigation**: `Ctrl-h/j/k/l` (vim-style, works inside neovim too)
- **Split panes**: `prefix + |` (vertical), `prefix + -` (horizontal)
- **Resize panes**: `prefix + h/j/k/l`
- **Reload config**: `prefix + r`

### Neovim (LazyVim)
The install script optionally sets up [LazyVim](https://www.lazyvim.org/) - a modern Neovim config with:
- LSP, completions, formatting out of the box
- Telescope for fuzzy finding
- Which-key for keybinding hints
- And much more

### Zsh
- History sharing across sessions
- Starship prompt (fast, customizable)
- Zoxide for smart `cd` (`z myproject` jumps to ~/work/myproject)
- Syntax highlighting
- `nvimrepo` function to open repos in tmux+neovim

## Customization

### Personal Config (Not Tracked)

**~/.zshrc.local** - Your aliases, paths, secrets:
```bash
# Work stuff
export WORK_DIR="$HOME/work"
alias myapp="cd $WORK_DIR/myapp && nvim ."

# API keys (never commit these!)
export API_KEY="..."

# RunPod developers
source ~/.dotfiles/extras/runpod-helpers.sh
```

**~/.gitconfig.local** - Your identity:
```gitconfig
[user]
    name = Your Name
    email = you@company.com
    signingkey = ABC123
```

### RunPod Developers

Source the helpers in your `.zshrc.local`:
```bash
source ~/.dotfiles/extras/runpod-helpers.sh
```

This gives you:
- `rpui`, `rpdev`, `rplinear` - Quick links
- `rp-pods`, `rp-ssh`, `rp-logs` - Pod management
- `rp-docker-build` - Build AMD64 images for RunPod
- `rp-pr` - Create PR with template
- And more

## File Structure

```
~/.dotfiles/
├── .zshrc                    # Main shell config
├── .tmux.conf                # Tmux config
├── .gitconfig                # Git config (includes .local)
├── .gitignore_global         # Global gitignore
├── .p10k.zsh                 # Prompt theme
├── CLAUDE.md                 # AI development guidelines
├── install.sh                # Installation script
├── LICENSE                   # MIT
├── .config/
│   ├── karabiner/
│   │   └── karabiner.json    # Caps Lock remapping
│   └── claude-code/
│       └── settings.json     # Claude Code config
├── extras/
│   └── runpod-helpers.sh     # Optional RunPod aliases
└── claude-desktop-config.json
```

## Updating

Changes to dotfiles take effect immediately (they're symlinks):

```bash
cd ~/.dotfiles
git pull  # Get updates

# Or push your changes
git add -A && git commit -m "Update config" && git push
```

## Uninstalling

```bash
# Remove symlinks
rm ~/.zshrc ~/.tmux.conf ~/.gitconfig ~/.gitignore_global ~/.p10k.zsh

# Restore backups
mv ~/.zshrc.backup ~/.zshrc  # etc.
```

## License

MIT - see [LICENSE](LICENSE)
