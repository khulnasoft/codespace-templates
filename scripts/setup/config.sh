#!/bin/bash
# Configuration settings for repository setup

# Repository configuration
declare -A REPO_CONFIG=(
    [DEFAULT_OWNER]="${REPO_OWNER:-your-org}"
    [DEFAULT_REPO]="${REPO_NAME:-$(basename -s .git $(git config --get remote.origin.url 2>/dev/null) || echo "codespace-templates")}"
    [DEFAULT_BRANCH]="${DEFAULT_BRANCH:-main}"
    [TEAM_SLUG]="${TEAM_SLUG:-maintainers}"
)

# Security settings
declare -A SECURITY_CONFIG=(
    [CODE_SCANNING]="true"
    [SECRET_SCANNING]="true"
    [DEPENDABOT_ALERTS]="true"
    [AUTOMATED_SECURITY_FIXES]="true"
)

# Dependencies configuration
declare -A DEPENDENCIES=(
    [MIN_GH_CLI_VERSION]="2.0.0"
    [MIN_JQ_VERSION]="1.6"
    [REQUIRED_COMMANDS]="gh jq curl"
)

# Path configurations
declare -A PATHS=(
    [SCRIPTS_DIR]="$(dirname "${BASH_SOURCE[0]}")"
    [WORKFLOWS_DIR]="$(dirname "$(dirname "${BASH_SOURCE[0]}")/../.github/workflows")"
    [CODEQL_DIR]="$(dirname "$(dirname "${BASH_SOURCE[0]}")/../.github/codeql")"
)

# Export all configurations
export REPO_CONFIG SECURITY_CONFIG DEPENDENCIES PATHS
