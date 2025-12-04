#!/usr/bin/env bash
# Environment configuration for setup

# Load environment variables from .env file if it exists
if [[ -f "$SCRIPT_DIR/../../.env" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/../../.env"
fi

# Default configuration
readonly DEFAULT_CONFIG=(
    "REPO_OWNER=${REPO_OWNER:-your-org}"
    "REPO_NAME=${REPO_NAME:-$(basename -s .git "$(git rev-parse --show-toplevel 2>/dev/null || echo "codespace-templates")")}"
    "DEFAULT_BRANCH=${DEFAULT_BRANCH:-main}"
    "TEAM_SLUG=${TEAM_SLUG:-maintainers}"
    "ENABLE_CODE_SCANNING=${ENABLE_CODE_SCANNING:-true}"
    "ENABLE_DEPENDABOT=${ENABLE_DEPENDABOT:-true}"
    "ENABLE_SECRET_SCANNING=${ENABLE_SECRET_SCANNING:-true}"
    "ENABLE_CONTAINER_SCANNING=${ENABLE_CONTAINER_SCANNING:-true}"
    "ENABLE_DEPENDENCY_REVIEW=${ENABLE_DEPENDENCY_REVIEW:-true}"
    "REQUIRE_CODE_OWNER_REVIEWS=${REQUIRE_CODE_OWNER_REVIEWS:-true}"
    "REQUIRED_APPROVING_REVIEW_COUNT=${REQUIRED_APPROVING_REVIEW_COUNT:-1}"
    "AUTO_MERGE_ENABLED=${AUTO_MERGE_ENABLED:-true}"
    "DELETE_HEAD_BRANCH=${DELETE_HEAD_BRANCH:-true}"
)

# Load default values
for config in "${DEFAULT_CONFIG[@]}"; do
    # shellcheck disable=SC2163
    export "$config"
    # shellcheck disable=SC2183
    declare -x "$config"
    # shellcheck disable=SC2155
    export "${config%%=*}"="${config#*=}"
done

# GitHub API configuration
export GITHUB_API_URL="${GITHUB_API_URL:-https://api.github.com}"

# Set GitHub token if available
if [[ -z "${GITHUB_TOKEN:-}" && -n "${GH_TOKEN:-}" ]]; then
    export GITHUB_TOKEN="$GH_TOKEN"
elif [[ -f "$HOME/.config/gh/hosts.yml" ]]; then
    # Try to get token from GitHub CLI config
    GITHUB_TOKEN=$(grep -A1 "github.com" "$HOME/.config/gh/hosts.yml" 2>/dev/null | grep -oP '(?<=oauth_token: ).*' || echo "")
    export GITHUB_TOKEN
fi

# Validate GitHub token
validate_github_token() {
    if [[ -z "${GITHUB_TOKEN}" ]]; then
        log_warning "GITHUB_TOKEN is not set. Some features may be limited."
        return 1
    fi
    
    # Check if token is valid
    if ! curl -s -H "Authorization: token $GITHUB_TOKEN" "$GITHUB_API_URL/user" &>/dev/null; then
        log_error "Invalid GitHub token. Please check your GITHUB_TOKEN environment variable."
        return 1
    fi
    
    return 0
}

# Load additional configurations
safe_source "$SCRIPT_DIR/config/codeql.sh"
safe_source "$SCRIPT_DIR/config/trivy.sh"
safe_source "$SCRIPT_DIR/config/dependabot.sh"

# Export environment variables
export -f validate_github_token
