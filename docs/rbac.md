# Role Based Access Control (RBAC)

Role Based Access Control (RBAC) allows API access to be performed using the underlying Source Code Management (SCM) platform's authentication and authorization.

Contrary to the use of the `MEND_RNV_API_SERVER_SECRET`, which provides a single "superuser" authentication token that must be shared between many users, this allows for per-user authentication, which can then be scoped to the individual's level of access on the given repositories.

For example, when enabled, this would allow a user to send a GitHub Personal Access Token (fine-grained or classic) to the API. Mend Renovate Self-Hosted will take that token, confirm the permissions the user has, and restrict access based on those permissions. See [the permissions matrix below](#permissions-matrix) for more information.

## How to enable

To enable RBAC on your Mend Renovate Self-Hosted deployment, you will need to specify `env MEND_RNV_SERVER_RBAC_ENABLED=true`, or `mendRnvServerRbacEnabled` in the Helm chart.

### Supported platforms

- GitHub (`env MEND_RNV_PLATFORM=github`)
- Bitbucket Server (`env MEND_RNV_PLATFORM=bitbucket-server`)

## Caching

By default, once a user's permissions are looked up, they are cached for 60 minutes (1 hour).

## Supported APIs

Only the following APIs are supported:

- API
- Reporting APIs
- Jobs API (subset of APIs)

## Permissions Matrix

