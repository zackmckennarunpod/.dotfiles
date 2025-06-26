# Dotfiles

Personal dotfiles repository for macOS setup.

## Installation

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

## Files Included

- `.zshrc` - Zsh configuration
- `.tmux.conf` - Tmux configuration
- `.gitconfig` - Git configuration
- `.gitignore_global` - Global gitignore
- `.p10k.zsh` - Powerlevel10k theme configuration

## What the install script does

- Creates symlinks from your home directory to the dotfiles in this repo
- Backs up existing dotfiles with `.backup` extension
- Makes it easy to keep your dotfiles in sync across multiple machines

## Updating

After making changes to any dotfile, simply commit and push to keep your configurations synchronized across machines.