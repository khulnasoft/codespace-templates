#!/usr/bin/env bash
# Utility functions

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Check if running in a container
is_container() {
    [[ -f /.dockerenv ]] || grep -q '\/docker\/' /proc/1/cgroup 2>/dev/null
}

# Get OS information
get_os_info() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ $(uname -s) == "Darwin" ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check if running in WSL (Windows Subsystem for Linux)
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -e /run/WSL/"${WSL_DISTRO_NAME:-}" ]]
}

# Check if running in GitHub Codespaces
is_codespaces() {
    [[ -n "${CODESPACES:-}" ]]
}

# Check if running in GitLab CI
is_gitlab_ci() {
    [[ -n "${GITLAB_CI:-}" ]]
}

# Check if running in GitHub Actions
is_github_actions() {
    [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Check if current directory is a git repository
is_git_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null
}

# Get git repository root directory
git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}

# Check if file exists and is not empty
file_exists() {
    [[ -s "$1" ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    mkdir -p "$1" || return 1
}

# Create file with directory structure
create_file() {
    local file_path="$1"
    local content="${2:-}"
    
    # Create directory structure if it doesn't exist
    mkdir -p "$(dirname "$file_path")" || return 1
    
    # Create or update file
    if [[ -n "$content" ]]; then
        echo "$content" > "$file_path"
    else
        touch "$file_path"
    fi
}

# Run a command with retries
run_with_retry() {
    local cmd=("$@")
    local max_attempts=3
    local delay=2
    local attempt=1
    local exit_code=0

    while [[ $attempt -le $max_attempts ]]; do
        log_info "Running: ${cmd[*]}"
        if "${cmd[@]}"; then
            return 0
        else
            exit_code=$?
            log_warning "Command failed (attempt $attempt/$max_attempts). Exit code: $exit_code"
            ((attempt++))
            
            if [[ $attempt -le $max_attempts ]]; then
                log_info "Retrying in ${delay}s..."
                sleep $delay
            fi
        fi
    done

    log_error "Command failed after $max_attempts attempts"
    return $exit_code
}

# Check if a port is in use
is_port_in_use() {
    local port=$1
    if command_exists lsof; then
        lsof -i ":$port" >/dev/null 2>&1
    else
        netstat -tuln 2>/dev/null | grep -q ":$port "
    fi
}

# Get available port
get_available_port() {
    local port=$1
    local max_attempts=10
    local attempt=0
    
    while is_port_in_use "$port" && [[ $attempt -lt $max_attempts ]]; do
        port=$((port + 1))
        ((attempt++))
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        log_error "Could not find available port after $max_attempts attempts"
        return 1
    fi
    
    echo "$port"
}

# Source a file if it exists
safe_source() {
    [[ -f "$1" ]] && source "$1"
}

# Add line to file if it doesn't exist
add_line_to_file() {
    local line=$1
    local file=$2
    
    grep -qxF "$line" "$file" 2>/dev/null || echo "$line" | sudo tee -a "$file" >/dev/null
}

# Check if a package is installed (Debian/Ubuntu)
is_package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Check if a package is installed (macOS)
is_brew_package_installed() {
    brew list --formula | grep -q "^$1$"
}

# Check if a package is installed (Linux)
# Usage: is_package_installed_linux <package_name>
is_package_installed_linux() {
    local os_id
    os_id=$(get_os_info)
    
    case $os_id in
        debian|ubuntu)
            dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
            ;;
        centos|rhel|fedora)
            rpm -q "$1" >/dev/null 2>&1
            ;;
        arch)
            pacman -Q "$1" >/dev/null 2>&1
            ;;
        *)
            command -v "$1" >/dev/null 2>&1
            ;;
    esac
}
