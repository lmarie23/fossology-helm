# FOSSology Helm Chart

A Helm chart for deploying FOSSology - an open source license compliance software system and toolkit.

## Description

FOSSology is a open source license compliance software system and toolkit. As a toolkit you can run license, copyright and export control scans from the command line. As a system, a database and web ui are provided to give you a compliance workflow. License, copyright and export scanners are tools available to help with your compliance activities.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

### From Helm Repository (Recommended)

```bash
# Add the FOSSology Helm repository
helm repo add fossology https://fossology.github.io/fossology-helm
helm repo update

# Install the chart
helm install my-fossology fossology/fossology
```

### From Source

To install the chart with the release name `fossology` from source:

```bash
helm install fossology .
```

### With Custom Values

```bash
# Install with custom configuration
helm install my-fossology fossology/fossology -f my-values.yaml

# Install in specific namespace
helm install my-fossology fossology/fossology --namespace fossology --create-namespace
```

The command deploys FOSSology on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## CI/CD and Releases

This chart includes comprehensive GitHub Actions workflows for automated testing, documentation generation, and releases:

- **🚀 Automated Releases**: Tagged releases trigger automatic chart packaging and publishing
- **🔍 Continuous Integration**: Pull requests and pushes are automatically tested
- **📚 Documentation**: Chart documentation is auto-generated and validated
- **🔄 Dependency Updates**: Weekly automated dependency and version updates

See [`.github/README.md`](.github/README.md) for detailed information about the CI/CD setup.

### Release Process

To create a new release:

1. Update the version in [`Chart.yaml`](Chart.yaml)
2. Update [`CHANGELOG.md`](CHANGELOG.md) with changes
3. Create and push a git tag:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

The release workflow will automatically:
- Validate and test the chart
- Create a GitHub release with packaged chart
- Publish to GitHub Pages Helm repository
- Push to GitHub Container Registry (OCI)

## Uninstalling the Chart

To uninstall/delete the `fossology` deployment:

```bash
helm delete fossology
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array| `[]`  |

### Common parameters

| Name                     | Description                                        | Value           |
| ------------------------ | -------------------------------------------------- | --------------- |
| `nameOverride`           | String to partially override common.names.name    | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname    | `""`            |

For a complete list of parameters, please refer to the [values.yaml](values.yaml) file.

## Configuration and installation details

### Example configurations

The [examples](examples/) directory contains example configurations for different deployment scenarios:

- [Basic deployment](examples/basic-deployment.yaml) - Simple deployment with default settings
- [External database](examples/external-database.yaml) - Using an external PostgreSQL database
- [Production with CNPG](examples/production-cnpg.yaml) - Production setup with CloudNativePG

### Database Configuration

FOSSology requires a PostgreSQL database. You can either:

1. Use the included PostgreSQL deployment (default)
2. Use an external PostgreSQL database
3. Use CloudNativePG for production deployments

See the [examples](examples/) directory for configuration examples.

## Troubleshooting

### Common Issues

1. **Pod stuck in Pending state**: Check if PersistentVolumes are available
2. **Database connection issues**: Verify database credentials and connectivity
3. **Image pull errors**: Check image registry and pull secrets configuration

### Getting Help

- Check the [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Review the [CHANGELOG.md](CHANGELOG.md) for version history
- Visit the [FOSSology website](https://www.fossology.org/) for more information

## License

This Helm chart is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for the full license text.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| FOSSology Team | fossology@fossology.org | https://www.fossology.org/ |