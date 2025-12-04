#!/bin/bash
# Repository configuration module

# Load dependencies
source "${BASH_SOURCE%/*}/utils.sh"

# Setup repository settings
setup_repository() {
    log_info "🔄 Configuring repository settings..."
    
    local repo_path="/repos/${REPO_CONFIG[DEFAULT_OWNER]}/${REPO_CONFIG[DEFAULT_REPO]}"
    
    # Update repository settings
    github_api PATCH "$repo_path" <<-EOF
    {
        "vulnerability_alerts": true,
        "allow_auto_merge": true,
        "delete_branch_on_merge": true,
        "allow_update_branch": true,
        "allow_rebase_merge": false,
        "allow_squash_merge": true,
        "allow_merge_commit": false,
        "has_issues": true,
        "has_projects": false,
        "has_wiki": false
    }
EOF
    
    setup_branch_protection
}

# Setup branch protection
setup_branch_protection() {
    log_info "🔒 Configuring branch protection for '${REPO_CONFIG[DEFAULT_BRANCH]}'..."
    
    local repo_path="/repos/${REPO_CONFIG[DEFAULT_OWNER]}/${REPO_CONFIG[DEFAULT_REPO]}"
    local branch_path="$repo_path/branches/${REPO_CONFIG[DEFAULT_BRANCH]}/protection"
    
    github_api PUT "$branch_path" <<-EOF
    {
        "required_status_checks": {
            "strict": true,
            "contexts": ["CodeQL", "Test", "Lint", "Dependency Review", "Secret Scan"]
        },
        "enforce_admins": true,
        "required_pull_request_reviews": {
            "required_approving_review_count": 1,
            "require_code_owner_reviews": true
        },
        "restrictions": {
            "teams": ["${REPO_CONFIG[TEAM_SLUG]}"],
            "users": []
        },
        "required_linear_history": true,
        "allow_force_pushes": false,
        "allow_deletions": false
    }
EOF
}
