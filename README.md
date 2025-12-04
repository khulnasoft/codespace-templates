# Codespace Templates [![Open in GitHub Codespaces](https://img.shields.io/badge/Open%20in%20GitHub%20Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates)

A collection of pre-configured development environment templates for various frameworks and languages, optimized for GitHub Codespaces.

## ✨ Features

- 🚀 **Quick Start**: Get started with new projects instantly
- ⚡ **Optimized**: Pre-configured for performance and best practices
- 🔄 **Version Controlled**: All templates are tracked in Git
- 🤖 **Automated**: CI/CD pipeline keeps templates up-to-date

## 📁 Project Structure

```
.
├── .github/                 # GitHub configurations
│   └── workflows/           # GitHub Actions workflows
├── deployed_templates/      # Auto-deployed templates (managed by CI/CD)
├── scripts/                 # Deployment and utility scripts
│   └── deploy_templates.sh  # Script to deploy templates
└── templates/               # Source templates
    ├── templates.json       # Template manifest
    ├── react/              # React template
    ├── nextjs/             # Next.js template
    ├── express/            # Express template
    └── ...                 # Other templates
```

## 📋 Available Templates

| Template | Category | Description | Tags | Launch |
|----------|----------|-------------|------|---------|
| [React](templates/react) | Frontend | Modern React with Vite and TypeScript | `react`, `typescript`, `vite` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Freact%2Fdevcontainer.json) |
| [Next.js](templates/nextjs) | Fullstack | React framework with SSR | `nextjs`, `react`, `typescript` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fnextjs%2Fdevcontainer.json) |
| [Express](templates/express) | Backend | Minimal Node.js web framework | `nodejs`, `express`, `javascript` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fexpress%2Fdevcontainer.json) |
| [Django](templates/django) | Backend | High-level Python web framework | `python`, `django`, `sqlite` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fdjango%2Fdevcontainer.json) |
| [Flask](templates/flask) | Backend | Lightweight Python WSGI framework | `python`, `flask`, `rest` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fflask%2Fdevcontainer.json) |
| [Jupyter](templates/jupyter) | Data Science | Jupyter Notebook environment | `python`, `jupyter`, `data-science` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fjupyter%2Fdevcontainer.json) |
| [Preact](templates/preact) | Frontend | Fast React alternative | `preact`, `javascript`, `vite` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fpreact%2Fdevcontainer.json) |
| [Rails](templates/rails) | Fullstack | Ruby on Rails framework | `ruby`, `rails`, `postgresql` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Frails%2Fdevcontainer.json) |
| [.NET Core](templates/dotnet) | Backend | Cross-platform .NET | `csharp`, `dotnet`, `webapi` | [![Open in Codespaces](https://img.shields.io/badge/Open%20in-Codespaces-2ea44f?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR-USERNAME%2Fcodespace-templates&devcontainer_path=.devcontainer%2Fdotnet%2Fdevcontainer.json) |

## � CI/CD Pipeline

Our CI/CD pipeline automates the validation, testing, and deployment of templates. The workflow is defined in [.github/workflows/deploy.yml](.github/workflows/deploy.yml).

### Key Features

- **Automated Validation**: Every push and PR is validated for:
  - JSON schema compliance
  - Required files and directory structure
  - Template metadata completeness

- **Environment-based Deployments**:
  - `development`: For testing changes
  - `staging`: For pre-production verification
  - `production`: For stable releases

- **Deployment Triggers**:
  - Push to `main` branch (auto-deploys to production)
  - Manual trigger via GitHub Actions UI
  - Pull Request validation (no deployment)

### Manual Deployment

Deploy to a specific environment using GitHub CLI:

```bash
# Deploy to staging
git checkout main
git pull
gh workflow run deploy.yml -f environment=staging
```

### Monitoring

- **Deployment Status**: View in GitHub Actions > Workflows
- **Environments**: Check deployment history in Repository Settings > Environments
- **Logs**: Detailed logs available for each workflow run

## 🔍 Template Validation

All templates must pass validation before deployment. The validation checks:

1. **Schema Compliance**:
   - Required fields in `templates.json`
   - Valid JSON structure
   - Version compatibility

2. **File Structure**:
   ```
   template-name/
   ├── .devcontainer/
   │   └── devcontainer.json  # Required: Dev container config
   ├── README.md             # Required: Template documentation
   └── ...                   # Template-specific files
   ```

3. **Metadata Requirements**:
   - Unique template ID
   - Description and category
   - Version and compatibility info
   - Maintainer details

## �🛠️ Development Workflow

### Local Development

1. Make changes to templates in the `templates/` directory
2. Test your changes locally:
   ```bash
   ./scripts/deploy_templates.sh
   ```
3. Commit and push changes to the `main` branch
4. GitHub Actions will automatically deploy changes to `deployed_templates/`

### Adding a New Template

1. Create a new directory in `templates/` for your template
2. Add required files:
   - `README.md`: Template documentation
   - `.devcontainer/devcontainer.json`: Codespace configuration
   - Any other necessary files
3. Update `templates/templates.json` with your template's metadata
4. Submit a pull request

## 🔄 CI/CD Pipeline

The deployment pipeline (`.github/workflows/deploy.yml`) handles:

- ✅ Automatic template validation
- 🚀 Parallel deployment of templates
- 📝 Detailed deployment logs
- 🔄 Automatic updates to `deployed_templates/`

## 🛡️ Security & Compliance

### Secrets Management
- Store sensitive data in GitHub Secrets
- Use environment-specific configuration
- Rotate secrets regularly

### Access Control
- Follow principle of least privilege
- Require code reviews for production changes
- Use branch protection rules

### Compliance Checks
- Dependencies are scanned for vulnerabilities
- Regular security audits
- Compliance with organizational policies

## 🛠️ Local Development

### Prerequisites
- Git
- Python 3.10+
- GitHub CLI (`gh`)
- Docker (for local testing)

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/your-org/codespace-templates.git
   cd codespace-templates
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements-dev.txt
   ```

3. Run local validation:
   ```bash
   ./scripts/validate_templates.sh
   ```

### Testing Changes
1. Make your changes in the `templates/` directory
2. Run the deployment script locally:
   ```bash
   ./scripts/deploy_templates.sh --dry-run
   ```
3. Verify the output and fix any issues
4. Commit and push your changes

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-template`
3. Make your changes and verify them locally:
   ```bash
   # Run tests and validation
   ./scripts/run_tests.sh
   ./scripts/validate_templates.sh
   ```
4. Commit your changes with a descriptive message:
   ```bash
   git commit -m "feat(templates): add new template for [framework]"
   ```
5. Push to your fork: `git push origin feature/amazing-template`
6. Create a pull request with a clear description of your changes

### Pull Request Requirements
- Include tests for new features
- Update documentation
- Ensure all validations pass
- Get required approvals before merging

## 📊 Monitoring & Observability

### Logging
- All deployments are logged with timestamps
- Detailed error messages for troubleshooting
- Structured JSON logs for parsing

### Metrics
- Deployment success/failure rates
- Template usage statistics
- Performance metrics

### Alerts
- Failed deployments
- Security vulnerabilities
- Performance degradation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- GitHub Actions for CI/CD
- JSON Schema for validation
- The open source community for inspiration and tools
