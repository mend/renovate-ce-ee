# Mend Renovate Self-hosted App Documentation

This repository provides documentation specific to the Mend Renovate Self-hosted Apps - Community Edition (Renovate CE) and Enterprise Edition (Renovate EE), and does not duplicate anything that is relevant and can be found in the [Renovate OSS repository](https://github.com/renovatebot/renovate).

Mend Renovate Community Edition was formerly known as "Mend Renovate On-Premises".

## Supported platforms

The following platforms are supported by Mend Renovate Community Edition and Enterprise Edition:
- GitHub.com
- GitHub Enterprise Server
- GitLab Cloud
- GitLab Enterprise Edition
- Bitbucket Data Center (in beta)

## Documentation contents

1. [Overview](./overview.md)
2. Installation ([Helm](./installation-helm.md))
3. Getting Started
   - [Setup guide for GitHub](setup-for-github.md)
   - [Setup guide for GitLab](setup-for-gitlab.md)
   - [Setup guide for Bitbucket Data Center](setup-for-bitbucket-data-center.md)
4. Configuration
   - [Self-hosted App configuration options](configuration-options.md)
   - [Example Renovate CE Docker Compose](../examples/docker-compose/docker-compose-renovate-community.yml)
   - [Example Renovate EE Docker Compose](../examples/docker-compose/docker-compose-renovate-enterprise.yml)
   - [Configure PostgreSQL DB](configure-postgres-db.md)
   - [Configure TLS Communication](./tls.md)
5. Migration ([Renovate On-Premises to Renovate Community](./migrating-to-renovate-ce.md))
6. API Documentation
   - [Admin APIs](./api.md)
   - [Job Logs APIs](./job-logs-apis.md)
   - [Reporting APIs](./reporting-apis.md)
7. [Advanced topics](./advanced.md)
