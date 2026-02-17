# GitLab CI/CD Setup for FOSSology Helm Chart

This document explains how to configure and use the GitLab CI/CD pipeline for the FOSSology Helm chart using the [to-be-continuous Helm template](https://to-be-continuous.gitlab.io/doc/ref/helm/).

## Overview

The GitLab CI/CD pipeline uses the **to-be-continuous Helm template v9.2.3+** and provides:
- **Validation**: Helm chart linting, YAML validation, and Kube-Score analysis
- **Testing**: Optional Helm tests with chart testing capabilities
- **Security**: Security scanning and vulnerability checks (SAST, Secret Detection)
- **Packaging**: Helm chart packaging with semantic versioning support
- **Publishing**: Push to OCI registries, traditional Helm repositories, or GitLab Package Registry
- **Deployment**: Multi-environment deployment (review, integration, staging, production)

## Pipeline Jobs

The to-be-continuous Helm template provides the following jobs:

### Validation Jobs
- **helm-lint**: Validates Helm chart syntax and templates using `helm lint`
- **helm-values-*-lint**: YAML linting of values files using yamllint
- **helm-*-score**: Kubernetes resource analysis using Kube-Score

### Package Job
- **helm-package**: Packages the Helm chart with semantic versioning support
  - Integrates with semantic-release for automatic versioning
  - Supports snapshot builds for development branches
  - Generates package output variables for downstream jobs

### Publish Job
- **helm-publish**: Publishes packaged charts to registries
  - Supports OCI registries (GitLab Container Registry, Harbor, AWS ECR)
  - Supports traditional Helm repositories
  - Supports GitLab Package Registry
  - Configurable publish strategies (manual, auto, disabled)

### Deployment Jobs (Optional)
- **helm-review-deploy**: Deploy to review environments (feature branches)
- **helm-integ-deploy**: Deploy to integration environment (develop branch)
- **helm-staging-deploy**: Deploy to staging environment (main/master branch)
- **helm-prod-deploy**: Deploy to production environment (main/master branch)
- **helm-*-cleanup**: Cleanup deployment environments

### Test Job (Optional)
- **helm-test**: Runs Helm tests if enabled

### Security Jobs (GitLab Templates)
- **sast**: Static Application Security Testing
- **secret_detection**: Detects secrets in code

## Configuration

The to-be-continuous Helm template uses component inputs and GitLab CI/CD variables for configuration. Configure these in your GitLab project settings under **Settings > CI/CD > Variables**.

### Component Inputs (in .gitlab-ci.yml)

Basic configuration is done through component inputs:

```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
    inputs:
      # Base application configuration
      base-app-name: "fossology"
      
      # Publishing configuration
      publish-strategy: "auto"  # manual, auto, none
      publish-url: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"
      
      # Environment configuration
      review-enabled: false
      staging-enabled: false
      prod-enabled: false
```

### Required Variables

#### Publishing Configuration
```bash
# For GitLab Container Registry (OCI) - Default
HELM_PUBLISH_URL: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"
HELM_PUBLISH_USER: $CI_REGISTRY_USER
HELM_PUBLISH_PASSWORD: $CI_REGISTRY_PASSWORD

# For GitLab Package Registry (Helm)
HELM_PUBLISH_URL: "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/release"
HELM_PUBLISH_USER: "gitlab-ci-token"
HELM_PUBLISH_PASSWORD: $CI_JOB_TOKEN

# For external OCI registry
HELM_PUBLISH_URL: "oci://harbor.example.com/charts"
HELM_PUBLISH_USER: "your-username"
HELM_PUBLISH_PASSWORD: "your-password"
```

#### Kubernetes Configuration (for deployments)
```bash
# Default kubeconfig (base64 encoded)
HELM_DEFAULT_KUBE_CONFIG: "LS0tLS1CRUdJTi..."

# Environment-specific kubeconfigs
HELM_STAGING_KUBE_CONFIG: "LS0tLS1CRUdJTi..."
HELM_PROD_KUBE_CONFIG: "LS0tLS1CRUdJTi..."
```

### Optional Variables
```bash
# Global configuration
HELM_BASE_APP_NAME: "fossology"
HELM_ENVIRONMENT_URL: "https://%{environment_name}.example.com"

# Job configuration
HELM_LINT_DISABLED: "false"
HELM_YAMLLINT_DISABLED: "false"
HELM_KUBE_SCORE_DISABLED: "false"
HELM_TEST_ENABLED: "false"

# Repository configuration
HELM_REPOS: "stable@https://charts.helm.sh/stable bitnami@https://charts.bitnami.com/bitnami"
```

## Publishing Setup

The to-be-continuous template supports multiple publishing methods for Helm charts.

### Option 1: GitLab Container Registry (OCI) - Recommended

GitLab Container Registry supports OCI artifacts including Helm charts. No additional setup required.

```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"

# Variables (automatically set by GitLab)
HELM_PUBLISH_USER: $CI_REGISTRY_USER
HELM_PUBLISH_PASSWORD: $CI_REGISTRY_PASSWORD
```

### Option 2: GitLab Package Registry (Helm)

Use GitLab's dedicated Helm package registry:

```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/release"

# Variables
HELM_PUBLISH_USER: "gitlab-ci-token"
HELM_PUBLISH_PASSWORD: $CI_JOB_TOKEN
```

### Option 3: External OCI Registry (Harbor, AWS ECR, etc.)

Configure external OCI registries:

```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "oci://harbor.example.com/charts"

# Variables for Harbor
HELM_PUBLISH_USER: "robot$helm-pusher"
HELM_PUBLISH_PASSWORD: "your-robot-token"

# Variables for AWS ECR
HELM_PUBLISH_USER: "AWS"
HELM_PUBLISH_PASSWORD: "$(aws ecr get-login-password)"
```

### Option 4: Traditional Chart Repository

For traditional HTTP-based chart repositories:

```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "https://charts.example.com/api/charts"
  publish-method: "post"  # or "put"

# Variables
HELM_PUBLISH_USER: "your-username"
HELM_PUBLISH_PASSWORD: "your-password"
```

## Deployment Environments

The to-be-continuous template supports multiple deployment environments with different triggers and configurations.

### Environment Types

1. **Review Environments**: Dynamic environments for feature branches
2. **Integration Environment**: For the develop/integration branch
3. **Staging Environment**: Pre-production environment on main/master branch
4. **Production Environment**: Production deployment on main/master branch

### Enabling Environments

Enable environments through component inputs:

```yaml
# In .gitlab-ci.yml
inputs:
  review-enabled: true
  staging-enabled: true
  prod-enabled: true
  
  # Environment URLs (supports variable expansion)
  environment-url: "https://%{environment_name}.example.com"
  prod-environment-url: "https://fossology.example.com"
```

### Kubernetes Configuration

#### Generating Kubeconfig

1. **For default cluster:**
   ```bash
   kubectl config view --raw --minify | base64 -w 0
   ```
   Set this as `HELM_DEFAULT_KUBE_CONFIG` variable.

2. **For environment-specific clusters:**
   ```bash
   # Staging cluster
   kubectl config view --raw --minify | base64 -w 0
   # Set as HELM_STAGING_KUBE_CONFIG
   
   # Production cluster
   kubectl config view --raw --minify | base64 -w 0
   # Set as HELM_PROD_KUBE_CONFIG
   ```

#### Service Account Setup (Recommended)

Create a dedicated service account for GitLab CI:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab-ci-helm
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gitlab-ci-helm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gitlab-ci-helm
  namespace: default
```

#### Environment Variables

Configure environment-specific variables:

```bash
# Default configuration
HELM_DEFAULT_KUBE_CONFIG: <base64-kubeconfig>
KUBE_NAMESPACE: "default"

# Review environments
HELM_REVIEW_NAMESPACE: "review"
HELM_REVIEW_VALUES: "values-review.yaml"
HELM_REVIEW_AUTOSTOP_DURATION: "4 hours"

# Staging environment
HELM_STAGING_NAMESPACE: "staging"
HELM_STAGING_VALUES: "values-staging.yaml"
HELM_STAGING_KUBE_CONFIG: <base64-kubeconfig>

# Production environment
HELM_PROD_NAMESPACE: "production"
HELM_PROD_VALUES: "values-production.yaml"
HELM_PROD_DEPLOY_STRATEGY: "manual"  # or "auto"
HELM_PROD_KUBE_CONFIG: <base64-kubeconfig>
```

## Pipeline Triggers

The to-be-continuous template provides automatic and manual triggers based on Git events and configuration.

### Automatic Triggers
- **All Branches**: Validation jobs (helm-lint, helm-values-lint, helm-score)
- **Main/Master Branch**: Full pipeline including packaging
- **Feature Branches**: Review environment deployment (if enabled)
- **Develop Branch**: Integration environment deployment (if enabled)
- **Tags**: Production deployment (if enabled and strategy is auto)

### Manual Triggers
- **helm-publish**: Manual chart publishing (if publish-strategy is manual)
- **helm-staging-deploy**: Manual staging deployment
- **helm-prod-deploy**: Manual production deployment (if strategy is manual)
- **helm-*-cleanup**: Manual environment cleanup

### Publishing Triggers

Configure when charts are published using the `publish-on` input:

```yaml
inputs:
  publish-on: "prod"      # Only on production branch
  # publish-on: "protected" # On protected branches
  # publish-on: "all"       # On all branches
  # publish-on: "tag"       # Only on Git tags
```

## Usage Examples

### 1. Basic Setup

Configure your [`.gitlab-ci.yml`](.gitlab-ci.yml):

```yaml
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
    inputs:
      base-app-name: "fossology"
      publish-strategy: "auto"
      publish-url: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"
```

### 2. Development Workflow
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
# Pipeline runs: helm-lint, helm-values-lint, helm-score
```

### 3. Release Workflow

#### With Semantic Release (Recommended)
```bash
# Use conventional commits
git commit -m "feat: add new deployment option"
git commit -m "fix: resolve ingress configuration issue"

# Push to main branch
git push origin main

# Pipeline automatically:
# 1. Determines next version using semantic-release
# 2. Packages chart with new version
# 3. Publishes to registry
```

#### Manual Versioning
```bash
# Update chart version in Chart.yaml
sed -i 's/version: 1.0.0/version: 1.0.1/' Chart.yaml

# Commit changes
git add Chart.yaml
git commit -m "Release version 1.0.1"
git push origin main

# Create and push tag (optional)
git tag v1.0.1
git push origin v1.0.1
```

### 4. Installing Released Charts

#### From GitLab Container Registry (OCI)
```bash
# Login to registry
helm registry login $CI_REGISTRY

# Install chart
helm install fossology oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts/fossology --version 1.0.1
```

#### From GitLab Package Registry
```bash
# Add repository
helm repo add fossology ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/release

# Update repository
helm repo update

# Install chart
helm install fossology fossology/fossology --version 1.0.1
```

### 5. Environment Deployment

Enable and configure environments:

```yaml
# In .gitlab-ci.yml
inputs:
  staging-enabled: true
  prod-enabled: true
  staging-environment-url: "https://fossology-staging.example.com"
  prod-environment-url: "https://fossology.example.com"
```

Configure environment variables:
```bash
# Staging deployment
HELM_STAGING_KUBE_CONFIG: <base64-kubeconfig>
HELM_STAGING_VALUES: "values-staging.yaml"

# Production deployment
HELM_PROD_KUBE_CONFIG: <base64-kubeconfig>
HELM_PROD_VALUES: "values-production.yaml"
HELM_PROD_DEPLOY_STRATEGY: "manual"
```

## Troubleshooting

### Common Issues

1. **Publishing Failed**
   - Verify `HELM_PUBLISH_*` variables are correctly set
   - Check registry permissions for the user/token
   - Ensure OCI URLs are prefixed with `oci://`
   - For GitLab Package Registry, verify project permissions

2. **Deployment Failed**
   - Verify `HELM_*_KUBE_CONFIG` variables are valid base64 encoded kubeconfig
   - Check cluster connectivity and permissions
   - Verify namespace exists or can be created
   - Check if values files exist for the environment

3. **Chart Validation Failed**
   - Review helm-lint job output for syntax errors
   - Check yamllint output for YAML formatting issues
   - Review kube-score output for Kubernetes best practices

4. **Environment Variables Not Recognized**
   - Ensure you're using the correct variable names for the template version
   - Check if variables are set at the correct scope (project/group)
   - Verify variable expansion settings in GitLab

### Debug Commands

```bash
# Test chart locally with to-be-continuous tools
helm lint .
helm template fossology . --debug

# Test values file syntax
yamllint values.yaml

# Test Kubernetes resources
helm template fossology . | kubectl apply --dry-run=client -f -

# Test registry authentication
helm registry login $HELM_PUBLISH_URL

# Test chart packaging
helm package . --dependency-update

# Test OCI push
helm push fossology-1.0.0.tgz oci://registry.example.com/charts
```

### Template-Specific Debugging

```bash
# Check template version and inputs
grep -A 10 "to-be-continuous/helm" .gitlab-ci.yml

# Verify variable substitution in values files
# Variables should use ${VAR} or %{VAR} syntax

# Check environment variable availability
echo $HELM_PUBLISH_URL
echo $HELM_BASE_APP_NAME
```

## Advanced Features

### Hook Scripts

The template supports custom hook scripts for deployment and cleanup:

```bash
# Create executable scripts in your repository
chmod +x helm-pre-deploy.sh helm-post-deploy.sh
chmod +x helm-pre-delete.sh helm-post-delete.sh

# Scripts have access to environment variables:
# $environment_name, $environment_type, $hostname, $kube_namespace
```

### Variable Substitution in Values Files

Use variable substitution in your values files:

```yaml
# values.yaml
app:
  name: "${environment_name}"
  type: "${environment_type}"
  url: "https://${hostname}"
  
# Prevent substitution with # nosubst comment
staticValue: "${DONT_SUBSTITUTE}" # nosubst
```

### Semantic Release Integration

Enable automatic versioning with semantic-release:

```yaml
# Add semantic-release template
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/semantic-release/gitlab-ci-semantic-release@latest"
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
    inputs:
      # Semantic release integration is enabled by default
      semrel-release-disabled: false
```

### Variants

The template supports several variants for specific use cases:

#### Vault Variant
```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm-vault@9.2.3"
    inputs:
      vault-base-url: "https://vault.example.com/v1"
```

#### Google Cloud Variant
```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm-gcp@9.2.3"
    inputs:
      gcp-oidc-provider: "projects/123/locations/global/workloadIdentityPools/pool/providers/gitlab"
      gcp-oidc-account: "service-account@project.iam.gserviceaccount.com"
```

#### AWS EKS Variant
```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm-eks@9.2.3"
    inputs:
      aws-region: "us-east-1"
      aws-oidc-role-arn: "arn:aws:iam::123456789012:role/gitlab-ci-role"
```

## Security Considerations

1. **Use least privilege**: Create dedicated service accounts with minimal required permissions
2. **Protect variables**: Mark sensitive variables as "Protected" and "Masked" in GitLab
3. **Regular updates**: Keep Helm, kubectl, and other tools updated
4. **Scan dependencies**: Regularly scan chart dependencies for vulnerabilities
5. **Network policies**: Implement network policies in target clusters
6. **Secret management**: Use external secret management (Vault, AWS Secrets Manager, etc.)

## Monitoring and Alerts

Consider setting up monitoring for:
- Pipeline success/failure rates
- Deployment health checks
- Chart registry storage usage
- Security scan results
- Environment deployment status

## Support

For issues with the GitLab CI/CD pipeline:
1. Check pipeline logs in GitLab CI/CD interface
2. Review this documentation and the [to-be-continuous documentation](https://to-be-continuous.gitlab.io/doc/ref/helm/)
3. Check GitLab CI/CD documentation
4. Review the [to-be-continuous project](https://gitlab.com/to-be-continuous/helm)
5. Contact the FOSSology team