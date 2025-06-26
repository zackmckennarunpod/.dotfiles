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
- `CLAUDE.md` - Development guidelines and practices for Claude
- `.config/claude-code/settings.json` - Claude Code CLI configuration (template)
- `claude-desktop-config.json` - Claude Desktop MCP server configuration (template)

## What the install script does

- Creates symlinks from your home directory to the dotfiles in this repo
- Backs up existing dotfiles with `.backup` extension
- Makes it easy to keep your dotfiles in sync across multiple machines

## Claude Configuration

After installation, you'll need to configure your Claude settings with actual API keys:

### Claude Code CLI
Edit `~/.config/claude-code/settings.json` and replace the placeholder values:
```json
{
  "environment": {
    "TEST_USER_JWT": "your_actual_jwt_token",
    "TEST_USER_ADMIN_JWT": "your_actual_admin_jwt_token"
  }
}
```

### Claude Desktop
Edit `~/Library/Application Support/Claude/claude_desktop_config.json` and replace the placeholder values:
```json
{
  "mcpServers": {
    "linear": {
      "env": {
        "LINEAR_API_KEY": "your_actual_linear_api_key"
      }
    },
    "stripe": {
      "args": [
        "--api-key=your_actual_stripe_api_key"
      ]
    }
  }
}
```

### Development Guidelines
The `CLAUDE.md` file contains comprehensive development guidelines and practices. It will be symlinked to your home directory for easy reference by Claude when working on projects.

## Updating

After making changes to any dotfile, simply commit and push to keep your configurations synchronized across machines.