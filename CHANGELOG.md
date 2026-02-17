# Changelog

All notable changes to this Helm chart will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-02-17

### Added
- Initial release of the FOSSology Helm chart
- Support for FOSSology 4.4.0
- CloudNativePG (CNPG) integration for high-availability PostgreSQL
- Embedded PostgreSQL option for development/testing
- External database support
- Comprehensive configuration options
- Image pull secrets support
- Ingress configuration with TLS support
- Persistent volume support
- Resource management and scaling options
- Node affinity and tolerations
- Monitoring and observability features
- Comprehensive documentation and examples
- Apache 2.0 license

### Features
- **Database Options**:
  - Embedded PostgreSQL for development
  - CloudNativePG for production high availability
  - External database connectivity
  - Automated backup configuration (with CNPG)

- **Security**:
  - Image pull secrets management
  - External secrets integration
  - TLS/SSL support for ingress

- **Scalability**:
  - Horizontal pod autoscaling ready
  - Multi-replica deployments
  - Anti-affinity rules for high availability

- **Operations**:
  - Comprehensive health checks
  - Resource limits and requests
  - Storage management
  - Monitoring integration

### Documentation
- Complete README with installation guides
- Configuration parameter documentation
- Deployment scenario examples
- Troubleshooting guide
- Migration instructions
- Contributing guidelines

### Examples
- Basic deployment configuration
- Production setup with CNPG
- External database configuration
- Security-focused setup
- High availability configuration

## [Unreleased]

### Planned
- Helm chart repository publication
- Additional monitoring integrations
- Backup automation improvements
- Performance optimization guides
- Multi-architecture support documentation