# Publishing Guide for FOSSology Helm Chart

This document provides instructions for publishing the FOSSology Helm chart to various repositories.

## Pre-Publication Checklist

- [x] **License**: Apache 2.0 license added
- [x] **Chart.yaml**: Complete metadata with proper versioning
- [x] **Documentation**: Comprehensive README.md with examples
- [x] **Examples**: Multiple deployment scenarios provided
- [x] **Values**: Well-documented values.yaml with sensible defaults
- [x] **Templates**: All Kubernetes manifests properly templated
- [x] **Security**: Image pull secrets and external secrets support
- [x] **Testing**: Examples for different environments

## Chart Structure

```
helm/fossology/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration
├── values-cnpg.yaml        # CloudNativePG example
├── LICENSE                 # Apache 2.0 license
├── README.md               # Comprehensive documentation
├── CHANGELOG.md            # Version history
├── CONTRIBUTING.md         # Contribution guidelines
├── PUBLISHING.md           # This file
├── .helmignore             # Files to ignore during packaging
├── templates/              # Kubernetes manifests
│   ├── _helpers.tpl
│   ├── NOTES.txt
│   ├── cnpg-cluster.yaml
│   ├── db-deployment.yaml
│   ├── imagepullsecret.yaml
│   ├── ingress.yaml
│   ├── pvc.yaml
│   ├── scheduler-deployment.yaml
│   ├── secrets.yaml
│   ├── service-db.yaml
│   ├── service-scheduler.yaml
│   ├── service.yaml
│   ├── web-deployment.yaml
│   └── tests/
│       └── test-connection.yaml
└── examples/               # Deployment examples
    ├── README.md
    ├── basic-deployment.yaml
    ├── production-cnpg.yaml
    └── external-database.yaml
```

## Publishing Steps

### 1. Validate the Chart

Before publishing, validate the chart:

```bash
# Lint the chart
helm lint helm/fossology

# Test template rendering
helm template test helm/fossology --debug

# Test installation (dry run)
helm install test helm/fossology --dry-run --debug

# Test with different values
helm template test helm/fossology -f helm/fossology/examples/basic-deployment.yaml
helm template test helm/fossology -f helm/fossology/examples/production-cnpg.yaml
```

### 2. Package the Chart

```bash
# Package the chart
helm package helm/fossology

# This creates: fossology-1.0.0.tgz
```

### 3. Publish to Artifact Hub

To publish to [Artifact Hub](https://artifacthub.io/):

1. **Create a GitHub repository** for the Helm chart
2. **Set up GitHub Pages** or use GitHub Releases
3. **Create an Artifact Hub metadata file**:

```yaml
# .artifacthub/metadata.yaml
repositoryID: fossology-helm
owners:
  - name: FOSSology Team
    email: fossology@fossology.org
```

4. **Submit to Artifact Hub** via their web interface

### 4. Publish to Helm Repository

#### Option A: GitHub Pages

1. **Create `gh-pages` branch**:
```bash
git checkout --orphan gh-pages
git rm -rf .
```

2. **Add chart packages**:
```bash
helm package helm/fossology
helm repo index . --url https://fossology.github.io/fossology-helm
git add .
git commit -m "Initial chart repository"
git push origin gh-pages
```

3. **Enable GitHub Pages** in repository settings

#### Option B: ChartMuseum

```bash
# Install ChartMuseum
helm plugin install https://github.com/chartmuseum/helm-push

# Add repository
helm repo add chartmuseum https://your-chartmuseum.com

# Push chart
helm cm-push fossology-1.0.0.tgz chartmuseum
```

### 5. Publish to OCI Registry

```bash
# Login to registry
helm registry login registry.example.com

# Push chart
helm push fossology-1.0.0.tgz oci://registry.example.com/charts
```

## Version Management

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features (backward compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes (backward compatible)

### Release Process

1. **Update version** in `Chart.yaml`
2. **Update `CHANGELOG.md`** with changes
3. **Test thoroughly** with new version
4. **Create Git tag**: `git tag v1.0.0`
5. **Push tag**: `git push origin v1.0.0`
6. **Package and publish** new version

## Testing Before Publication

### Local Testing

```bash
# Install locally
helm install test-fossology helm/fossology

# Test upgrade
helm upgrade test-fossology helm/fossology

# Test with different configurations
helm install test-basic helm/fossology -f helm/fossology/examples/basic-deployment.yaml
helm install test-prod helm/fossology -f helm/fossology/examples/production-cnpg.yaml

# Cleanup
helm uninstall test-fossology test-basic test-prod
```

### CI/CD Pipeline

Create GitHub Actions workflow:

```yaml
# .github/workflows/helm.yml
name: Helm Chart CI
on: [push, pull_request]
jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: azure/setup-helm@v3
    - name: Lint chart
      run: helm lint helm/fossology
    - name: Test templates
      run: helm template test helm/fossology
```

## Documentation Updates

When publishing:

1. **Update README.md** with installation instructions
2. **Add repository information**:
```bash
helm repo add fossology https://fossology.github.io/fossology-helm
helm repo update
helm install my-fossology fossology/fossology
```

3. **Update examples** with repository references

## Security Considerations

- **Scan images** for vulnerabilities
- **Review dependencies** for security issues
- **Validate RBAC** permissions
- **Test with security policies** (Pod Security Standards)
- **Document security best practices**

## Support and Maintenance

- **Monitor issues** in GitHub repository
- **Respond to community feedback**
- **Keep dependencies updated**
- **Test with new Kubernetes versions**
- **Maintain backward compatibility**

## Metrics and Analytics

Track chart usage:
- **Download statistics** from Artifact Hub
- **GitHub repository metrics** (stars, forks, issues)
- **Community feedback** and contributions
- **Version adoption** rates

## Legal Compliance

- **Verify license compatibility** of all components
- **Include proper attributions**
- **Document third-party dependencies**
- **Ensure compliance** with FOSSology project guidelines

---

For questions about publishing, contact the FOSSology team at fossology@fossology.org or create an issue in the GitHub repository.