# Contributing to Codespace Templates

Thank you for your interest in contributing! This guide will help you get started with contributing to our template collection.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Template Development](#template-development)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Reporting Issues](#reporting-issues)
- [Community](#community)

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/codespace-templates.git
   cd codespace-templates
   ```
3. **Set up your development environment**:
   ```bash
   # Install development dependencies
   pip install -r requirements-dev.txt
   
   # Install pre-commit hooks
   pre-commit install
   ```

## Template Development

### Creating a New Template

1. Create a new directory in `templates/` with a descriptive name (lowercase, hyphen-separated)
2. Add the following required files:
   - `README.md` - Template documentation
   - `.devcontainer/devcontainer.json` - Dev container configuration
   - Any additional files needed for the template

### Template Structure

```
template-name/
├── .devcontainer/
│   ├── devcontainer.json  # Required: Dev container config
│   └── ...               # Additional dev container files
├── README.md             # Required: Template documentation
├── .gitignore            # Project-specific ignores
└── ...                   # Template-specific files
```

### Template Metadata

Update `templates/templates.json` with your template's metadata:

```json
{
  "id": "your-template-id",
  "name": "Your Template Name",
  "description": "A brief description of your template",
  "category": "Frontend|Backend|Fullstack|Data Science",
  "tags": ["tag1", "tag2"],
  "path": "template-name",
  "version": "1.0.0",
  "compatibility": {
    "node": ">=16.0.0",
    "python": ">=3.8"
  },
  "dependencies": {
    "package-name": "^1.0.0"
  }
}
```

## Pull Request Process

1. Ensure your fork is up to date with the main repository:
   ```bash
   git remote add upstream https://github.com/your-org/codespace-templates.git
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. Create a new feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```

3. Make your changes and commit them with a descriptive message:
   ```bash
   git commit -m "feat(templates): add new template for [framework]"
   ```

4. Push your changes to your fork:
   ```bash
   git push origin feat/your-feature-name
   ```

5. Open a pull request against the `main` branch

## Code Review Guidelines

- Keep pull requests focused on a single feature or fix
- Ensure all tests pass
- Update documentation as needed
- Follow the existing code style
- Include tests for new features
- Make sure your code is well-documented

## Testing

Run the following commands to ensure your changes work as expected:

```bash
# Run all tests
./scripts/run_tests.sh

# Validate template structure
./scripts/validate_templates.sh

# Test deployment (dry run)
./scripts/deploy_templates.sh --dry-run
```

## Documentation

- Keep `README.md` up to date with any changes
- Document new features or configuration options
- Add examples where helpful
- Update the changelog for significant changes

## Reporting Issues

When reporting issues, please include:

1. A clear, descriptive title
2. Steps to reproduce the issue
3. Expected vs. actual behavior
4. Environment details (OS, browser, etc.)
5. Any relevant logs or screenshots

## Community

- Join our [Discord/Slack channel] for discussions
- Follow us on [Twitter] for updates
- Check out our [blog] for tutorials and announcements

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

---

Thank you for contributing to Codespace Templates! Your help is greatly appreciated.
