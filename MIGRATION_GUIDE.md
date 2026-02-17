# Migration Guide: to-be-continuous Helm Template

This document provides a migration guide for updating from the previous GitLab CI implementation to the new [to-be-continuous Helm template v9.2.3](https://to-be-continuous.gitlab.io/doc/ref/helm/).

## Key Changes

### Template Structure

**Before:**
```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2"
    inputs:
      publish-strategy: "auto"
```

**After:**
```yaml
include:
  - component: "$CI_SERVER_FQDN/to-be-continuous/helm/gitlab-ci-helm@9.2.3"
    inputs:
      base-app-name: "fossology"
      publish-strategy: "auto"
      publish-url: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"
      review-enabled: false
      staging-enabled: false
      prod-enabled: false
```

## Variable Mapping

### Publishing Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `HELM_REGISTRY_URL` | `HELM_PUBLISH_URL` | Add `oci://` prefix for OCI registries |
| `HELM_REGISTRY_USER` | `HELM_PUBLISH_USER` | Same functionality |
| `HELM_REGISTRY_PASSWORD` | `HELM_PUBLISH_PASSWORD` | Same functionality |
| `HELM_REGISTRY_PATH` | Include in `HELM_PUBLISH_URL` | Path is now part of the URL |

### Kubernetes Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `KUBE_CONFIG_STAGING` | `HELM_STAGING_KUBE_CONFIG` | Environment-specific kubeconfig |
| `KUBE_CONFIG_PRODUCTION` | `HELM_PROD_KUBE_CONFIG` | Environment-specific kubeconfig |
| N/A | `HELM_DEFAULT_KUBE_CONFIG` | Default kubeconfig for all environments |
| N/A | `KUBE_NAMESPACE` | Default Kubernetes namespace |

### Application Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| N/A | `HELM_BASE_APP_NAME` | Base application name (defaults to `$CI_PROJECT_NAME`) |
| `CHART_VERSION` | Use semantic-release or Chart.yaml | Version management changed |

### Environment Variables

| Old Variable | New Variable | Notes |
|--------------|--------------|-------|
| `STAGING_URL` | `HELM_STAGING_ENVIRONMENT_URL` | Environment-specific URL |
| `PRODUCTION_URL` | `HELM_PROD_ENVIRONMENT_URL` | Environment-specific URL |
| N/A | `HELM_ENVIRONMENT_URL` | Default URL pattern for all environments |

### New Environment Configuration

The template now supports multiple environment types with dedicated configuration:

```bash
# Review environments (feature branches)
HELM_REVIEW_ENABLED=true
HELM_REVIEW_NAMESPACE=review
HELM_REVIEW_VALUES=values-review.yaml
HELM_REVIEW_AUTOSTOP_DURATION="4 hours"

# Integration environment (develop branch)
HELM_INTEG_ENABLED=true
HELM_INTEG_NAMESPACE=integration
HELM_INTEG_VALUES=values-integration.yaml

# Staging environment (main/master branch)
HELM_STAGING_ENABLED=true
HELM_STAGING_NAMESPACE=staging
HELM_STAGING_VALUES=values-staging.yaml

# Production environment (main/master branch)
HELM_PROD_ENABLED=true
HELM_PROD_NAMESPACE=production
HELM_PROD_VALUES=values-production.yaml
HELM_PROD_DEPLOY_STRATEGY=manual
```

## Job Changes

### Old Jobs vs New Jobs

| Old Job | New Job | Notes |
|---------|---------|-------|
| `helm:lint` | `helm-lint` | Same functionality |
| `ct:lint` | `helm-values-*-lint` | YAML linting of values files |
| `ct:install` | `helm-test` | Optional Helm tests |
| `helm:security` | `helm-*-score` | Kube-Score analysis |
| `helm:package` | `helm-package` | Enhanced with semantic versioning |
| `helm:release:oci` | `helm-publish` | Unified publishing job |
| `helm:release:traditional` | `helm-publish` | Unified publishing job |
| `deploy:staging` | `helm-staging-deploy` | Environment-specific deployment |
| `deploy:production` | `helm-prod-deploy` | Environment-specific deployment |

## Publishing Methods

### GitLab Container Registry (OCI)

**Before:**
```bash
HELM_REGISTRY_URL=$CI_REGISTRY_URL
HELM_REGISTRY_USER=$CI_REGISTRY_USER
HELM_REGISTRY_PASSWORD=$CI_REGISTRY_PASSWORD
```

**After:**
```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "oci://$CI_REGISTRY/$CI_PROJECT_PATH/charts"

# Variables (automatically set)
HELM_PUBLISH_USER: $CI_REGISTRY_USER
HELM_PUBLISH_PASSWORD: $CI_REGISTRY_PASSWORD
```

### GitLab Package Registry

**New option:**
```yaml
# In .gitlab-ci.yml
inputs:
  publish-url: "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/release"

# Variables
HELM_PUBLISH_USER: "gitlab-ci-token"
HELM_PUBLISH_PASSWORD: $CI_JOB_TOKEN
```

## Migration Steps

1. **Update .gitlab-ci.yml:**
   - Update template version to `@9.2.3`
   - Add required component inputs
   - Configure environment settings

2. **Update Variables:**
   - Rename variables according to the mapping table
   - Add new environment-specific variables
   - Update registry URLs with `oci://` prefix if needed

3. **Create Environment Values Files:**
   - `values-review.yaml` (if review environments enabled)
   - `values-staging.yaml` (if staging environment enabled)
   - `values-production.yaml` (if production environment enabled)

4. **Test Pipeline:**
   - Create a test branch and verify validation jobs work
   - Test publishing to registry
   - Test environment deployments (if enabled)

## Benefits of Migration

1. **Enhanced Environment Management:** Support for review, integration, staging, and production environments
2. **Better Publishing Options:** Support for GitLab Package Registry and multiple OCI registries
3. **Improved Validation:** Enhanced linting with yamllint and Kube-Score
4. **Semantic Versioning:** Integration with semantic-release for automatic versioning
5. **Hook Scripts:** Support for custom deployment and cleanup scripts
6. **Variable Substitution:** Advanced variable substitution in values files
7. **Cloud Variants:** Support for Vault, GCP, and AWS EKS variants

## Support

For migration assistance:
1. Review the [to-be-continuous documentation](https://to-be-continuous.gitlab.io/doc/ref/helm/)
2. Check the updated [`GITLAB_CI_SETUP.md`](GITLAB_CI_SETUP.md)
3. Review the [`.gitlab-ci-variables.example`](.gitlab-ci-variables.example) file
4. Contact the FOSSology team for project-specific help