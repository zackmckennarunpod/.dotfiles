#!/bin/bash
# RunPod Developer Helpers
# Source this file in your .zshrc.local:
#   source ~/.dotfiles/extras/runpod-helpers.sh

############################
# RunPod Links
############################
alias rpui="open https://runpod.io"
alias rpdev="open 'https://dev.runpod.io?ref=runpod'"
alias rpdocs="open 'https://docs.runpod.io'"
alias rpgithub="open 'https://github.com/runpod'"
alias rplinear="open 'https://linear.app/runpod'"

############################
# Pod Management (requires runpodctl)
############################

# List all pods
rp-pods() {
    if command -v runpodctl &> /dev/null; then
        runpodctl get pod
    else
        echo "runpodctl not installed. Install with: pip install runpodctl"
    fi
}

# SSH into a pod by ID
rp-ssh() {
    local pod_id="$1"
    if [[ -z "$pod_id" ]]; then
        echo "Usage: rp-ssh <pod_id>"
        return 1
    fi
    ssh "root@${pod_id}.runpod.io"
}

# Quick pod logs
rp-logs() {
    local pod_id="$1"
    if [[ -z "$pod_id" ]]; then
        echo "Usage: rp-logs <pod_id>"
        return 1
    fi
    if command -v runpodctl &> /dev/null; then
        runpodctl logs "$pod_id"
    else
        echo "runpodctl not installed"
    fi
}

############################
# GitHub Helpers
############################

# Sync fork with upstream
rp-sync-fork() {
    local repo="${1:-$(basename "$PWD")}"
    echo "Syncing fork: $repo"
    gh repo sync "$(gh api user --jq .login)/$repo" --force
}

# Open current repo in browser
rp-open() {
    gh repo view --web
}

# Create PR with RunPod template
rp-pr() {
    local title="$1"
    if [[ -z "$title" ]]; then
        echo "Usage: rp-pr \"PR Title\""
        return 1
    fi
    gh pr create --title "$title" --body "## Summary

## Test Plan

## Screenshots (if applicable)
"
}

############################
# Database Helpers (if using mysql)
############################

# Quick query dev database
rp-db-dev() {
    local query="$1"
    if [[ -z "$query" ]]; then
        echo "Usage: rp-db-dev \"SELECT * FROM ...\""
        return 1
    fi
    mysql -h "$RUNPOD_DEV_DB_HOST" -u "$RUNPOD_DEV_DB_USER" -p"$RUNPOD_DEV_DB_PASS" -e "$query"
}

############################
# Docker Helpers
############################

# Build and push to Docker Hub for RunPod (AMD64)
rp-docker-build() {
    local image_name="$1"
    local tag="${2:-latest}"
    local username="${DOCKER_USERNAME:-zackmckennarunpod}"

    if [[ -z "$image_name" ]]; then
        echo "Usage: rp-docker-build <image_name> [tag]"
        echo "Builds for AMD64 (required for RunPod)"
        return 1
    fi

    echo "Building ${username}/${image_name}:${tag} for linux/amd64..."
    docker buildx build --platform linux/amd64 -t "${username}/${image_name}:${tag}" --push .
}

############################
# Utility Functions
############################

# Open user in RunPod admin (paste user ID first)
rp-open-user() {
    local uid="${1:-$(pbpaste | tr -d '\n')}"
    local encoded=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$uid")
    open "https://runpod.io/console/admin/users/$encoded"
}

# Quick environment check
rp-env() {
    echo "RunPod Environment:"
    echo "  RUNPOD_API_KEY: ${RUNPOD_API_KEY:+set}"
    echo "  DOCKER_USERNAME: ${DOCKER_USERNAME:-not set}"
    echo "  Node: $(node --version 2>/dev/null || echo 'not installed')"
    echo "  Python: $(python3 --version 2>/dev/null || echo 'not installed')"
    echo "  runpodctl: $(command -v runpodctl &>/dev/null && echo 'installed' || echo 'not installed')"
}

echo "RunPod helpers loaded! Run 'rp-env' to check your environment."
