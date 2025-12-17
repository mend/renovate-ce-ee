# Role Based Access Control (RBAC)

Role Based Access Control (RBAC) allows API access using the underlying Source Code Management (SCM) platform's authentication and authorization, instead of the shared "admin token".

Contrary to the use of the `MEND_RNV_API_SERVER_SECRET`, which provides a single "superuser" authentication token that must be shared between many users, this allows for per-user authentication, which can then be scoped to the individual's level of access on the given repositories.

For example, when enabled, this would allow a user to send a GitHub Personal Access Token (fine-grained or classic) to the API. Mend Renovate Self-Hosted will take that token, confirm the permissions the user has, and restrict access based on those permissions. See the per-platform permissions matrices below for more information.

## How to enable

To enable RBAC on your Mend Renovate Self-Hosted deployment, you will need to specify `env MEND_RNV_SERVER_RBAC_ENABLED=true`, or `mendRnvServerRbacEnabled` in the Helm chart.

### Supported platforms

- GitHub (`env MEND_RNV_PLATFORM=github`)
- Bitbucket Server (`env MEND_RNV_PLATFORM=bitbucket-server`)

## Caching

By default, once a user's permissions are looked up, they are cached for 60 minutes (1 hour).

## Supported APIs

Only the following APIs support authenticating with RBAC tokens:

- API
- Reporting APIs
- Jobs API (subset of APIs)

## GitHub

When running on GitHub (Cloud or Server), **??**


### Personal Access Tokens (Fine-Grained)

**??**

### Personal Access Tokens (Classic)

> [!WARNING]
> It is recommended you use a **??**, as it can be more finely scoped **??**.
>
> However, if you're working across multiple organisations, you would **??**

**??**

### Other token types

It is not posible **??**

### Permissions matrix

Given a user's level of access to the repository and the organisation, we take the **highest** possible permission as **??**.

|  Resource | SCM Access Level | Mend Renovate RBAC access level |
|  -- | -- | - |
| Repository | `none` | `none` |
|  Repository | `pull` (AKA read-only) | `repo:read` |
|  Repository | `triage` | `repo:read` |
|  Repository | `push` (AKA write access) | `repo:write` |
|  Repository | `maintain` | `repo:write` |
|  Repository | `admin` | `repo:write` |

Note: We determine repository permissions using [the "Get repository permissions for a user" API](https://docs.github.com/en/rest/collaborators/collaborators?apiVersion=2022-11-28#get-repository-permissions-for-a-user).

|  Resource | Membership role | Mend Renovate RBAC access level |
|  -- | -- | - |
| Organization | `none` (AKA not a member) | `none` |
| Organization | `member` | `org:read` |
| Organization | `billing_manager` | `org:read` |
|Organization  | `admin` (AKA an Organization Owner  | `org:write` |

Note: We determine organization permissions using [the "List organization memberships for the authenticated user" API](https://docs.github.com/en/rest/orgs/members?apiVersion=2022-11-28#list-organization-memberships-for-the-authenticated-user).

## Bitbucket Server

### **??**

### Permissions matrix

|  Resource | SCM Access Level | Mend access level |
|  -- | -- | - |
| Repository | `REPO_READ`  | `read` |
| Repository | `REPO_WRITE` | `write` |
| Repository | `REPO_ADMIN` | `write` |


**??**Note: We determine repository permissions using **??** https://developer.atlassian.com/server/bitbucket/rest/v1000/api-group-repository/#api-api-latest-repos-get
