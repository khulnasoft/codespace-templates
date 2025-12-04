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

## 🛠️ Development Workflow

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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-template`
3. Commit your changes: `git commit -m 'Add amazing template'`
4. Push to the branch: `git push origin feature/amazing-template`
5. Open a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
