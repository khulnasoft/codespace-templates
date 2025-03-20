#!/bin/bash
set -e

TEMPLATE_DIR="./templates"
DEPLOY_DIR="./deployed_templates"

mkdir -p "$DEPLOY_DIR"

echo "Deploying templates from $TEMPLATE_DIR to $DEPLOY_DIR..."
rsync -av --exclude=".git" "$TEMPLATE_DIR/" "$DEPLOY_DIR/"

if [[ -n $(git status --porcelain "$DEPLOY_DIR") ]]; then
    git add "$DEPLOY_DIR"
    git commit -m "Deploy updated templates"
    git push origin main
else
    echo "No changes to commit."
fi

echo "Deployment complete!"
