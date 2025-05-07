#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
MANIFEST_FILE="$TEMPLATE_DIR/templates.json"

# Load template manifest
load_manifest() {
    if [ ! -f "$MANIFEST_FILE" ]; then
        echo -e "${RED}Error: Manifest file not found at $MANIFEST_FILE${NC}" >&2
        return 1
    fi
    cat "$MANIFEST_FILE"
}

# List all templates
list_templates() {
    echo -e "${BLUE}Available Templates:${NC}\n"
    
    load_manifest | jq -r '
    .templates[] | 
    "\(.name) (\(.id))" + 
    "\n  \(.description)" + 
    "\n  Category: \(.category)" + 
    "\n  Tags: \(.tags | join(", "))" + 
    "\n  Path: \(.path)\n"
    '
}

# Get template by ID
get_template() {
    local template_id="$1"
    local template
    
    template=$(load_manifest | jq --arg id "$template_id" '.templates[] | select(.id == $id)')
    
    if [ -z "$template" ]; then
        echo -e "${RED}Error: Template '$template_id' not found${NC}" >&2
        return 1
    fi
    
    echo "$template"
}

# Validate a template
validate_template() {
    local template_id="$1"
    local template_path
    local template_json
    local valid=true
    
    # Get template info
    if ! template_json=$(get_template "$template_id"); then
        return 1
    fi
    
    template_path=$(echo "$template_json" | jq -r '.path')
    full_path="$TEMPLATE_DIR/$template_path"
    
    echo -e "${BLUE}Validating template: ${GREEN}$(echo "$template_json" | jq -r '.name')${NC}\n"
    
    # Check required fields
    local required_fields=("id" "name" "description" "category" "tags" "path")
    for field in "${required_fields[@]}"; do
        if ! echo "$template_json" | jq -e ".$field" > /dev/null; then
            echo -e "${RED}✗ Missing required field: $field${NC}"
            valid=false
        fi
    done
    
    # Check directory exists
    if [ ! -d "$full_path" ]; then
        echo -e "${RED}✗ Template directory not found: $full_path${NC}"
        valid=false
    else
        # Check required files
        local required_files=("README.md" ".devcontainer/devcontainer.json")
        for file in "${required_files[@]}"; do
            if [ ! -f "$full_path/$file" ]; then
                echo -e "${YELLOW}⚠ Missing recommended file: $file${NC}"
            fi
        done
    fi
    
    if [ "$valid" = true ]; then
        echo -e "${GREEN}✓ Template '$template_id' is valid${NC}"
        return 0
    else
        echo -e "${RED}✗ Template '$template_id' has issues${NC}" >&2
        return 1
    fi
}

# Validate all templates
validate_all_templates() {
    local all_valid=true
    local templates
    
    templates=$(load_manifest | jq -r '.templates[].id')
    
    for template_id in $templates; do
        if ! validate_template "$template_id"; then
            all_valid=false
        fi
        echo ""
    done
    
    if [ "$all_valid" = true ]; then
        echo -e "${GREEN}✓ All templates are valid${NC}"
        return 0
    else
        echo -e "${RED}✗ Some templates have issues${NC}" >&2
        return 1
    fi
}

# Search templates by tag
search_templates_by_tag() {
    local tag="$1"
    
    echo -e "${BLUE}Templates with tag '$tag':${NC}\n"
    
    load_manifest | jq -r --arg tag "$tag" '
    .templates[] | 
    select(.tags | index($tag)) | 
    "\(.name) (\(.id))\n  \(.description)\n"
    '
}

# Show help
show_help() {
    echo -e "${BLUE}Template Management Utility${NC}\n"
    echo "Usage: $0 [command] [arguments]"
    echo ""
    echo "Commands:"
    echo "  list                     List all available templates"
    echo "  show <template_id>       Show details of a specific template"
    echo "  validate <template_id>   Validate a specific template"
    echo "  validate-all             Validate all templates"
    echo "  search <tag>             Search templates by tag"
    echo "  help                     Show this help message"
}

# Main function
main() {
    local command="${1:-help}"
    local arg="${2:-}"
    
    case "$command" in
        list)
            list_templates
            ;;
        show)
            if [ -z "$arg" ]; then
                echo -e "${RED}Error: Template ID is required${NC}" >&2
                show_help
                exit 1
            fi
            get_template "$arg" | jq .
            ;;
        validate)
            if [ -z "$arg" ]; then
                validate_all_templates
            else
                validate_template "$arg"
            fi
            ;;
        search)
            if [ -z "$arg" ]; then
                echo -e "${RED}Error: Search tag is required${NC}" >&2
                show_help
                exit 1
            fi
            search_templates_by_tag "$arg"
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Run the script
main "$@"
