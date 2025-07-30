# Renovate CE/EE Reporting APIs

Reporting APIs provide real-time data about the state of Orgs, Repos, and Pull requests that are managed by Mend Renovate.

> [!NOTE]  
> Some API data is restricted to Mend Renovate Enterprise Edition

## Available Reporting APIs

The list below describes the available reporting APIs. Follow the links on the API names for full details.

**Note**: Some API data is <u>available only in the Enterprise Edition</u>. See each API for details.

- [Org list](#org-list) ← List of orgs using Renovate
- [Org info](#org-info) ← Stats for a single org - [Some data Enterprise only]
- [Repo list](#repo-list) ← List of repos for a single org
- [Repo info](#repo-info) ← Stats for a single repo [Some data Enterprise only]
- [Repo dashboard](#repo-dashboard) ← Dependency Dashboard information [Enterprise only]
- [Repo pull requests](#repo-pull-requests) ← List of pull requests for a single repo [Enterprise only / GitHub only]
- [LibYears - System](#libyears---system) ← Libyears data for the whole system [Enterprise only]
- [LibYears - Org](#libyears---org) ← Libyears data for a single org [Enterprise only]
- [LibYears - Repo](#libyears---repo) ← Libyears data for a single repo [Enterprise only]

## Enable Reporting APIs

To enable reporting APIs, set both `MEND_RNV_API_ENABLED: true` and `MEND_RNV_API_ENABLE_REPORTING: true` (backward compatible with `MEND_RNV_REPORTING_ENABLED: true`) on the CE/EE Server container.
Reporting APIs are disabled by default.

When Reporting APIs are enabled, relevant data will be collected after every Renovate job and stored locally in the Renovate database.

The `Repo pull requests` API is available for GitHub only. To enable it, see configuration table below.

| Container | Configuration variable              | Description                                                                                                                                  |
|-----------|-------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| Worker    | `RENOVATE_REPOSITORY_CACHE`         | Set to `enabled` to enable `Repo pull requests` API                                                                                          |
| Worker    | `RENOVATE_REPOSITORY_CACHE_TYPE`    | To enable S3 repository cache, see [docs](https://docs.renovatebot.com/self-hosted-configuration/#repositorycachetype). Defaults to `local`. |
| Worker    | `RENOVATE_X_REPO_CACHE_FORCE_LOCAL` | If using S3 repository cache, set to `enabled` to enable `Repo pull request` API                                                             |
| Server    | `MEND_RNV_CRON_LIBYEARS_MV_REFRESH` | Defines the cron schedule for updating the org-level libyears data. Defaults to "20 * * * *" (every hour at 20 minutes past the hour)        |

## Reporting API URLs

See the table below for a list of reporting API URL formats.

| API                                                               | URL format                                    | Query parameters                                                                                                              |
|-----------------------------------------------------------------------------------|-----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| [Org list](#org-list)                                             | [GET] /api/v1/orgs                            | state=[active,suspended,installed(active+suspended),uninstalled,all] (default=installed) <br> limit (default=100, max=10,000) |
| [Org info](#org-info)<br/>[Some data Enterprise only]             | [GET] /api/v1/orgs/{org}                      |                                                                                                                               |
| [Repo list](#repo-list)                                           | [GET] /api/v1/orgs/{org}/-/repos              | state=[installed,uninstalled,all] (default=installed) <br> limit (default=100, max=10,000)                                    |
| [Repo info](#repo-info)<br/>[Some data Enterprise only]           | [GET] /api/v1/repos/{org}/{repo}              |                                                                                                                               |
| [Repo dashboard](#repo-dashboard)<br/>[Enterprise only]                       | [GET] /api/v1/repos/{org}/{repo}/-/dashboard  |                                                                                                                               |
| [Repo pull requests](#repo-pull-requests)<br/>[Enterprise only]<br/>[GitHub only] | [GET] /api/v1/repos/{org}/{repo}/-/pulls      | state=[open,merged,closed,all] (default=open) <br> limit (default=100, max=10,000)                                            |
| [LibYears - System](#libyears---system)<br/>[Enterprise only]                    | [GET] /api/v1/orgs/-/libyears                 | state=[installed,suspended,active] (default=installed) <br> details (default=false) <br> limit (default=100, max=10,000)      |
| [LibYears - Org](#libyears---org)<br/>[Enterprise only]                       | [GET] /api/v1/orgs/{org}/-/libyears           | details (default=false) <br> limit (default=100, max=10,000)                                                                  |
| [LibYears - Repo](#libyears---repo)<br/>[Enterprise only]                      | [GET] /api/v1/repos/{org}/{repo}/-/libyears   |                                                                                                                               |

## Details of Reporting APIs

### Org list

API: [GET] /api/v1/orgs

query parameters:
- state
  - Options = active, suspended, installed(active+suspended), uninstalled, all
  - Default = installed
- limit
  - Max = 10,000
  - Default = 100

**Description:** List of orgs using Renovate

States:
- Active = Enabled, Not Suspended
- Suspended = Enabled, Suspended
- Installed = Active or Suspended
- Uninstalled = Not Enabled

**Example 1:** Fetch a list of all currently installed orgs

[GET] http://my.renovate.server.com/api/v1/orgs

**Example 2:** Fetch a list of all installed orgs that have turned off Renovate (ie. enabled,suspended)

[GET] http://my.renovate.server.com/api/v1/orgs?state=suspended

```json
[
    {
        "id": "97cabe6b-a757-52e6-ba28-c8173b571efd",
        "name": "my-org",
        "enabled": true,
        "suspended": true,
        "installedAt": "2024-05-19 16:29:51.531136"
    },
]
```

### Org info

API: [GET] /api/v1/orgs/{org}

**Description:** Stats for a single org

Note: Summaries for `renovateStatuses` and `pullRequests` are available only with Enterprise Edition

**Example:** Fetch info and stats for org `my-org`

[GET] http://my.renovate.server.com/api/v1/orgs/my-org (Note: no trailing slash!)

```json
{
  "id": "97cabe6b-a757-52e6-ba28-c8173b571efd",
  "name": "my-org",
  "enabled": true,
  "suspended": false,
  "installationId": 42985750,
  "installedAt": "2024-03-07 11:01:04.535359",
  "repositories": {
    "installed": 2,
    "uninstalled": 2,
    "total": 4
  },
  "renovateStatuses": {    <-- Enterprise Edition only
    "activated": 1,
    "disabled": 0,
    "onboarded": 1,
    "onboarding": 0,
    "unknown": 0,
    "failed": 0,
    "resource-limit": 0,
    "timeout": 0,
    "total": 2
  },
  "pullRequests": {    <-- Enterprise Edition only
    "merged": 2,
    "open": 4,
    "ignored": 2,
    "total": 8
  }
}
```

### Repo list

API: [GET] /api/v1/orgs/{org}/-/repos

query parameters:
- state
    - Options = installed, uninstalled, all
    - Default = installed
- limit
  - Max = 10,000
  - Default = 100

**Description:** List of repos for a single org

**Example:** Fetch a list of all currently installed repos on org `my-org`

[GET] http://my.renovate.server.com/api/v1/orgs/my-org/-/repos

```json
[
  {
    "name": "demo-repo-1",
    "fullName": "my-org/demo-repo-1",
    "enabled": true,
    "installedAt": "2024-03-07 10:56:50.55661"
  },
  {
    "name": "demo-repo-2",
    "fullName": "my-org/demo-repo-2",
    "enabled": true,
    "installedAt": "2024-03-07 10:56:50.55661"
  }
]
```

**Example:** Fetch a list of all repos (installed and uninstalled)

[GET] http://my.renovate.server.com/api/v1/orgs/my-org/-/repos?state=all

```json
[
  {
    "name": "demo-repo-1",
    "fullName": "my-org/demo-repo-1",
    "enabled": true,
    "installedAt": "2024-03-07 10:56:50.55661"
  },
  {
    "name": "demo-repo-2",
    "fullName": "my-org/demo-repo-2",
    "enabled": true,
    "installedAt": "2024-03-07 10:56:50.55661"
  },
  {
    "name": "demo-repo-3",
    "fullName": "my-org/demo-repo-3",
    "enabled": false,
    "installedAt": "2024-03-07 10:56:50.55661",
    "removedAt": "2024-03-07 11:01:04.543134"
  },
  {
    "name": "demo-repo-4",
    "fullName": "my-org/demo-repo-4",
    "enabled": false,
    "installedAt": "2024-03-07 10:56:50.55661",
    "removedAt": "2024-03-07 11:01:04.543134"
  }
]
```

**Example:** Fetch a list of uninstalled repos for org `my-org`

[GET] http://my.renovate.server.com/api/v1/orgs/my-org/-/repos?state=uninstalled

```json
[
  {
    "name": "demo-repo-3",
    "fullName": "my-org/demo-repo-3",
    "enabled": false,
    "installedAt": "2024-03-07 10:56:50.55661",
    "removedAt": "2024-03-07 11:01:04.543134"
  },
  {
    "name": "demo-repo-4",
    "fullName": "my-org/demo-repo-4",
    "enabled": false,
    "installedAt": "2024-03-07 10:56:50.55661",
    "removedAt": "2024-03-07 11:01:04.543134"
  }
]
```

### Repo info

API: [GET] /api/v1/repos/{org}/{repo}

**Description:** Stats for a single repo

Note: The `status` field and `pullRequestStats` summaries are available only with Enterprise Edition

**Example:** Fetch info and stats for repo `my-org/demo-repo-2`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/demo-repo-2

```json
{
    "id": "ea26988f-7e8b-56b4-9fe3-68903d349251",
    "name": "demo-repo-2",
    "fullName": "my-org/demo-repo-2",
    "state": "installed",
    "status": "activated",    <-- Enterprise Edition only
    "installedAt": "2024-03-07 10:56:50.55661",
    "pullRequestStats": {    <-- Enterprise Edition only
        "merged": 2,
        "open": 3,
        "ignored": 2,
        "total": 7
    }
}
```

### Repo dashboard

API: [GET] /api/v1/repos/{org}/{repo}/-/dashboard

**Description:** Replicates the Dependency Dashboard Issue contents.
Includes:
- Notes/Warnings
- Detected Dependencies (‘deps’)
- Renovate Updates (‘updates’)

Note: Available only with Enterprise Edition. Returns no data when returned from Community Edition.

**Example:** Fetch all Dependency Dashboard information for repo `my-org/demo-repo-2`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/demo-repo-2/-/dashboard

```json
{
    "notes": {},
    "deps": {
        "main": {
            "nuget": [
                {
                    "deps": [
                        {
                            "depName": "Nuke.Common",
                            "depType": "nuget",
                            "updates": [
                                {
                                    "bucket": "non-major",
                                    "newMajor": 5,
                                    "newMinor": 3,
                                    "newValue": "5.3.0",
                                    "branchName": "renovate/nuke.common-5.x",
                                    "newVersion": "5.3.0",
                                    "updateType": "minor",
                                    "releaseTimestamp": "2021-08-04T06:49:23.533Z"
                                },
                                {
                                    "bucket": "major",
                                    "newMajor": 8,
                                    "newMinor": 0,
                                    "newValue": "8.0.0",
                                    "branchName": "renovate/nuke.common-8.x",
                                    "newVersion": "8.0.0",
                                    "updateType": "major",
                                    "releaseTimestamp": "2024-01-18T23:16:15.010Z"
                                }
                            ],
                            "homepage": "https://nuke.build/",
                            "sourceUrl": "https://github.com/nuke-build/nuke",
                            "datasource": "nuget",
                            "versioning": "nuget",
                            "packageName": "Nuke.Common",
                            "registryUrl": "https://api.nuget.org/v3/index.json",
                            "currentValue": "5.1.0",
                            "fixedVersion": "5.1.0",
                            "isSingleVersion": true
                        },
                        {
                            "depName": "Microsoft.Playwright",
                            "depType": "nuget",
                            "updates": [
                                {
                                    "bucket": "non-major",
                                    "newMajor": 1,
                                    "newMinor": 42,
                                    "newValue": "1.42.0",
                                    "branchName": "renovate/playwright-dotnet-monorepo",
                                    "newVersion": "1.42.0",
                                    "updateType": "minor",
                                    "releaseTimestamp": "2024-03-07T16:37:54.833Z"
                                }
                            ],
                            "sourceUrl": "https://github.com/microsoft/playwright-dotnet",
                            "datasource": "nuget",
                            "versioning": "nuget",
                            "packageName": "Microsoft.Playwright",
                            "registryUrl": "https://api.nuget.org/v3/index.json",
                            "currentValue": "1.41.2",
                            "fixedVersion": "1.41.2",
                            "isSingleVersion": true
                        },
                        {
                            "depName": "Microsoft.JSInterop",
                            "depType": "nuget",
                            "updates": [
                                {
                                    "bucket": "non-major",
                                    "newMajor": 5,
                                    "newMinor": 0,
                                    "newValue": "5.0.17",
                                    "branchName": "renovate/dotnet-monorepo",
                                    "newVersion": "5.0.17",
                                    "updateType": "patch",
                                    "releaseTimestamp": "2022-05-10T14:17:43.033Z"
                                },
                                {
                                    "bucket": "major",
                                    "newMajor": 8,
                                    "newMinor": 0,
                                    "newValue": "8.0.2",
                                    "branchName": "renovate/major-dotnet-monorepo",
                                    "newVersion": "8.0.2",
                                    "updateType": "major",
                                    "releaseTimestamp": "2024-02-13T14:23:38.200Z"
                                }
                            ],
                            "homepage": "https://asp.net/",
                            "sourceUrl": "https://github.com/dotnet/aspnetcore",
                            "datasource": "nuget",
                            "versioning": "nuget",
                            "packageName": "Microsoft.JSInterop",
                            "registryUrl": "https://api.nuget.org/v3/index.json",
                            "currentValue": "5.0.8",
                            "fixedVersion": "5.0.8",
                            "isSingleVersion": true
                        }
                    ],
                    "packageFile": "dotnet.csproj"
                }
            ]
        }
    },
    "updates": {
        "open": [
            {
                "prNo": 2,
                "result": "done",
                "prTitle": "Update dependency Microsoft.JSInterop to v5.0.17",
                "upgrades": [
                    {
                        "depName": "Microsoft.JSInterop",
                        "newValue": "5.0.17",
                        "datasource": "nuget",
                        "newVersion": "5.0.17",
                        "updateType": "patch",
                        "packageFile": "dotnet.csproj",
                        "packageName": "Microsoft.JSInterop",
                        "currentValue": "5.0.8",
                        "fixedVersion": "5.0.8",
                        "currentVersion": "5.0.8",
                        "displayPending": ""
                    }
                ],
                "branchName": "renovate/dotnet-monorepo"
            },
            {
                "prNo": 9,
                "result": "done",
                "prTitle": "Update dependency Microsoft.Playwright to v1.42.0",
                "upgrades": [
                    {
                        "depName": "Microsoft.Playwright",
                        "newValue": "1.42.0",
                        "datasource": "nuget",
                        "newVersion": "1.42.0",
                        "updateType": "minor",
                        "packageFile": "dotnet.csproj",
                        "packageName": "Microsoft.Playwright",
                        "currentValue": "1.41.2",
                        "fixedVersion": "1.41.2",
                        "currentVersion": "1.41.2",
                        "displayPending": ""
                    }
                ],
                "branchName": "renovate/playwright-dotnet-monorepo"
            },
            {
                "prNo": 8,
                "result": "done",
                "prTitle": "Update dependency Nuke.Common to v5.3.0",
                "upgrades": [
                    {
                        "depName": "Nuke.Common",
                        "newValue": "5.3.0",
                        "datasource": "nuget",
                        "newVersion": "5.3.0",
                        "updateType": "minor",
                        "packageFile": "dotnet.csproj",
                        "packageName": "Nuke.Common",
                        "currentValue": "5.1.0",
                        "fixedVersion": "5.1.0",
                        "currentVersion": "5.1.0",
                        "displayPending": ""
                    }
                ],
                "branchName": "renovate/nuke.common-5.x"
            }
        ],
        "ignoredOrBlocked": [
            {
                "prNo": null,
                "result": "already-existed",
                "prTitle": "Update dependency Microsoft.JSInterop to v8",
                "upgrades": [
                    {
                        "depName": "Microsoft.JSInterop",
                        "newValue": "8.0.2",
                        "datasource": "nuget",
                        "newVersion": "8.0.2",
                        "updateType": "major",
                        "packageFile": "dotnet.csproj",
                        "packageName": "Microsoft.JSInterop",
                        "currentValue": "5.0.8",
                        "fixedVersion": "5.0.8",
                        "currentVersion": "5.0.8",
                        "displayPending": ""
                    }
                ],
                "branchName": "renovate/major-dotnet-monorepo"
            },
            {
                "prNo": null,
                "result": "already-existed",
                "prTitle": "Update dependency Nuke.Common to v8",
                "upgrades": [
                    {
                        "depName": "Nuke.Common",
                        "newValue": "8.0.0",
                        "datasource": "nuget",
                        "newVersion": "8.0.0",
                        "updateType": "major",
                        "packageFile": "dotnet.csproj",
                        "packageName": "Nuke.Common",
                        "currentValue": "5.1.0",
                        "fixedVersion": "5.1.0",
                        "currentVersion": "5.1.0",
                        "displayPending": ""
                    }
                ],
                "branchName": "renovate/nuke.common-8.x"
            }
        ]
    }
}
```

### Repo pull requests

> [!IMPORTANT]  
> 1. The `Repo pull request` API only works with GitHub repositories.
> 2. Requires `RENOVATE_REPOSITORY_CACHE=enabled` set on Worker containers.
> 3. If using S3 repo cache, the `RENOVATE_X_REPO_CACHE_FORCE_LOCAL` must be set on Worker containers.

API: [GET] /api/v1/repos/{org}/{repo}/-/pulls

Note: Available only with Enterprise Edition. Returns no data when returned from Community Edition.

query parameters:
- state
  - Options = open, merged, closed, all
  - Default = open
- limit
  - Max = 10,000
  - Default = 100

Pagination is not supported. Results are sorted with most recently updated first.

**Description:** List of pull requests for a single repo
- Defaults to `open` pull requests only with limit of `100`.
- Results are sorted descending by PR update date.

**Example:** Fetch a list of all open pull requests created by Renovate on repo `my-org/demo-repo-2`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/demo-repo-2/-/pulls

```json
[
    {
        "repoId": "ea26988f-7e8b-56b4-9fe3-68903d349251",
        "prNumber": 9,
        "prTitle": "Update dependency Microsoft.Playwright to v1.42.0",
        "branchName": "renovate/playwright-dotnet-monorepo",
        "prCreatedAt": "2024-03-07 16:53:21",
        "createdAt": "2024-03-07 16:53:23.925878",
        "updatedAt": "2024-03-07 16:53:23.925878",
        "state": "open",
        "link": "https://github.com/my-org/demo-repo-2/pull/9"
    },
    {
        "repoId": "ea26988f-7e8b-56b4-9fe3-68903d349251",
        "prNumber": 8,
        "prTitle": "Update dependency Nuke.Common to v5.3.0",
        "branchName": "renovate/nuke.common-5.x",
        "prCreatedAt": "2024-03-05 15:55:40",
        "createdAt": "2024-03-07 11:02:19.496966",
        "updatedAt": "2024-03-07 11:02:19.496966",
        "state": "open",
        "link": "https://github.com/my-org/demo-repo-2/pull/8"
    },
    {
        "repoId": "ea26988f-7e8b-56b4-9fe3-68903d349251",
        "prNumber": 2,
        "prTitle": "Update dependency Microsoft.JSInterop to v5.0.17",
        "branchName": "renovate/dotnet-monorepo",
        "prCreatedAt": "2024-03-05 14:49:54",
        "createdAt": "2024-03-07 11:02:19.496966",
        "updatedAt": "2024-03-07 11:02:19.496966",
        "state": "open",
        "link": "https://github.com/my-org/demo-repo-2/pull/2"
    }
]
```

### LibYears - System

API: [GET] /api/v1/orgs/-/libyears

**Description:** Returns system-wide libyears statistics across all organizations

Optional query parameters:

- state ("installed" | "suspended" | "active")
  - Filters the results based on the state of the organizations
  - Default: "installed"

- details (boolean)
  - When true, includes individual org level libyears
  - Default: false

- limit (integer)
  - Limits the number of orgs returned in details
  - Max = 10,000
  - Default = 100

**Example:** Fetch libyears data for all orgs in the system and include details for each org.

[GET] http://my.renovate.server.com/api/v1/orgs/-/libyears?details=true

```json
{
    "id": "389943",
    "name": "myrenovateapp",
    "type": "system",
    "libYears": {
        "managers": {
            "npm": 61.8861429979274,
            "nuget": 8.04675623100584
        },
        "total": 69.93289922893324
    },
    "dependencyStatus": {
        "outdated": 34,
        "total": 39
    },
    "updatedAt": "2025-05-26 15:10:42",
    "details": [
        {
            "id": "97cabe6b-a757-52e6-ba28-c8173b571efd",
            "name": "my-org-1",
            "type": "org",
            "suspended": false,
            "updatedAt": "2025-05-26 15:10:42",
            "libYears": {
                "managers": {
                    "npm": 61.8861429979274,
                    "nuget": 8.04675623100584
                },
                "total": 69.93289922893318
            },
            "dependencyStatus": {
                "outdated": 34,
                "total": 39
            }
        }
    ]
}
```

### LibYears - Org

API: [GET] /api/v1/orgs/{org}/-/libyears

**Description:** Returns libyears for a specific organization

Path parameters:

- :org:
  - The organization identifier. Supports nested org paths (e.g., org/sub-org).

Optional query parameters:

- details (boolean)
  - When true, includes per repository libyears data within the organization
  - Default: false

- limit (integer)
  - Limits the number of repositories returned in details
  - Max = 10,000
  - Default = 100

**Example:** Fetch libyears data for my-org-1 and include details for each repository.

[GET] http://my.renovate.server.com/api/v1/orgs/my-org-1/-/libyears?details=true

```json
{
  "id": "97cabe6b-a757-52e6-ba28-c8173b571efd",
  "name": "my-org-1",
  "type": "org",
  "suspended": false,
  "updatedAt": "2025-05-26 15:10:42",
  "libYears": {
    "managers": {
      "npm": 61.8861429979274,
      "nuget": 8.04675623100584
    },
    "total": 69.93289922893318
  },
  "dependencyStatus": {
    "outdated": 34,
    "total": 39
  },
  "details": [
    {
      "id": "a71578dc-87de-5caf-84cb-b7f67907d85e",
      "type": "repo",
      "name": "my-org-1/my-repo-1",
      "installed": true,
      "libYears": {
        "total": 61.88614299792735,
        "managers": {
          "npm": 61.88614299792735
        }
      },
      "dependencyStatus": {
        "outdated": 31,
        "total": 36
      },
      "updatedAt": "2025-05-26 15:10:13"
    },
    {
      "id": "ea26988f-7e8b-56b4-9fe3-68903d349251",
      "type": "repo",
      "name": "my-org-1/my-repo-2",
      "installed": true,
      "libYears": {
        "total": 8.046756231005835,
        "managers": {
          "nuget": 8.046756231005835
        }
      },
      "dependencyStatus": {
        "outdated": 3,
        "total": 3
      },
      "updatedAt": "2025-05-26 15:10:42"
    }
  ]
}
```

### LibYears - Repo

API: [GET] /api/v1/repos/{org}/{repo}/-/libyears

**Description:** Returns libyears statistics for a specific repository

Path parameters:

- :org/repo:
  - The full repository path in the form org/repo. Supports nested paths (e.g., org/sub/repo).

**Example:** Fetch libyears data for repository "my-repo-1" in org "my-org-1"

[GET] http://my.renovate.server.com/api/v1/repos/my-org-1/my-repo-1/-/libyears

```json
{
  "id": "ea26988f-7e8b-56b4-9fe3-68903d349251",
  "type": "repo",
  "name": "my-org-1/my-repo-1",
  "installed": true,
  "libYears": {
    "total": 8.046756231005835,
    "managers": {
      "nuget": 8.046756231005835
    }
  },
  "dependencyStatus": {
    "outdated": 3,
    "total": 3
  },
  "updatedAt": "2025-05-26 15:10:42"
}
```
