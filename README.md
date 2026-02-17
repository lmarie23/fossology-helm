# fossology

A Helm chart for deploying FOSSology - an open source license compliance software system and toolkit

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.4.0](https://img.shields.io/badge/AppVersion-4.4.0-informational?style=flat-square)

## Overview

FOSSology is an open source license compliance software system and toolkit. As a toolkit you can run license, copyright and export control scans from the command line. As a system, a database and web ui are provided to give you a compliance workflow. License, copyright and export scanners are tools available to help with your compliance activities.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installation

### Add Helm Repository

```bash
helm repo add fossology https://fossology.github.io/fossology-helm
helm repo update
```

### Install Chart

```bash
# Install with default values
helm install my-fossology fossology/fossology

# Install with custom values
helm install my-fossology fossology/fossology -f my-values.yaml

# Install in specific namespace
helm install my-fossology fossology/fossology --namespace fossology --create-namespace
```

## Uninstallation

```bash
helm uninstall my-fossology
```

## Configuration

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| dbimage.enableTestDb | bool | `false` |  |
| dbimage.pullPolicy | string | `"IfNotPresent"` |  |
| dbimage.repository | string | `"postgres"` |  |
| dbimage.tag | float | `9.6` |  |
| fossology.db_host | string | `""` |  |
| fossology.db_name | string | `"fossology"` |  |
| fossology.db_password | string | `""` |  |
| fossology.db_port | int | `5432` |  |
| fossology.db_user | string | `"fossology"` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"fossology/fossology"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecret.create | bool | `false` |  |
| imagePullSecret.email | string | `""` |  |
| imagePullSecret.name | string | `""` |  |
| imagePullSecret.password | string | `""` |  |
| imagePullSecret.registry | string | `""` |  |
| imagePullSecret.username | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.class | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"fossology.example.com"` |  |
| ingress.hosts[0].paths[0] | string | `"/"` |  |
| nameOverride | string | `""` |  |
| namespace | string | `"default"` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteMany"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"10Gi"` |  |
| postgresql.database | string | `"app"` |  |
| postgresql.enabled | bool | `false` |  |
| postgresql.instances | int | `1` |  |
| postgresql.name | string | `"fossology-postgresql"` |  |
| postgresql.storage.size | string | `"8Gi"` |  |
| postgresql.username | string | `"app"` |  |
| replicaCount | int | `1` |  |
| resources.limits.cpu | string | `"2000m"` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | string | `"1000m"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| servicescheduler.port | int | `80` |  |
| servicescheduler.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |

## Examples

The chart includes several example configurations in the `examples/` directory:

- [`basic-deployment.yaml`](examples/basic-deployment.yaml) - Simple deployment with default PostgreSQL
- [`production-cnpg.yaml`](examples/production-cnpg.yaml) - Production setup with CloudNativePG
- [`external-database.yaml`](examples/external-database.yaml) - Using external database

### Basic Deployment

```bash
helm install fossology fossology/fossology -f examples/basic-deployment.yaml
```

### Production with CloudNativePG

```bash
helm install fossology fossology/fossology -f examples/production-cnpg.yaml
```

### External Database

```bash
helm install fossology fossology/fossology -f examples/external-database.yaml
```

## Database Options

### Built-in PostgreSQL (Default)

The chart includes a PostgreSQL deployment by default:

```yaml
postgresql:
  enabled: true
  auth:
    postgresPassword: "fossology"
    database: "fossology"
```

### CloudNativePG

For production environments, use CloudNativePG:

```yaml
cnpg:
  enabled: true
  cluster:
    instances: 3
    postgresql:
      parameters:
        max_connections: "200"
        shared_buffers: "256MB"
```

### External Database

Connect to an existing PostgreSQL instance:

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: "postgres.example.com"
  port: 5432
  database: "fossology"
  username: "fossology"
  existingSecret: "fossology-db-secret"
  existingSecretPasswordKey: "password"
```

## Persistence

### Storage Classes

Configure storage for different components:

```yaml
persistence:
  repository:
    enabled: true
    storageClass: "fast-ssd"
    size: "100Gi"
 
  uploads:
    enabled: true
    storageClass: "standard"
    size: "50Gi"
```

### Backup and Recovery

For production deployments, ensure regular backups:

```yaml
cnpg:
  enabled: true
  cluster:
    backup:
      enabled: true
      schedule: "0 2 * * *"
      retentionPolicy: "30d"
```

## Security

### Image Pull Secrets

For private registries:

```yaml
imagePullSecrets:
  - name: "my-registry-secret"
```

### External Secrets

Use external secret management:

```yaml
externalSecrets:
  enabled: true
  secretStore:
    name: "vault-backend"
    kind: "SecretStore"
```

## Monitoring and Observability

### Service Monitor

Enable Prometheus monitoring:

```yaml
serviceMonitor:
  enabled: true
  namespace: "monitoring"
  labels:
    release: "prometheus"
```

### Logging

Configure log levels:

```yaml
fossology:
  web:
    logLevel: "INFO"
  scheduler:
    logLevel: "DEBUG"
```

## Networking

### Ingress

Configure ingress for external access:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: fossology.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: fossology-tls
      hosts:
        - fossology.example.com
```

### Service Types

Choose appropriate service type:

```yaml
service:
  type: ClusterIP  # ClusterIP, NodePort, LoadBalancer
  port: 80
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   kubectl logs deployment/fossology-web
   kubectl describe pod -l app.kubernetes.io/name=fossology
   ```

2. **Storage Issues**
   ```bash
   kubectl get pvc
   kubectl describe pvc fossology-repository
   ```

3. **Resource Constraints**
   ```bash
   kubectl top pods
   kubectl describe nodes
   ```

### Debug Mode

Enable debug logging:

```yaml
fossology:
  web:
    logLevel: "DEBUG"
  scheduler:
    logLevel: "DEBUG"
```

## Upgrading

### Backup Before Upgrade

Always backup your data before upgrading:

```bash
# Backup database
kubectl exec -it fossology-postgresql-0 -- pg_dump -U fossology fossology > backup.sql

# Backup persistent volumes
kubectl get pvc
```

### Upgrade Process

```bash
# Update repository
helm repo update

# Check what will change
helm diff upgrade my-fossology fossology/fossology

# Perform upgrade
helm upgrade my-fossology fossology/fossology
```

## CI/CD and Release Management

This chart includes comprehensive CI/CD pipelines for both GitHub Actions and GitLab CI/CD.

### GitLab CI/CD Pipeline

The GitLab CI/CD pipeline ([`.gitlab-ci.yml`](.gitlab-ci.yml)) uses the [to-be-continuous Helm template](https://to-be-continuous.gitlab.io/doc/ref/helm/) and provides:

- **Validation**: Helm chart linting, YAML validation, and Kube-Score analysis
- **Testing**: Optional Helm tests with chart testing capabilities
- **Security**: Security scanning and vulnerability checks (SAST, Secret Detection)
- **Packaging**: Helm chart packaging with semantic versioning support
- **Publishing**: Push to OCI registries, traditional Helm repositories, or GitLab Package Registry
- **Deployment**: Multi-environment deployment (review, integration, staging, production)

#### Quick Setup

1. **Basic Configuration** in [`.gitlab-ci.yml`](.gitlab-ci.yml):
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

2. **Optional: Configure Publishing Variables** in GitLab project settings:
   ```bash
   # For GitLab Container Registry (default)
   HELM_PUBLISH_USER=$CI_REGISTRY_USER
   HELM_PUBLISH_PASSWORD=$CI_REGISTRY_PASSWORD
   
   # For external registries
   HELM_PUBLISH_USER=your-username
   HELM_PUBLISH_PASSWORD=your-password
   ```

3. **Optional: Configure Kubernetes Deployment**:
   ```bash
   HELM_DEFAULT_KUBE_CONFIG=<base64-encoded-kubeconfig>
   HELM_STAGING_KUBE_CONFIG=<base64-encoded-kubeconfig>
   HELM_PROD_KUBE_CONFIG=<base64-encoded-kubeconfig>
   ```

4. **Pipeline Triggers**:
   - **All Branches**: Validation jobs (helm-lint, helm-values-lint, helm-score)
   - **Main Branch**: Full pipeline including packaging and publishing
   - **Feature Branches**: Review environment deployment (if enabled)
   - **Tags**: Production deployment (if enabled)

For detailed setup instructions, see [`GITLAB_CI_SETUP.md`](GITLAB_CI_SETUP.md).

### GitHub Actions Pipeline

The GitHub Actions pipeline ([`.github/workflows/`](.github/workflows/)) provides similar functionality optimized for GitHub environments.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this chart.

## License

## Source Code

* <https://github.com/fossology/fossology>
* <https://github.com/fossology/fossology-helm>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| FOSSology Team | <fossology@fossology.org> | <https://www.fossology.org/> |

---

For more information about FOSSology, visit [https://www.fossology.org/](https://www.fossology.org/)