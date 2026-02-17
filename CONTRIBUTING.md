# Contributing to FOSSology Helm Chart

Thank you for your interest in contributing to the FOSSology Helm chart! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

This project follows the [FOSSology Code of Conduct](https://www.fossology.org/code-of-conduct/). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- Helm 3.0+
- kubectl configured to access your cluster
- Git

### Development Tools

- [helm-docs](https://github.com/norwoodj/helm-docs) for documentation generation
- [chart-testing](https://github.com/helm/chart-testing) for testing
- [kubeval](https://github.com/instrumenta/kubeval) for Kubernetes manifest validation

## Development Setup

1. **Fork and clone the repository**:
   ```bash
   git clone https://github.com/your-username/fossology-helm.git
   cd fossology-helm
   ```

2. **Set up your development environment**:
   ```bash
   # Install development dependencies
   helm plugin install https://github.com/chartmuseum/helm-push
   helm plugin install https://github.com/helm/helm-2to3
   
   # Add required repositories
   helm repo add cnpg https://cloudnative-pg.github.io/charts
   helm repo update
   ```

3. **Install dependencies**:
   ```bash
   cd helm/fossology
   helm dependency update
   ```

## Making Changes

### Branch Naming

Use descriptive branch names:
- `feature/add-monitoring-support`
- `fix/ingress-tls-configuration`
- `docs/update-installation-guide`

### Commit Messages

Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Examples:
- `feat(cnpg): add backup configuration support`
- `fix(ingress): correct TLS certificate handling`
- `docs(readme): update installation instructions`

### Code Style

1. **YAML Formatting**:
   - Use 2 spaces for indentation
   - Keep lines under 120 characters
   - Use meaningful variable names

2. **Template Guidelines**:
   - Use `{{- }}` for whitespace control
   - Include helpful comments
   - Follow Helm best practices

3. **Values File**:
   - Provide sensible defaults
   - Include comprehensive comments
   - Group related configurations

### Documentation

- Update README.md for significant changes
- Add examples for new features
- Update CHANGELOG.md
- Include inline comments in templates

## Testing

### Local Testing

1. **Lint the chart**:
   ```bash
   helm lint helm/fossology
   ```

2. **Template validation**:
   ```bash
   helm template test helm/fossology --debug
   ```

3. **Dry run installation**:
   ```bash
   helm install test helm/fossology --dry-run --debug
   ```

4. **Test with different values**:
   ```bash
   helm template test helm/fossology -f examples/basic-deployment.yaml
   helm template test helm/fossology -f examples/production-cnpg.yaml
   ```

### Integration Testing

1. **Install in test cluster**:
   ```bash
   # Basic installation
   helm install test-basic helm/fossology -f examples/basic-deployment.yaml
   
   # Wait for deployment
   kubectl wait --for=condition=available --timeout=300s deployment/test-basic-fossology-web
   
   # Test functionality
   kubectl port-forward svc/test-basic-fossology-web 8080:80
   # Visit http://localhost:8080
   
   # Cleanup
   helm uninstall test-basic
   ```

2. **Test upgrades**:
   ```bash
   # Install previous version
   helm install test-upgrade helm/fossology --version 0.9.0
   
   # Upgrade to current version
   helm upgrade test-upgrade helm/fossology
   
   # Verify upgrade
   kubectl rollout status deployment/test-upgrade-fossology-web
   ```

### Automated Testing

We use GitHub Actions for CI/CD. Tests include:
- Helm linting
- Template validation
- Installation testing
- Upgrade testing

## Submitting Changes

### Pull Request Process

1. **Create a pull request** with:
   - Clear title and description
   - Reference to related issues
   - List of changes made
   - Testing performed

2. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Helm lint passes
   - [ ] Template validation passes
   - [ ] Installation tested
   - [ ] Upgrade tested
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Documentation updated
   - [ ] CHANGELOG.md updated
   - [ ] Examples updated (if applicable)
   ```

3. **Review Process**:
   - Maintainers will review your PR
   - Address feedback promptly
   - Ensure CI checks pass
   - Squash commits if requested

### Documentation Updates

For documentation-only changes:
- Update relevant files
- Test documentation locally
- Ensure links work correctly
- Check formatting and grammar

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

1. Update version in `Chart.yaml`
2. Update `CHANGELOG.md`
3. Test release candidate
4. Create release tag
5. Publish to chart repository

## Getting Help

- **Questions**: Open a [GitHub Discussion](https://github.com/fossology/fossology-helm/discussions)
- **Bugs**: Create a [GitHub Issue](https://github.com/fossology/fossology-helm/issues)
- **Security**: Email [fossology-security@fossology.org](mailto:fossology-security@fossology.org)
- **Community**: Join the [FOSSology mailing list](https://lists.fossology.org/g/fossology)

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- GitHub contributors list
- Release notes

Thank you for contributing to FOSSology! 🎉