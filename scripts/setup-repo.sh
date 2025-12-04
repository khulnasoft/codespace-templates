#!/bin/bash
# setup-repo.sh - Configure GitHub repository with comprehensive security and automation

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Configuration - Update these values as needed
REPO_OWNER="${REPO_OWNER:-your-org}"
REPO_NAME="${REPO_NAME:-$(basename -s .git $(git config --get remote.origin.url) 2>/dev/null || echo "codespace-templates")}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
TEAM_SLUG="${TEAM_SLUG:-maintainers}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging functions
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# Check prerequisites
check_prerequisites() {
    info "🔍 Checking prerequisites..."
    
    # Check for required commands
    local required_commands=("gh" "jq" "curl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is required but not installed. Please install it first."
        fi
    done
    
    # Check GitHub CLI authentication
    if ! gh auth status &>/dev/null; then
        warn "GitHub CLI is not authenticated. Running 'gh auth login'..."
        gh auth login
    fi
    
    # Verify GitHub token has sufficient permissions
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        warn "GITHUB_TOKEN environment variable is not set. Some features may be limited."
    fi
}

# Setup repository settings
setup_repository_settings() {
    info "�️  Configuring repository settings..."
    
    # Update basic repository settings
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        /repos/$REPO_OWNER/$REPO_NAME \
        -f vulnerability_alerts=true \
        -f allow_auto_merge=true \
        -f delete_branch_on_merge=true \
        -f allow_update_branch=true \
        -f allow_rebase_merge=false \
        -f allow_squash_merge=true \
        -f allow_merge_commit=false \
        -f has_issues=true \
        -f has_projects=false \
        -f has_wiki=false
}

# Setup branch protection
setup_branch_protection() {
    info "🔒 Configuring branch protection for '$DEFAULT_BRANCH'..."
    
    local status_checks='{"strict":true,"contexts":["CodeQL","Test","Lint","Dependency Review","Secret Scan"]}'
    
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github.luke-cage-preview+json" \
        /repos/$REPO_OWNER/$REPO_NAME/branches/$DEFAULT_BRANCH/protection \
        -f required_status_checks="$status_checks" \
        -f enforce_admins=true \
        -f required_pull_request_reviews='{"required_approving_review_count":1,"require_code_owner_reviews":true}' \
        -f restrictions='{"teams":["'$TEAM_SLUG'"],"users":[]}' \
        -f required_linear_history=true \
        -f allow_force_pushes=false \
        -f allow_deletions=false
}

# Setup security features
setup_security_features() {
    info "🛡️  Enabling security features..."
    
    # Enable Dependabot security updates
    info "Enabling Dependabot security updates..."
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github.dependabot.v1+json" \
        /repos/$REPO_OWNER/$REPO_NAME/vulnerability-alerts
    
    # Enable automated security fixes
    info "Enabling automated security fixes..."
    gh api \
        --method PUT \
        -H "Accept: application/vnd.github.london-preview+json" \
        /repos/$REPO_OWNER/$REPO_NAME/automated-security-fixes
    
    # Enable secret scanning
    info "Enabling secret scanning..."
    gh api \
        --method PATCH \
        -H "Accept: application/vnd.github+json" \
        /repos/$REPO_OWNER/$REPO_NAME \
        -f security_and_analysis='{"secret_scanning":{"status":"enabled"}}'
    
    # Enable push protection
    info "Enabling push protection for secrets..."
    gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        /repos/$REPO_OWNER/$REPO_NAME/secret-scanning/push-protection \
        -f status="enabled"
}

# Setup CodeQL code scanning
setup_codeql() {
    info "🔍 Setting up CodeQL code scanning..."
    
    # Create .github/codeql directory if it doesn't exist
    mkdir -p .github/codeql
    
    # Create or update codeql-config.yml
    cat > .github/codeql/codeql-config.yml << 'EOL'
---
name: "CodeQL Configuration"

# To learn more about this file, see: https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/configuring-code-scanning#using-a-custom-configuration-file

queries:
  - name: Security
    uses: ./
    apply-default-queries: true
    queries: security-extended,security-and-quality

paths-ignore:
  - '**/node_modules/**'
  - '**/tests/**'
  - '**/test/**'
  - '**/dist/**'
  - '**/build/**'
  - '**/vendor/**'
  - '**/__mocks__/**'
  - '**/.github/**'
  - '**/.vscode/**'
  - '**/.idea/**'
  - '**/*.md'
  - '**/*.json'
  - '**/*.lock'
  - '**/*.min.*'
  - '**/*.bundle.*'

disable-default-queries: false
EOL

    info "✅ CodeQL configuration created at .github/codeql/codeql-config.yml"
}

# Setup Trivy container scanning
setup_trivy() {
    info "🔍 Setting up Trivy container scanning..."
    
    # Create .github/workflows directory if it doesn't exist
    mkdir -p .github/workflows
    
    # Create trivy-scan.yml workflow
    cat > .github/workflows/container-scan.yml << 'EOL'
name: Container Vulnerability Scan

on:
  push:
    branches: [ main ]
    paths:
      - '**/Dockerfile'
      - '**/docker-compose*.yml'
  pull_request:
    branches: [ main ]
    paths:
      - '**/Dockerfile'
      - '**/docker-compose*.yml'
  schedule:
    - cron: '0 0 * * 0' # Weekly on Sunday at midnight

jobs:
  trivy-scan:
    name: Scan container images with Trivy
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: '**/Dockerfile'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
          ignore-unfixed: true
      
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
          category: container-scan
EOL

    info "✅ Trivy container scanning workflow created at .github/workflows/container-scan.yml"
}

# Setup Dependabot configuration
setup_dependabot() {
    info "🔄 Configuring Dependabot..."
    
    mkdir -p .github
    
    # Create or update dependabot.yml
    cat > .github/dependabot.yml << 'EOL'
version: 2
updates:
  # Enable version updates for npm
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      time: "09:00"
      timezone: "UTC"
    # Apply labels to all pull requests for package updates
    labels:
      - "dependencies"
      - "security"
    # Group all patch updates together
    groups:
      npm-minor-patch:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
    # Allow up to 5 open pull requests for version updates
    open-pull-requests-limit: 5
    # Only allow updates to the lockfile only for patch updates
    versioning-strategy: increase

  # Enable version updates for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      time: "10:00"
      timezone: "UTC"
    labels:
      - "github-actions"
      - "dependencies"

  # Enable version updates for Python
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
      time: "11:00"
      timezone: "UTC"
    labels:
      - "dependencies"
      - "python"
    groups:
      python-minor-patch:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
EOL

    info "✅ Dependabot configuration created at .github/dependabot.yml"
}

# Setup Changelog generation
setup_changelog() {
    info "📝 Setting up Changelog generation..."
    
    # Create or update .chglog/config.yml
    mkdir -p .chglog
    
    cat > .chglog/config.yml << 'EOL'
style: github
template: CHANGELOG.tpl.md
info:
  title: CHANGELOG
  repository_url: https://github.com/{{.Owner}}/{{.Repository}}
options:
  commits:
    filters:
      Type:
        - feat
        - fix
        - perf
        - refactor
  commit_groups:
    title_maps:
      feat: Features
      fix: Bug Fixes
      perf: Performance Improvements
      refactor: Code Refactoring
      test: Tests
      docs: Documentation
      chore: Maintenance
  header:
    pattern: "^(\\w*)(\\(([\\w\\-]+)\\))?:\\s*(.*)$"
    pattern_maps:
      - Type
      - Scope
      - Scope
      - Subject
  notes:
    keywords:
      - BREAKING CHANGE
      - BREAKING CHANGES
EOL

    # Create CHANGELOG.tpl.md
    cat > CHANGELOG.tpl.md << 'EOL'
{{ if .Versions -}}
{{ if .Unreleased -}}
## [Unreleased]({{.Info.RepositoryURL}}/compare/{{.Latest.Version}}...HEAD)

{{ range .Unreleased.Commits -}}
- {{.Header}}
{{ end -}}
{{ end -}}

{{ range .Versions }}
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]({{$.Info.RepositoryURL}}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}){{ else }}{{ .Tag.Name }}{{ end }} ({{ datetime "2006-01-02" .Tag.Date }})
{{ range .CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ .Subject }}
{{ end }}
{{ end -}}

{{- if .RevertingCommits -}}
### Reverts
{{ range .RevertingCommits -}}
- {{ .RevertHeader }}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}
{{ range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}
{{ end -}}
EOL

    info "✅ Changelog configuration created in .chglog/"
}

# Main function
main() {
    echo -e "\n${GREEN}🚀 Starting repository setup for $REPO_OWNER/$REPO_NAME${NC}\n"
    
    # Check for required tools and authentication
    check_prerequisites
    
    # Configure repository settings
    setup_repository_settings
    
    # Setup branch protection
    setup_branch_protection
    
    # Setup security features
    setup_security_features
    
    # Setup CodeQL
    setup_codeql
    
    # Setup Trivy container scanning
    setup_trivy
    
    # Setup Dependabot
    setup_dependabot
    
    # Setup Changelog generation
    setup_changelog
    
    echo -e "\n${GREEN}✅ Repository setup completed successfully!${NC}\n"
    echo "Next steps:"
    echo "1. Review the generated configuration files"
    echo "2. Add and commit the changes"
    echo "3. Push to your repository to trigger the new workflows"
    echo -e "\nTo make this script executable, run: chmod +x scripts/setup-repo.sh"
    echo -e "To run the setup: GITHUB_TOKEN=your_github_token ./scripts/setup-repo.sh\n"
}

# Run the main function
main "$@"
