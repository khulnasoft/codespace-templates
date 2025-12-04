#!/usr/bin/env bash
# Main entry point for repository setup
# Usage: ./setup.sh [--minimal] [--full] [--security] [--dependencies]

set -eo pipefail

# Import core libraries
source "./scripts/setup/lib/logging.sh"
source "./scripts/setup/lib/utils.sh"

# Default configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${SCRIPT_DIR}/setup/config"
readonly MODULES_DIR="${SCRIPT_DIR}/setup/modules"

# Parse command line arguments
parse_args() {
    local mode="standard"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --minimal) mode="minimal" ; shift ;;
            --full) mode="full" ; shift ;;
            --security) mode="security" ; shift ;;
            --dependencies) mode="dependencies" ; shift ;;
            *) log_error "Unknown option: $1" ; exit 1 ;;
        esac
    done
    
    echo "$mode"
}

# Main function
main() {
    local mode="${1:-standard}"
    
    log_header "🚀 Starting Repository Setup"
    log_info "Mode: $mode"
    
    # Load configuration
    source "${SCRIPT_DIR}/setup/config/env.sh"
    
    # Run setup based on mode
    case $mode in
        minimal)
            run_module "repository"
            ;;
        standard)
            run_module "repository"
            run_module "dependencies"
            run_module "security"
            ;;
        full)
            run_module "repository"
            run_module "dependencies"
            run_module "security"
            run_module "monitoring"
            run_module "documentation"
            ;;
        security)
            run_module "security"
            ;;
        dependencies)
            run_module "dependencies"
            ;;
    esac
    
    log_success "✅ Setup completed successfully!"
}

# Run a specific module
run_module() {
    local module=$1
    local module_script="${MODULES_DIR}/${module}.sh"
    
    if [[ -f "$module_script" ]]; then
        log_header "🔧 Setting up ${module^}"
        source "$module_script"
    else
        log_warning "Module '${module}' not found"
    fi
}

# Run main function with arguments
main "$@"
