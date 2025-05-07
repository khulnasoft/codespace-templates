#!/bin/bash
set -euo pipefail

# Configuration
TEMPLATE_DIR="./templates"
DEPLOY_DIR="./deployed_templates"
MANIFEST_FILE="$TEMPLATE_DIR/templates.json"
BRANCH="main"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if required commands are available
check_requirements() {
    local commands=("rsync" "git" "jq")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "Required command not found: $cmd"
        fi
    done
}

# Validate template structure
validate_template() {
    local template_dir="$1"
    local required_files=("README.md" ".devcontainer/devcontainer.json")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$template_dir/$file" ]; then
            warn "Missing required file in $template_dir: $file"
            return 1
        fi
    done
    return 0
}

# Deploy a single template
deploy_template() {
    local template_path="$1"
    local template_name="$(basename "$template_path")"
    local target_dir="$DEPLOY_DIR/$template_name"
    
    section "Deploying $template_name"
    
    # Validate template
    if ! validate_template "$template_path"; then
        warn "Skipping invalid template: $template_name"
        return 1
    fi
    
    # Create target directory
    mkdir -p "$target_dir" || {
        warn "Failed to create directory: $target_dir"
        return 1
    }
    
    # Sync template files
    if ! rsync -av --delete --exclude='.git' --exclude='node_modules' "$template_path/" "$target_dir/"; then
        warn "Failed to sync template: $template_name"
        return 1
    }
    
    return 0
}

# Main deployment function
deploy_templates() {
    section "Starting template deployment"
    
    # Ensure template directory exists
    if [ ! -d "$TEMPLATE_DIR" ]; then
        error "Template directory not found: $TEMPLATE_DIR"
    fi
    
    # Check if manifest exists
    if [ ! -f "$MANIFEST_FILE" ]; then
        error "Template manifest not found: $MANIFEST_FILE"
    fi

    # Create deploy directory if it doesn't exist
    mkdir -p "$DEPLOY_DIR" || error "Failed to create directory: $DEPLOY_DIR"
    
    # Read template list from manifest
    local templates=()
    while IFS= read -r template; do
        templates+=("$template")
    done < <(jq -r '.templates[].path' "$MANIFEST_FILE")
    
    # Deploy each template
    local success_count=0
    local failed_count=0
    
    for template in "${templates[@]}"; do
        local template_path="$TEMPLATE_DIR/$template"
        if [ -d "$template_path" ]; then
            if deploy_template "$template_path"; then
                ((success_count++))
            else
                ((failed_count++))
            fi
        else
            warn "Template directory not found: $template_path"
            ((failed_count++))
        fi
    done
    
    # Report status
    section "Deployment Summary"
    info "Successfully deployed: $success_count templates"
    if [ "$failed_count" -gt 0 ]; then
        warn "Failed to deploy: $failed_count templates"
    fi
    
    # Check for changes
    if ! git diff --quiet -- "$DEPLOY_DIR"; then
        info "Changes detected, committing updates..."
        git add "$DEPLOY_DIR"
        
        # Generate commit message with changed files
        local commit_msg="Deploy template updates\n\n"
        commit_msg+="$(git diff --name-only --cached -- "$DEPLOY_DIR" | sort | uniq | sed 's/^/- /')"
        
        if ! git commit -m "$commit_msg"; then
            error "Failed to commit changes"
        fi
        
        if ! git push origin "$BRANCH"; then
            error "Failed to push changes to $BRANCH"
        fi
        info "Changes successfully deployed to $BRANCH"
    else
        info "No changes to deploy"
    fi
}

# Main execution
main() {
    check_requirements
    deploy_templates
    info "Deployment completed successfully"
}

main "$@"
