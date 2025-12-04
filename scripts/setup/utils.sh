#!/bin/bash
# Utility functions for repository setup

# Load configuration
source "${BASH_SOURCE%/*}/config.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check GitHub CLI authentication
check_gh_auth() {
    if ! gh auth status &>/dev/null; then
        log_warn "GitHub CLI is not authenticated. Running 'gh auth login'..."
        gh auth login
    fi
}

# Validate configuration
validate_config() {
    local valid=true
    
    # Check required commands
    for cmd in ${DEPENDENCIES[REQUIRED_COMMANDS]}; do
        if ! command_exists "$cmd"; then
            log_error "$cmd is required but not installed."
            valid=false
        fi
    done
    
    # Check GitHub token
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        log_warn "GITHUB_TOKEN environment variable is not set. Some features may be limited."
    fi
    
    $valid || log_error "Configuration validation failed."
}

# Ensure directory exists
ensure_dir() {
    mkdir -p "$1" || log_error "Failed to create directory: $1"
}

# Run GitHub API command with error handling
github_api() {
    local method="${1:-GET}"
    local endpoint="$2"
    local data="${3:-}"
    
    local cmd=("gh" "api" "--method" "$method" "$endpoint")
    
    if [[ -n "$data" ]]; then
        cmd+=("--input" "$data")
    fi
    
    "${cmd[@]}" 2>/dev/null || {
        log_warn "Failed to execute GitHub API command. Retrying with debug output..."
        set -x
        "${cmd[@]}" || log_error "GitHub API command failed"
        set +x
    }
}
