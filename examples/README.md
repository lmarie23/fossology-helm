# FOSSology Helm Chart Examples

This directory contains example configurations for different deployment scenarios of the FOSSology Helm chart.

## Available Examples

### 1. Basic Deployment (`basic-deployment.yaml`)

A minimal configuration suitable for development, testing, or small-scale deployments.

**Features:**
- Single replica
- Embedded PostgreSQL database
- Basic ingress configuration
- Minimal resource allocation

**Usage:**
```bash
helm install fossology . -f examples/basic-deployment.yaml
```

### 2. Production with CloudNativePG (`production-cnpg.yaml`)

A production-ready configuration with high availability PostgreSQL using CloudNativePG operator.

**Features:**
- Multiple replicas with anti-affinity
- High availability PostgreSQL cluster (3 instances)
- Automated backups to S3
- Production resource allocation
- TLS-enabled ingress
- Monitoring and alerting

**Prerequisites:**
- CloudNativePG operator installed
- S3 bucket for backups
- cert-manager for TLS certificates

**Usage:**
```bash
# Create backup credentials secret first
kubectl create secret generic backup-creds \
  --from-literal=ACCESS_KEY_ID=your-access-key \
  --from-literal=SECRET_ACCESS_KEY=your-secret-key

# Install with production configuration
helm install fossology . -f examples/production-cnpg.yaml
```

### 3. External Database (`external-database.yaml`)

Configuration for connecting to an existing external PostgreSQL database.

**Features:**
- No embedded database
- External database connection
- Support for database secrets
- Private registry support

**Prerequisites:**
- External PostgreSQL database
- Database credentials (preferably as Kubernetes secret)

**Usage:**
```bash
# Create database secret
kubectl create secret generic fossology-db-secret \
  --from-literal=db_password=your-database-password

# Install with external database
helm install fossology . -f examples/external-database.yaml
```

## Customizing Examples

You can combine and modify these examples to suit your specific needs:

1. **Copy an example file:**
   ```bash
   cp examples/basic-deployment.yaml my-values.yaml
   ```

2. **Modify the configuration** according to your requirements

3. **Install with your custom values:**
   ```bash
   helm install my-fossology . -f my-values.yaml
   ```

## Common Customizations

### Changing the Image Version

```yaml
image:
  repository: fossology/fossology
  tag: "4.3.0"  # Use specific version
```

### Configuring Resource Limits

```yaml
resources:
  limits:
    cpu: 4000m
    memory: 8Gi
  requests:
    cpu: 2000m
    memory: 4Gi
```

### Setting up TLS

```yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  tls:
    - secretName: fossology-tls
      hosts:
        - fossology.yourdomain.com
```

### Configuring Persistence

```yaml
persistence:
  enabled: true
  accessMode: ReadWriteMany  # For multi-replica deployments
  size: 100Gi
  storageClass: "fast-ssd"
```

## Validation

Before deploying, you can validate your configuration:

```bash
# Dry run to check for errors
helm install fossology . -f your-values.yaml --dry-run

# Template rendering to see generated manifests
helm template fossology . -f your-values.yaml
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues:**
   - Verify database credentials
   - Check network connectivity
   - Ensure database exists and user has proper permissions

2. **Storage Issues:**
   - Verify storage class exists
   - Check PVC status: `kubectl get pvc`
   - Ensure sufficient storage quota

3. **Ingress Issues:**
   - Verify ingress controller is installed
   - Check DNS resolution
   - Validate TLS certificates

### Getting Help

- Check pod logs: `kubectl logs -l app.kubernetes.io/name=fossology`
- Describe resources: `kubectl describe pod <pod-name>`
- Check events: `kubectl get events --sort-by=.metadata.creationTimestamp`

For more detailed troubleshooting, refer to the main [README.md](../README.md) file.