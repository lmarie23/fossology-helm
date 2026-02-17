# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the FOSSology Helm chart repository.

## Workflows Overview

### 🚀 [`release.yml`](workflows/release.yml)

**Trigger**: Git tags matching `v*` pattern or manual dispatch

**Purpose**: Automated chart release and publishing

**Features**:
- Chart validation and testing
- Semantic version management
- GitHub Releases creation with chart packages
- GitHub Pages publishing for Helm repository
- OCI registry publishing (GitHub Container Registry)
- Automatic chart version updates

**Usage**:
```bash
# Create and push a tag to trigger release
git tag v1.0.1
git push origin v1.0.1

# Or use manual dispatch from GitHub Actions UI
```

### 🔍 [`ci.yml`](workflows/ci.yml)

**Trigger**: Push to main/master branch or pull requests

**Purpose**: Continuous integration and testing

**Features**:
- Helm chart linting and validation
- Template rendering tests
- Example configuration testing
- Security vulnerability scanning
- Chart testing with kind cluster
- Documentation validation
- Version increment checking

### 📚 [`docs.yml`](workflows/docs.yml)

**Trigger**: Changes to chart files (values.yaml, Chart.yaml, templates, README.md)

**Purpose**: Automated documentation generation and validation

**Features**:
- Auto-generation of README.md using helm-docs
- Example validation against current chart
- Changelog update reminders
- Automatic documentation commits (on main branch)
- PR comments for documentation updates

### 🔄 [`dependency-update.yml`](workflows/dependency-update.yml)

**Trigger**: Weekly schedule (Mondays 9 AM UTC) or manual dispatch

**Purpose**: Automated dependency and version updates

**Features**:
- Helm chart dependency updates
- FOSSology version checking and updates
- Security vulnerability scanning
- Automated pull request creation
- Chart testing with updates

## Configuration Files

### [`ct.yaml`](ct.yaml)

Chart Testing configuration for helm/chart-testing action:
- Defines chart directories and excluded charts
- Configures Helm repositories
- Sets validation parameters
- Specifies additional test commands

### [`mlc_config.json`](mlc_config.json)

Markdown Link Check configuration:
- Ignores localhost and local IP patterns
- Configures HTTP headers for GitHub API
- Sets timeout and retry parameters
- Defines alive status codes

### [`README.md.gotmpl`](README.md.gotmpl)

Helm-docs template for generating comprehensive chart documentation:
- Chart metadata and badges
- Installation instructions
- Configuration examples
- Troubleshooting guides
- Best practices

## Setup Requirements

### Repository Settings

1. **GitHub Pages**: Enable GitHub Pages with source set to "GitHub Actions"
2. **Secrets**: No additional secrets required (uses GITHUB_TOKEN)
3. **Permissions**: Ensure Actions have write permissions for contents and packages

### Branch Protection

Recommended branch protection rules for main/master:
- Require pull request reviews
- Require status checks to pass
- Require branches to be up to date
- Include administrators

### Required Status Checks

Configure these checks as required:
- `lint-test`
- `security-scan`
- `chart-testing`
- `docs-validation`

## Release Process

### Automatic Release (Recommended)

1. **Prepare Release**:
   ```bash
   # Update Chart.yaml version
   sed -i 's/version: .*/version: 1.0.1/' Chart.yaml
   
   # Update CHANGELOG.md
   echo "## [1.0.1] - $(date +%Y-%m-%d)" >> CHANGELOG.md
   echo "### Added/Changed/Fixed" >> CHANGELOG.md
   
   # Commit changes
   git add Chart.yaml CHANGELOG.md
   git commit -m "chore: bump version to 1.0.1"
   git push origin main
   ```

2. **Create Release**:
   ```bash
   # Create and push tag
   git tag v1.0.1
   git push origin v1.0.1
   ```

3. **Verify Release**:
   - Check GitHub Actions for successful workflow runs
   - Verify GitHub Release was created
   - Confirm chart is available in GitHub Pages
   - Test installation from published repository

### Manual Release

Use the workflow dispatch feature in GitHub Actions UI:
1. Go to Actions → Release Helm Chart
2. Click "Run workflow"
3. Enter the version number (e.g., "1.0.1")
4. Click "Run workflow"

## Testing Locally

### Prerequisites

```bash
# Install required tools
helm plugin install https://github.com/helm/helm-docs
helm plugin install https://github.com/helm/chart-testing
```

### Run Tests

```bash
# Lint chart
helm lint .

# Test templates
helm template test . --debug

# Test with examples
helm template test . -f examples/basic-deployment.yaml

# Generate documentation
helm-docs --chart-search-root=. --template-files=.github/README.md.gotmpl

# Run chart testing
ct lint --config .github/ct.yaml
```

## Monitoring and Maintenance

### Workflow Monitoring

- Monitor workflow runs in GitHub Actions tab
- Set up notifications for failed workflows
- Review security scan results regularly
- Check dependency update PRs weekly

### Maintenance Tasks

- Review and merge dependency update PRs
- Update workflow versions quarterly
- Monitor chart download statistics
- Respond to community issues and PRs

## Troubleshooting

### Common Issues

1. **Release Workflow Fails**:
   - Check Chart.yaml syntax
   - Verify all required files exist
   - Ensure version follows semantic versioning

2. **Documentation Generation Fails**:
   - Verify helm-docs template syntax
   - Check values.yaml formatting
   - Ensure all referenced files exist

3. **Chart Testing Fails**:
   - Review ct.yaml configuration
   - Check example files validity
   - Verify Helm repository accessibility

### Debug Steps

1. **Enable Debug Logging**:
   ```yaml
   # Add to workflow steps
   - name: Debug
     run: |
       helm template test . --debug
       helm lint . --debug
   ```

2. **Check Workflow Logs**:
   - Review detailed logs in GitHub Actions
   - Look for specific error messages
   - Check artifact uploads/downloads

3. **Local Reproduction**:
   ```bash
   # Reproduce workflow steps locally
   act -j lint-test  # Using nektos/act
   ```

## Contributing

When contributing to workflows:

1. Test changes in a fork first
2. Follow existing naming conventions
3. Add appropriate comments and documentation
4. Update this README for significant changes
5. Consider backward compatibility

## Security

- Workflows use minimal required permissions
- No secrets are stored in repository
- All external actions are pinned to specific versions
- Security scanning is integrated into CI/CD

---

For questions about the CI/CD setup, please create an issue or contact the maintainers.