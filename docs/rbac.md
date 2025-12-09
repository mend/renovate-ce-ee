# Role Based Access Control (RBAC)

Role Based Access Control (RBAC) allows API access using the underlying Platform's authentication and authorization, instead of the shared "admin token".

Contrary to the use of the `MEND_RNV_API_SERVER_SECRET`, which provides a single "superuser" authentication token that many users share, the use of RBAC allows for per-user authentication, which will then base the permissions available to the user based on their level of access on the given repositories.

For example, when enabled, this would allow a user to send a GitHub Personal Access Token (fine-grained or classic) to the API, instead of the shared admin token. Mend Renovate Self-Hosted will take that token, confirm the permissions the user has, and restrict access based on those permissions. See the per-platform permissions matrices below for more information.

## How to enable

To enable RBAC on your Mend Renovate Self-Hosted deployment, you will need to specify `env MEND_RNV_SERVER_RBAC_ENABLED=true`, or `mendRnvServerRbacEnabled` in the Helm chart.

The RBAC functionality is available for both Community Edition and Enterprise Edition. See the platform support below.

### Supported platforms

- GitHub (`env MEND_RNV_PLATFORM=github`, since Community Edition 11.0.0 and Enterprise Edition 5.0.0)
- Bitbucket Data Center (`env MEND_RNV_PLATFORM=bitbucket-server`, since Community Edition 12.0.0 and Enterprise Edition 6.0.0)

## Caching

By default, once a user's permissions are looked up, they are cached for 60 minutes (1 hour).

You can configure this using `MEND_RNV_CACHE_TTL_OVERRIDES_MAP`.

For instance, to configure the RBAC data be cached for a maximum of 5 minutes:

```sh
export MEND_RNV_CACHE_TTL_OVERRIDES_MAP=rbac=5m
```

## Supported APIs

Only the following APIs support authenticating with RBAC tokens:

- API
- Reporting APIs
- Jobs API (under the `/api` prefix)

## GitHub

When running against GitHub (Cloud or Enterprise Server), Mend Renovate Self-Hosted requires a Personal Access Token (Fine-Grained or Classic) to authenticate.

Mend recommends using a Fine-Grained personal access token where possible, due to the enhanced security benefits, and extra organization control.

The RBAC API requires a very low privileged personal access tokens by design - it only needs to confirm that the user is a member of the organization, and read metadata about repositories to confirm the user's access rights.
The GitHub token used does not require write access to the repository, or access to its contents. However, the user themselves must have access to the repository if attempting to use an API that requires `repo:write`.

### Personal Access Tokens (Fine-Grained)

> [!NOTE]
> Fine-grained personal access tokens can only be created for a single Resource Owner at a time.
>
> If you need access to multiple organizations, you will need one fine-grained personal access token per organization.
>
> If you're calling APIs that require access to multiple organizations (such as the "System Libyears" API), using a Classic personal access token may be preferred, to avoid multiple API calls with different tokens.
>
> If you are an [Outside Collaborator](https://docs.github.com/en/organizations/managing-user-access-to-your-organizations-repositories/managing-outside-collaborators/adding-outside-collaborators-to-repositories-in-your-organization) on a repository, it is [not currently possible](https://github.com/github/roadmap/issues/601) to create a fine-grained personal access token for access to a repository. Until this is supported, we recommend using a Classic personal access token.

Fine-grained personal access tokens are bound to a "Resource Owner", which is either a User or an Organization.

When [creating a new Fine-grained personal access token](https://github.com/settings/personal-access-tokens/new), you will need to:

- Specify the organization or user you wish to access with this token as the "Resource Owner"
- Specify access to `All repositories` or `Only select repositories`
  - This can also be "Only select repositories" for a subset of Private/Internal repositories that you would like to interact with
  - Public repositories are always included
- Specify the Organization permissions:
  - `Members`: `Read-only`
- Specify the Repository permissions:
  - `Metadata`: `Read-only`

No other permissions are required, and the token used does not require access to the repo's contents.

### Personal Access Tokens (Classic)

> [!WARNING]
> It is strongly recommended you use a fine-grained personal access token, as it can be more finely scoped to the level of access required.
>
> Using a Classic personal access token is **not** minimal in its access, and due to its coarse grained permissions model, the token used will have write access implied, even if Mend Renovate Self-Hosted does not use it.

When [creating a new Classic personal access token](https://github.com/settings/tokens/new?scopes=repo,read:org), you will need to specify the following scopes:

- `repo` scope
- `read:org` scope

### Other token types

It might be possible to use other token types (such as OAuth App tokens) but these are not tested and therefore unsupported.

### Permissions matrix

Given a user's level of access to the repository and the organization, we take the **highest** possible permission as the access level for the operation.

| Resource   | SCM Access Level          | Mend Renovate RBAC access level |
| ---------- | ------------------------- | ------------------------------- |
| Repository | (no access)               | `none`                          |
| Repository | `pull` (AKA read-only)    | `repo:read`                     |
| Repository | `triage`                  | `repo:read`                     |
| Repository | `push` (AKA write access) | `repo:write`                    |
| Repository | `maintain`                | `repo:write`                    |
| Repository | `admin`                   | `repo:write`                    |

Note: We determine repository permissions using [the "Get repository permissions for a user" API](https://docs.github.com/en/rest/collaborators/collaborators?apiVersion=2022-11-28#get-repository-permissions-for-a-user).

| Resource     | Membership role                                                  | Mend Renovate RBAC access level |
| ------------ | ---------------------------------------------------------------- | ------------------------------- |
| Organization | `none` (AKA not a member, or an outside collaborator on repo(s)) | `none`                          |
| Organization | `member`                                                         | `org:read`                      |
| Organization | `billing_manager`                                                | `org:read`                      |
| Organization | `admin` (AKA an Organization Owner)                              | `org:write`                     |

Note: We determine organization permissions using [the "List organization memberships for the authenticated user" API](https://docs.github.com/en/rest/orgs/members?apiVersion=2022-11-28#list-organization-memberships-for-the-authenticated-user).

## Bitbucket Data Center

When running against Bitbucket Data Center, Mend Renovate Self-Hosted requires an HTTP Token to authenticate.

When creating the HTTP Token, you will need to specify the following permissions:

- Project permissions: `Project read`
- Repository permissions: `Repository Write`

Unlike GitHub's RBAC functionality, the token generated for Bitbucket Data Center must have write access to a repository, if you wish to interact with APIs that require `repo:write`.

### Permissions matrix

Given a user's level of access to the repository and the project, we take the **highest** possible permission as the access level for the operation.

| Resource   | SCM Access Level | Mend Renovate RBAC access level |
| ---------- | ---------------- | ------------------------------- |
| Repository | (none)           | `none`                          |
| Repository | `REPO_READ`      | `repo:read`                     |
| Repository | `REPO_WRITE`     | `repo:write`                    |
| Repository | `REPO_ADMIN`     | `repo:write`                    |

| Resource | SCM Access Level          | Mend Renovate RBAC access level |
| -------- | ------------------------- | ------------------------------- |
| Project  | `none` (AKA not a member) | `none`                          |
| Project  | `PROJECT_READ`            | `org:read`                      |
| Project  | `PROJECT_WRITE`           | `org:write`                     |
| Project  | `PROJECT_ADMIN`           | `org:write`                     |

Note: we determine the permissions using the [Search for repositories API](https://developer.atlassian.com/server/bitbucket/rest/v1000/api-group-repository/#api-api-latest-repos-get) and [Search for projects](https://developer.atlassian.com/server/bitbucket/rest/v1000/api-group-project/#api-api-latest-projects-get) APIs.
