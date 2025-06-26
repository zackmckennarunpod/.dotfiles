                      ############################
# 🧠 Zsh History Behavior
############################
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# Fix grep conflict for functions
unset -f grep 2>/dev/null
unalias grep 2>/dev/null
alias grep='grep --color=auto'

setopt INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

#########################/nvim && nvim ."
alias vdot="cd ~/.config/nvim && nvim ."
alias rcnv="cd ~/.config/nvim && source ~/.zshrc"

function nvimrepo() {
  local BASE_DIR="$HOME/Repos/github.com"
  local REPO_NAME="$1"
  if [[ -z "$REPO_NAME" ]]; then
    REPO_NAME=$(find "$BASE_DIR" -mindepth 1 -maxdepth 1 -type d | sed "s|$BASE_DIR/||" | fzf)
  fi
  local REPO_PATH="$BASE_DIR/$REPO_NAME"
  [[ -d "$REPO_PATH" ]] && cd "$REPO_PATH" && nvim .
}

alias ff='tmux new-session -d -s "$(basename "$PWD")" "nvim ."; tmux attach'

############################
# 🧬 Git Shortcuts
############################
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gb='git branch'
alias gl='git log --oneline --graph --decorate'

alias gadd='git add .'
alias ginit='git init .'
alias gits='git status'
alias gitd='git diff'
alias gitl='git log --oneline'
alias gcm='/Users/zackmckenna/scripts/commit.sh'
alias gsm='/Users/zackmckenna/scripts/git-stage.sh'

############################
# 🚀 RunPod Aliases
##############################
# 🛠️  Tooling and Environment
############################
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
eval "$(/opt/homebrew/bin/brew shellenv)"

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# BUN
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# MySQL, Scripts, Dev Tools
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH="$HOME/Developer/tools:$PATH"

############################
# 🌟 Shell Enhancements
############################

# Starship prompt
eval "$(starship init zsh)"

# Zoxide: directory jumping
eval "$(zoxide init zsh)"
alias zf='zoxide query -l | fzf-tmux | xargs -o tmux n                     ew-window -c'

# ASDF                                      #
alias rpui="open https://runpod.io"
alias rpuid="open 'https://dev.runpod.io?ref=runpod'"
alias rpmui="open 'https://github.com/runpod/main-ui'"
alias rprp="open 'https://github.com/runpod/RunPod'"
alias runrp="cd ~/Repos/github.com/zackmckenna/RunPod && yarn dev"
alias runrpui="cd ~/Repos/github.com/runpod/main-ui/console && yarn dev"
alias rpp="open 'https://github.com/orgs/runpod/projects/6'"
alias linear="open 'https://linear.app/runpod/team/E/active'"
alias syncrp="gh repo sync zackmckenna/main-ui && gh repo sync zackmckenna/RunPod"

############################
# 🧭 Navigation + General
############################
alias ..='cd ..'
alias ...='cd ../..'
alias home='cd ~'
alias c='clear'
alias x='exit'
alias e='code -n ~/ ~/.zshrc ~/.aliases ~/.colors ~/.hooks'
alias sc='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'
alias sshconfig='nvim ~/.ssh/config'
alias gitconfig='nvim ~/.gitconfig'
alias ip='ipconfig getifaddr en0'
alias getip="dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com"

###                                     #########################
# 🧼 Cleanup / Utilities
############################
alias rnm='rm -rf node_modules'
alias rap='rm -rf build coverage node_modules package-lock.json && npm i'
alias npk='npx npkill'
alias nkp='npx kill-port '
alias nfk='npx fkill-cli'
alias tnt='fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim'

############################
# 🧪 Custom Functions
############################
findLambda() {
  aws lambda list-functions --query 'Functions[*].FunctionName' --output text | tr '\t' '\n' | grep "$1"
}

findQueue() {
  aws sqs list-queues --query 'QueueUrls' --output text | tr '\t' '\n' | grep "$1"
}


. /opt/homebrew/opt/asdf/libexec/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)

# Syntax Highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completion
autoload -Uz compinit && compinit

# NVM
source /opt/homebrew/opt/nvm/nvm.sh
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

############################
# 🔧 Plugin: Znap (Fast Load)
############################
[[ -r ~/Repos/znap/znap.zsh ]] ||
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/Repos/znap
source ~/Repos/znap/znap.zsh
znap source marlonrichert/zsh-autocomplete

############################
# 🖼️ Theme
############################
alias editzsh="nvim ~/.zshrc"
source $ZSH/oh-my-zsh.sh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
function nvimrepo() {
  local BASE_DIR="$HOME/Repos/github.com"
  local REPO_NAME="$1"
  local REPO_PATH=""

  if [[ -z "$REPO_NAME" ]]; then
    REPO_PATH=$(find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type d | fzf)
  else
    local matches=($(find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type d -iname "*$REPO_NAME*"))
    local match_count="${#matches[@]}"

    if [[ "$match_count" -eq 0 ]]; then
      echo "❌ Repo not found: $REPO_NAME"
      return 1
    elif [[ "$match_count" -eq 1 ]]; then
      REPO_PATH="${matches[0]}"
    else
      REPO_PATH=$(printf "%s\n" "${matches[@]}" | fzf --prompt="Multiple matches for '$REPO_NAME': ")
    fi
  fi

  if [[ -z "$REPO_PATH" || ! -d "$REPO_PATH" ]]; then
    echo "❌ Invalid selection or path"
    return 1
  fi

  local SESSION_NAME=$(basename "$REPO_PATH")

  if [[ -n "$TMUX" ]]; then
    echo "🪟 Opening new tmux window in session: $SESSION_NAME"
    tmux new-window -c "$REPO_PATH" -n "$SESSION_NAME" "nvim ."
  else
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
      echo "⚡ Attaching to existing session: $SESSION_NAME"
      tmux attach-session -t "$SESSION_NAME"
    else
      echo "🚀 Creating new tmux session: $SESSION_NAME"
      tmux new-session -s "$SESSION_NAME" -c "$REPO_PATH" "nvim ."
    fi
  fi
}

alias openuser='uid=$(pbpaste | tr -d "\n"); encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$uid"); open "https://runpod.io/console/admin/users/$encoded"'
############################
# 🧠 LazyVim / eeovim Shortcuts
############################

alias nv="nvim"
alias nvdot="nvim ~/.config/nvim"
alias nvl="cd ~/.config"

. "$HOME/.local/share/../bin/env"
export PATH=~/.npm-global/bin:$PATH
alias claude="/Users/zackmckenna/.claude/local/claude"
