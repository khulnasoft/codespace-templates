#!/usr/bin/env bash
# Logging utilities

# Colors
readonly COLOR_RESET='\033[0m'
readonly COLOR_DEBUG='\033[0;34m'    # Blue
readonly COLOR_INFO='\033[0;32m'     # Green
readonly COLOR_WARNING='\033[1;33m'  # Yellow
readonly COLOR_ERROR='\033[0;31m'    # Red
readonly COLOR_HEADER='\033[1;36m'   # Cyan

# Log levels: 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL
LOG_LEVEL=${LOG_LEVEL:-1}

# Log functions
log_debug() {
    if [[ $LOG_LEVEL -le 0 ]]; then
        echo -e "${COLOR_DEBUG}[DEBUG] $1${COLOR_RESET}" >&2
    fi
}

log_info() {
    if [[ $LOG_LEVEL -le 1 ]]; then
        echo -e "${COLOR_INFO}[INFO] $1${COLOR_RESET}"
    fi
}

log_warning() {
    if [[ $LOG_LEVEL -le 2 ]]; then
        echo -e "${COLOR_WARNING}[WARNING] $1${COLOR_RESET}" >&2
    fi
}

log_error() {
    if [[ $LOG_LEVEL -le 3 ]]; then
        echo -e "${COLOR_ERROR}[ERROR] $1${COLOR_RESET}" >&2
    fi
}

log_critical() {
    if [[ $LOG_LEVEL -le 4 ]]; then
        echo -e "${COLOR_ERROR}[CRITICAL] $1${COLOR_RESET}" >&2
        exit 1
    fi
}

log_success() {
    echo -e "✅ ${COLOR_INFO}$1${COLOR_RESET}"
}

log_header() {
    echo -e "\n${COLOR_HEADER}=== $1 ===${COLOR_RESET}"
}

# Check if running in CI environment
is_ci() {
    [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]
}

# Check if running in debug mode
is_debug() {
    [[ "${DEBUG:-0}" == "1" ]]
}
