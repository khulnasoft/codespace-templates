#!/bin/bash
# setup-repo.sh - Configure GitHub repository settings and security features

# Exit on error
set -e

# Configuration
REPO_OWNER="your-org"
REPO_NAME="codespace-templates"
DEFAULT_BRANCH="main"
TEAM_SLUG="maintainers"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first: https://cli.github.com/"
    exit 1
fi

# Authenticate with GitHub
echo "🔐 Authenticating with GitHub..."
gh auth status || gh auth login

# Enable security features
echo "🛡️  Enabling security features..."
gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  /repos/$REPO_OWNER/$REPO_NAME \
  -f vulnerability_alerts=true \
  -f allow_auto_merge=true \
  -f delete_branch_on_merge=true \
  -f allow_update_branch=true

# Enable Dependabot security updates
echo "🔄 Enabling Dependabot security updates..."
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.dependabot-preview+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/vulnerability-alerts"

# Configure branch protection
echo "🔒 Configuring branch protection for $DEFAULT_BRANCH..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github.luke-cage-preview+json" \
  /repos/$REPO_OWNER/$REPO_NAME/branches/$DEFAULT_BRANCH/protection \
  -f required_status_checks='{"strict":true,"contexts":["CodeQL","Test","Lint"]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}' \
  -f restrictions='{"teams":["'$TEAM_SLUG'"]}'

# Enable automated security fixes
echo "🔧 Enabling automated security fixes..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github.london-preview+json" \
  /repos/$REPO_OWNER/$REPO_NAME/automated-security-fixes

echo "✅ Repository configuration complete!"