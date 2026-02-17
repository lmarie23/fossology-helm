# GitLab CI/CD Setup for FOSSology Helm Chart

This document explains how to configure and use the GitLab CI/CD pipeline for the FOSSology Helm chart release and deployment.

## Overview

The GitLab CI/CD pipeline provides:
- **Validation**: Helm chart linting and template validation
- **Testing**: Chart testing with Kubernetes integration tests
- **Security**: Security scanning and vulnerability checks
- **Packaging**: Helm chart packaging and indexing
- **Release**: Push to private OCI or traditional Helm registries
- **Deployment**: Automated deployment to staging and production environments

## Pipeline Stages

### 1. Validate Stage
- **helm:lint**: Validates Helm chart syntax and templates
- **ct:lint**: Uses chart-testing tool for comprehensive validation

### 2. Test Stage
- **ct:install**: Creates a Kind cluster and tests chart installation

### 3. Security Stage
- **helm:security**: Scans rendered templates for security issues
- **SAST**: Static Application Security Testing (GitLab template)
- **Secret Detection**: Detects secrets in code (GitLab template)

### 4. Package Stage
- **helm:package**: Packages the Helm chart and generates repository index

### 5. Release Stage
- **helm:release:oci**: Pushes chart to OCI-compatible registry
- **helm:release:traditional**: Pushes to traditional git-based Helm repository
- **release:notes**: Generates release notes from CHANGELOG.md

### 6. Deploy Stage
- **deploy:staging**: Deploys to staging environment (manual trigger)
- **deploy:production**: Deploys to production environment (manual trigger, tags only)

## Required GitLab CI/CD Variables

Configure these variables in your GitLab project settings under **Settings > CI/CD > Variables**:

### Registry Configuration
```bash
# For GitLab Container Registry (default)
HELM_REGISTRY_URL: $CI_REGISTRY_URL
HELM_REGISTRY_USER: $CI_REGISTRY_USER
HELM_REGISTRY_PASSWORD: $CI_REGISTRY_PASSWORD

# For external private registry
HELM_REGISTRY_URL: "https://your-registry.example.com"
HELM_REGISTRY_USER: "your-username"
HELM_REGISTRY_PASSWORD: "your-password"
```

### Kubernetes Configuration (for deployments)
```bash
# Base64 encoded kubeconfig for staging cluster
KUBE_CONFIG_STAGING: "LS0tLS1CRUdJTi..."

# Base64 encoded kubeconfig for production cluster
KUBE_CONFIG_PRODUCTION: "LS0tLS1CRUdJTi..."
```

### Optional Variables
```bash
# For traditional git-based Helm repository
HELM_REPO_URL: "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/charts/helm-charts.git"

# Custom chart version (overrides Chart.yaml)
CHART_VERSION: "1.0.1"

# Custom registry path
HELM_REGISTRY_PATH: "charts/fossology"
```

## Setting Up Private Registry

### Option 1: GitLab Container Registry (Recommended)

GitLab Container Registry supports OCI artifacts including Helm charts. No additional setup required.

```bash
# The pipeline will automatically use:
HELM_REGISTRY_URL: $CI_REGISTRY_URL
HELM_REGISTRY_USER: $CI_REGISTRY_USER
HELM_REGISTRY_PASSWORD: $CI_REGISTRY_PASSWORD
```

### Option 2: External OCI Registry (Harbor, AWS ECR, etc.)

Configure the registry variables:

```bash
# Example for Harbor
HELM_REGISTRY_URL: "https://harbor.example.com"
HELM_REGISTRY_USER: "robot$helm-pusher"
HELM_REGISTRY_PASSWORD: "your-robot-token"

# Example for AWS ECR
HELM_REGISTRY_URL: "123456789012.dkr.ecr.us-west-2.amazonaws.com"
HELM_REGISTRY_USER: "AWS"
HELM_REGISTRY_PASSWORD: "$(aws ecr get-login-password)"
```

### Option 3: Traditional Git-based Repository

Set up a separate Git repository for Helm charts:

```bash
HELM_REPO_URL: "https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/charts/helm-charts.git"
```

## Kubernetes Cluster Setup

### Generating Kubeconfig

1. **For staging cluster:**
   ```bash
   kubectl config view --raw --minify | base64 -w 0
   ```
   Set this as `KUBE_CONFIG_STAGING` variable.

2. **For production cluster:**
   ```bash
   kubectl config view --raw --minify | base64 -w 0
   ```
   Set this as `KUBE_CONFIG_PRODUCTION` variable.

### Service Account Setup (Recommended)

Create a dedicated service account for GitLab CI:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-ci
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gitlab-ci
  namespace: default
```

## Pipeline Triggers

### Automatic Triggers
- **Merge Requests**: Runs validation and testing stages
- **Main Branch**: Runs full pipeline including packaging
- **Tags**: Runs full pipeline including release to production

### Manual Triggers
- **Traditional Release**: Manual trigger for git-based repository
- **Staging Deployment**: Manual deployment to staging environment
- **Production Deployment**: Manual deployment to production (tags only)

## Usage Examples

### 1. Development Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes to chart
# ... edit files ...

# Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# Create merge request
# Pipeline runs validation and testing
```

### 2. Release Workflow
```bash
# Update chart version in Chart.yaml
sed -i 's/version: 1.0.0/version: 1.0.1/' Chart.yaml

# Update CHANGELOG.md
echo "## [1.0.1] - $(date +%Y-%m-%d)" >> CHANGELOG.md
echo "### Added" >> CHANGELOG.md
echo "- New feature description" >> CHANGELOG.md

# Commit changes
git add Chart.yaml CHANGELOG.md
git commit -m "Release version 1.0.1"
git push origin main

# Create and push tag
git tag v1.0.1
git push origin v1.0.1

# Pipeline runs full release process
```

### 3. Installing Released Chart

#### From OCI Registry
```bash
# Login to registry
helm registry login $HELM_REGISTRY_URL

# Install chart
helm install fossology oci://$HELM_REGISTRY_URL/path/to/fossology --version 1.0.1
```

#### From Traditional Repository
```bash
# Add repository
helm repo add fossology https://charts.example.com/

# Update repository
helm repo update

# Install chart
helm install fossology fossology/fossology --version 1.0.1
```

## Troubleshooting

### Common Issues

1. **Registry Authentication Failed**
   - Verify `HELM_REGISTRY_*` variables are correctly set
   - Check registry permissions for the user/token

2. **Kubernetes Deployment Failed**
   - Verify `KUBE_CONFIG_*` variables are valid base64 encoded kubeconfig
   - Check cluster connectivity and permissions

3. **Chart Testing Failed**
   - Review chart-testing configuration in `.github/ct.yaml`
   - Check if test values are appropriate for the testing environment

4. **Security Scan Failed**
   - Review security warnings in the pipeline logs
   - Update chart templates to address security concerns

### Debug Commands

```bash
# Test chart locally
helm lint .
helm template fossology . --debug

# Test with chart-testing
ct lint --config .github/ct.yaml --charts .

# Test registry push locally
helm package .
helm push fossology-1.0.0.tgz oci://registry.example.com/charts
```

## Security Considerations

1. **Use least privilege**: Create dedicated service accounts with minimal required permissions
2. **Protect variables**: Mark sensitive variables as "Protected" and "Masked" in GitLab
3. **Regular updates**: Keep Helm, kubectl, and other tools updated
4. **Scan dependencies**: Regularly scan chart dependencies for vulnerabilities
5. **Network policies**: Implement network policies in target clusters

## Monitoring and Alerts

Consider setting up monitoring for:
- Pipeline success/failure rates
- Deployment health checks
- Chart registry storage usage
- Security scan results

## Support

For issues with the GitLab CI/CD pipeline:
1. Check pipeline logs in GitLab CI/CD interface
2. Review this documentation
3. Check GitLab CI/CD documentation
4. Contact the FOSSology team