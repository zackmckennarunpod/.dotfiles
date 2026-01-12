############################
# Zsh Configuration
# Generalized dotfiles - add personal overrides to ~/.zshrc.local
############################

############################
# History
############################
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

############################
# Environment
############################
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'

# Homebrew (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
[[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Local scripts and tools
[[ -d "$HOME/scripts" ]] && export PATH="$HOME/scripts:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

############################
# Navigation
############################
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias c='clear'
alias x='exit'

############################
# Editor
############################
alias nv="nvim"
alias zshconfig='nvim ~/.zshrc'
alias sshconfig='nvim ~/.ssh/config'
alias gitconfig='nvim ~/.gitconfig'
alias sc='source ~/.zshrc'

############################
# Git
############################
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpull='git pull'

############################
# Utilities
############################
alias rnm='rm -rf node_modules'
alias ip='ipconfig getifaddr en0 2>/dev/null || hostname -I 2>/dev/null | awk "{print \$1}"'

# Fix grep alias conflicts
unset -f grep 2>/dev/null
unalias grep 2>/dev/null
alias grep='grep --color=auto'

############################
# Shell Enhancements
############################

# Starship prompt (if installed)
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Zoxide (if installed)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# NVM (if installed via homebrew)
if [[ -f /opt/homebrew/opt/nvm/nvm.sh ]]; then
  source /opt/homebrew/opt/nvm/nvm.sh
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ASDF (if installed)
if [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
  source /opt/homebrew/opt/asdf/libexec/asdf.sh
  fpath=(${ASDF_DIR}/completions $fpath)
fi

# Zsh syntax highlighting (if installed)
if [[ -f $(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

############################
# Completion
############################
autoload -Uz compinit && compinit

############################
# Oh-My-Zsh
############################
if [[ -f $ZSH/oh-my-zsh.sh ]]; then
  source $ZSH/oh-my-zsh.sh
fi

############################
# Powerlevel10k Theme
############################
if [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

############################
# Znap Plugin Manager (optional)
############################
ZNAP_DIR="$HOME/.znap"
if [[ -r "$ZNAP_DIR/znap.zsh" ]]; then
  source "$ZNAP_DIR/znap.zsh"
  znap source marlonrichert/zsh-autocomplete
fi

############################
# Functions
############################

# Open repo in neovim with tmux session
nvimrepo() {
  local BASE_DIR="${REPO_BASE_DIR:-$HOME/Developer}"
  local REPO_NAME="$1"
  local REPO_PATH=""

  if [[ -z "$REPO_NAME" ]]; then
    if command -v fzf &> /dev/null; then
      REPO_PATH=$(find "$BASE_DIR" -mindepth 1 -maxdepth 3 -type d -name ".git" 2>/dev/null | xargs -I {} dirname {} | fzf)
    else
      echo "Usage: nvimrepo <repo-name> (or install fzf for interactive selection)"
      return 1
    fi
  else
    local matches=($(find "$BASE_DIR" -mindepth 1 -maxdepth 3 -type d -iname "*$REPO_NAME*" 2>/dev/null))
    local match_count="${#matches[@]}"

    if [[ "$match_count" -eq 0 ]]; then
      echo "Repo not found: $REPO_NAME"
      return 1
    elif [[ "$match_count" -eq 1 ]]; then
      REPO_PATH="${matches[0]}"
    else
      if command -v fzf &> /dev/null; then
        REPO_PATH=$(printf "%s\n" "${matches[@]}" | fzf --prompt="Multiple matches for '$REPO_NAME': ")
      else
        echo "Multiple matches found:"
        printf "%s\n" "${matches[@]}"
        return 1
      fi
    fi
  fi

  if [[ -z "$REPO_PATH" || ! -d "$REPO_PATH" ]]; then
    echo "Invalid selection or path"
    return 1
  fi

  local SESSION_NAME=$(basename "$REPO_PATH")

  if [[ -n "$TMUX" ]]; then
    tmux new-window -c "$REPO_PATH" -n "$SESSION_NAME" "nvim ."
  else
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      tmux attach-session -t "$SESSION_NAME"
    else
      tmux new-session -s "$SESSION_NAME" -c "$REPO_PATH" "nvim ."
    fi
  fi
}

# Find AWS Lambda functions
findLambda() {
  aws lambda list-functions --query 'Functions[*].FunctionName' --output text | tr '\t' '\n' | grep "$1"
}

# Find AWS SQS queues
findQueue() {
  aws sqs list-queues --query 'QueueUrls' --output text | tr '\t' '\n' | grep "$1"
}

############################
# Local Overrides
# Create ~/.zshrc.local for personal/work-specific config
############################
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
