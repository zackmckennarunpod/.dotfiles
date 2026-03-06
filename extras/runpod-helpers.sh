#!/bin/bash
# Runpod Developer Helpers
# Auto-sourced by .zshrc when ~/.dotfiles exists

############################
# Cross-platform open command
############################
_rp_open() {
    if command -v open &>/dev/null; then
        open "$@"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$@"
    else
        echo "$@"
    fi
}

############################
# Runpod Shortcuts
############################
export RUNPOD_HOME="${RUNPOD_HOME:-$HOME/repos}"
alias rphome='cd $RUNPOD_HOME'

alias rpui='_rp_open https://runpod.io'
alias rpdev='_rp_open https://dev.runpod.io?ref=runpod'
alias rpdocs='_rp_open https://docs.runpod.io'
alias rpgithub='_rp_open https://github.com/runpod'
alias rplinear='_rp_open https://linear.app/runpod'

############################
# Database
############################

# Quick query dev database
rp-db-dev() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: rp-db-dev \"SELECT * FROM ...\""
        return 1
    fi
    mysql -h "${PLANETSCALE_HOST:-$RUNPOD_DEV_DB_HOST}" \
          -u "${PLANETSCALE_USER:-$RUNPOD_DEV_DB_USER}" \
          -p"${PLANETSCALE_PASSWORD:-$RUNPOD_DEV_DB_PASS}" \
          --ssl-mode=VERIFY_IDENTITY \
          -e "$query"
}

# Alias for quick access
alias BD_DB='rp-db-dev'

############################
# Pod Management
############################

rp-pods() {
    if command -v runpodctl &> /dev/null; then
        runpodctl get pod
    else
        echo "runpodctl not installed"
    fi
}

rp-ssh() {
    local pod_id="$1"
    [[ -z "$pod_id" ]] && { echo "Usage: rp-ssh <pod_id>"; return 1; }
    # Runpod SSH goes through the TCP proxy — port 22 maps to the SSH proxy endpoint.
    ssh "root@${pod_id}-22.proxy.runpod.net"
}

rp-logs() {
    local pod_id="$1"
    [[ -z "$pod_id" ]] && { echo "Usage: rp-logs <pod_id>"; return 1; }
    if command -v runpodctl &> /dev/null; then
        runpodctl logs "$pod_id"
    else
        echo "runpodctl not installed"
    fi
}

############################
# GitHub Helpers
############################

rp-sync-fork() {
    local repo="${1:-$(basename "$PWD")}"
    echo "Syncing fork: $repo"
    gh repo sync "$(gh api user --jq .login)/$repo" --force
}

rp-open() {
    gh repo view --web 2>/dev/null || echo "Not in a git repo"
}

rp-pr() {
    local title="$1"
    [[ -z "$title" ]] && { echo "Usage: rp-pr \"PR Title\""; return 1; }
    gh pr create --title "$title" --body "## Summary

## Test Plan

## Screenshots (if applicable)
"
}

############################
# Docker (AMD64 for Runpod)
############################

rp-docker-build() {
    local image_name="$1"
    local tag="${2:-latest}"
    local username="${DOCKER_USERNAME:-zackmckennarunpod}"

    [[ -z "$image_name" ]] && { echo "Usage: rp-docker-build <image_name> [tag]"; return 1; }

    echo "Building ${username}/${image_name}:${tag} for linux/amd64..."
    docker buildx build --platform linux/amd64 -t "${username}/${image_name}:${tag}" --push .
}

############################
# Environment Check
############################

rp-env() {
    echo "Runpod Environment:"
    echo "  RUNPOD_HOME:     ${RUNPOD_HOME:-not set}"
    echo "  RUNPOD_API_URL:  ${RUNPOD_API_URL:-not set}"
    echo "  RP_API_KEY:      ${RP_API_KEY:+set}"
    echo "  DOCKER_USERNAME: ${DOCKER_USERNAME:-not set}"
    echo "  PLANETSCALE:     ${PLANETSCALE_HOST:+connected}"
    echo "  Node:    $(node --version 2>/dev/null || echo 'not installed')"
    echo "  Python:  $(python3 --version 2>/dev/null || echo 'not installed')"
    echo "  gh:      $(gh --version 2>/dev/null | head -1 || echo 'not installed')"
    [[ -f ~/.devbox-env ]] && echo "  DevPod:  yes" || echo "  DevPod:  no"
}
