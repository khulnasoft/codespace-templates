# Security Policy

## Supported Versions

We provide security updates for the following versions of our templates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously and appreciate your efforts to responsibly disclose any vulnerabilities you find.

### How to Report

Please report security vulnerabilities by emailing our security team at [security@example.com](mailto:security@example.com). 

**Do not** create a public GitHub issue for security vulnerabilities.

### What to Include

When reporting a vulnerability, please include:
- A description of the vulnerability
- Steps to reproduce the issue
- Impact of the vulnerability
- Any potential mitigations
- Your contact information

### Our Commitment

- We will acknowledge receipt of your report within 48 hours
- We will keep you informed about the progress of the fix
- We will credit you in our security advisories (unless you prefer to remain anonymous)

## Security Updates

Security updates are released as patch versions (e.g., 1.0.0 → 1.0.1). We recommend always using the latest version of our templates.

## Security Best Practices

### For Template Users
- Keep your dependencies up to date
- Regularly review security advisories for your stack
- Use dependency scanning tools
- Follow the principle of least privilege

### For Template Developers
- Never include secrets or sensitive data in templates
- Use environment variables for configuration
- Keep dependencies up to date
- Follow secure coding practices
- Use security linters and scanners

## Security Audits

We conduct regular security audits of our codebase and dependencies. Third-party security audits are performed annually.

## Dependency Security

We use Dependabot to monitor for vulnerable dependencies. All dependencies are regularly scanned for known vulnerabilities.

## Secure Development Lifecycle

1. **Design Phase**: Security requirements and threat modeling
2. **Development**: Secure coding practices and peer reviews
3. **Testing**: Security testing and vulnerability scanning
4. **Deployment**: Secure configuration and access controls
5. **Monitoring**: Continuous security monitoring and incident response

## Incident Response

In case of a security incident:

1. Our security team will investigate the report
2. We will develop and test a fix
3. We will release a security update
4. We will publish a security advisory

## Security Advisories

Security advisories are published in our [GitHub Security Advisories](https://github.com/your-org/codespace-templates/security/advisories) page.

## Responsible Disclosure

We follow responsible disclosure guidelines. Please allow us reasonable time to address security issues before public disclosure.

## Security Contacts

- **Security Team**: [security@example.com](mailto:security@example.com)
- **PGP Key**: [Link to PGP key]
