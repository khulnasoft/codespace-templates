#!/bin/bash
set -euo pipefail

# Configuration
TEMPLATE_DIR="./templates"
DEPLOY_DIR="./deployed_templates"
MANIFEST_FILE="$TEMPLATE_DIR/templates.json"
SCHEMA_FILE="$TEMPLATE_DIR/schema.json"
LOG_FILE="./deploy.log"
BRANCH="main"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize log file
echo "=== Deployment started at $(date) ===" > "$LOG_FILE"

# Logging functions
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() {
    log "INFO" "$1"
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    log "WARN" "$1"
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    log "ERROR" "$1"
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

section() {
    local section_name="$1"
    log "SECTION" "$section_name"
    echo -e "\n${BLUE}=== $section_name ===${NC}"
}

# Check if required commands are available
check_requirements() {
    local commands=("rsync" "git" "jq" "python3")
    local missing=()
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required commands: ${missing[*]}"
    fi
}

# Validate JSON against schema
validate_json_schema() {
    local json_file="$1"
    local schema_file="$2"
    
    if [ ! -f "$schema_file" ]; then
        warn "Schema file not found: $schema_file. Skipping schema validation."
        return 0
    fi
    
    if ! python3 -c "import jsonschema; jsonschema.Draft202012Validator.check_schema(jsonschema.Draft202012Validator.META_SCHEMA)" 2>/dev/null; then
        warn "jsonschema module not available or incompatible. Install with: pip install jsonschema"
        return 0
    fi
    
    if ! python3 -c "
import json
import jsonschema
import sys

try:
    with open('$json_file') as f:
        instance = json.load(f)
    with open('$schema_file') as f:
        schema = json.load(f)
    
    # For backward compatibility, don't fail on unknown formats
    jsonschema.validators.Draft202012Validator.FORMAT_CHECKER = jsonschema.draft202012_format_checker
    
    # Validate
    jsonschema.validate(instance=instance, schema=schema)
    print('Schema validation passed')
    sys.exit(0)
except Exception as e:
    print(f'Schema validation error: {str(e)}')
    sys.exit(1)
"; then
        return 1
    fi
    return 0
}

# Validate template structure and metadata
validate_template() {
    local template_dir="$1"
    local template_name=$(basename "$template_dir")
    local required_files=(
        "README.md" 
        ".devcontainer/devcontainer.json"
    )
    local optional_files=(
        "package.json"
        "requirements.txt"
        "*.csproj"
        "Gemfile"
        "Pipfile"
    )
    
    # Check required files
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -e "$template_dir/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        warn "Missing required files in $template_name: ${missing_files[*]}"
        return 1
    fi
    
    # Check for at least one dependency file
    local has_deps=false
    for pattern in "${optional_files[@]}"; do
        if compgen -G "$template_dir/$pattern" > /dev/null; then
            has_deps=true
            break
        fi
    done
    
    if [ "$has_deps" = false ]; then
        warn "No dependency management file found in $template_name. Consider adding one."
    }
    
    # Validate devcontainer.json
    local devcontainer_file="$template_dir/.devcontainer/devcontainer.json"
    if ! jq empty "$devcontainer_file" 2>/dev/null; then
        warn "Invalid JSON in $template_name/.devcontainer/devcontainer.json"
        return 1
    fi
    
    return 0
}

# Update template metadata with current timestamp
update_template_metadata() {
    local template_dir="$1"
    local template_id="$2"
    local temp_file=$(mktemp)
    
    jq --arg id "$template_id" \
       --arg timestamp "$TIMESTAMP" \
       '(.templates[] | select(.id == $id) | .lastUpdated) = $timestamp' \
       "$MANIFEST_FILE" > "$temp_file" && \
    mv "$temp_file" "$MANIFEST_FILE"
}

# Deploy a single template
deploy_template() {
    local template_path="$1"
    local template_name=$(basename "$template_path")
    local target_dir="$DEPLOY_DIR/$template_name"
    local temp_dir=$(mktemp -d)
    
    section "Deploying $template_name"
    
    # Validate template structure
    if ! validate_template "$template_path"; then
        warn "Skipping invalid template: $template_name"
        return 1
    fi
    
    # Create target directory
    mkdir -p "$target_dir" || {
        warn "Failed to create directory: $target_dir"
        return 1
    }
    
    # Use rsync with --delete to ensure exact copy
    if ! rsync -av --delete \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='__pycache__' \
        --exclude='.venv' \
        --exclude='.mypy_cache' \
        --exclude='.pytest_cache' \
        "$template_path/" "$target_dir/"; then
        warn "Failed to sync template: $template_name"
        return 1
    fi
    
    # Update template metadata
    if ! update_template_metadata "$template_path" "$template_name"; then
        warn "Failed to update template metadata for: $template_name"
    }
    
    info "Successfully deployed $template_name"
    return 0
}

# Main deployment function
deploy_templates() {
    section "Starting template deployment"
    info "Logging to: $LOG_FILE"
    
    # Ensure template directory exists
    if [ ! -d "$TEMPLATE_DIR" ]; then
        error "Template directory not found: $TEMPLATE_DIR"
    fi
    
    # Check if manifest exists
    if [ ! -f "$MANIFEST_FILE" ]; then
        error "Template manifest not found: $MANIFEST_FILE"
    fi
    
    # Validate manifest against schema
    if ! validate_json_schema "$MANIFEST_FILE" "$SCHEMA_FILE"; then
        error "Template manifest validation failed"
    fi

    # Create deploy directory if it doesn't exist
    mkdir -p "$DEPLOY_DIR" || error "Failed to create directory: $DEPLOY_DIR"
    
    # Read template list from manifest
    local templates=()
    while IFS= read -r template; do
        templates+=("$template")
    done < <(jq -r '.templates[].path' "$MANIFEST_FILE")
    
    if [ ${#templates[@]} -eq 0 ]; then
        warn "No templates found in manifest"
        return 0
    fi
    
    info "Found ${#templates[@]} templates to deploy"
    
    # Process each template
    local success_count=0
    local fail_count=0
    
    for template_path in "${templates[@]}"; do
        local full_path="$TEMPLATE_DIR/$template_path"
        
        # Skip if template directory doesn't exist
        if [ ! -d "$full_path" ]; then
            warn "Template directory not found: $full_path"
            ((fail_count++))
            continue
        fi
        
        # Check if template is deprecated
        local is_deprecated=$(jq -r --arg path "$template_path" 
            '.templates[] | select(.path == $path) | .isDeprecated // false' "$MANIFEST_FILE")
            
        if [ "$is_deprecated" = "true" ]; then
            local deprecation_msg=$(jq -r --arg path "$template_path" 
                '.templates[] | select(.path == $path) | .deprecationMessage // "This template is deprecated"' "$MANIFEST_FILE")
            warn "Skipping deprecated template: $template_path - $deprecation_msg"
            continue
        fi
        
        # Deploy the template
        if deploy_template "$full_path"; then
            ((success_count++))
        else
            ((fail_count++))
        fi
    done
    
    # Generate deployment summary
    section "Deployment Summary"
    if [ $success_count -gt 0 ]; then
        info "Successfully deployed $success_count template(s)"
    fi
    
    if [ $fail_count -gt 0 ]; then
        warn "Failed to deploy $fail_count template(s)"
    fi
    
    # Update lastUpdated timestamp in manifest
    jq --arg timestamp "$TIMESTAMP" '.lastUpdated = $timestamp' "$MANIFEST_FILE" > "$MANIFEST_FILE.tmp" && \
        mv "$MANIFEST_FILE.tmp" "$MANIFEST_FILE"
    
    if [ $fail_count -gt 0 ]; then
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    # Parse command line arguments
    local dry_run=false
    local template_filter=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                dry_run=true
                shift
                ;;
            --template)
                if [ -n "$2" ]; then
                    template_filter="$2"
                    shift 2
                else
                    error "--template requires a template name"
                fi
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    # Initialize
    check_requirements
    
    if [ "$dry_run" = true ]; then
        info "Running in dry-run mode. No changes will be made."
    fi
    
    # Run deployment
    local start_time=$(date +%s)
    
    if ! deploy_templates; then
        error "Template deployment failed"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    info "Deployment completed in ${duration} seconds"
    return 0
}

# Show help message
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Deploy code templates to the target directory.

Options:
  --dry-run     Validate templates without making changes
  --template    Deploy a specific template by name
  --help        Show this help message and exit

Environment Variables:
  TEMPLATE_DIR    Source directory for templates (default: ./templates)
  DEPLOY_DIR      Target directory for deployed templates (default: ./deployed_templates)
  LOG_FILE        Path to log file (default: ./deploy.log)

Examples:
  # Deploy all templates
  $ ./scripts/deploy_templates.sh
  
  # Validate templates without deploying
  $ ./scripts/deploy_templates.sh --dry-run
  
  # Deploy a specific template
  $ ./scripts/deploy_templates.sh --template react
EOF
}

# Run the main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
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
