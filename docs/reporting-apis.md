# Renovate EE Reporting APIs

Reporting APIs provide real-time data about the state of Orgs, Repos, and Pull requests that are managed by Mend Renovate.
These APIs are available only on Mend Renovate Enterprise Edition instances running with a Postgres DB.

**Version**: This documentation reflects APIs available in Mend Renovate Enterprise v7.0.0

> [!IMPORTANT]  
> Reporting APIs are only supported for the following configuration:
> - Mend Renovate Enterprise Edition
> - Using PostgresDB for Renovate database

## Available Reporting APIs

The list below describes the available reporting APIs. Follow the links on the API names for full details.

- [Org info](#org-info) ← Stats for a single org
- [Repo list](#repo-list) ← List of repos for a single org
- [Repo info](#repo-info) ← Stats for a single repo
- [Repo dashboard](#repo-dashboard) ← Dependency Dashboard information
- [Repo pull requests](#repo-pull-requests) [GitHub only] ← List of pull requests for a single repo

## Enable Reporting APIs

Reporting APIs are disabled by default. When Reporting APIs are enabled, relevant data will be collected after every Renovate job and stored locally in the Renovate database.

To enable reporting APIs:
* Set `MEND_RNV_REPORTING_ENABLED=true` on the Renovate EE Server containers.

> [!IMPORTANT]  
> Data will not be available for the `Repo pull requests` API unless Renovate is run with Repository Cache enabled.

To enable data collection for the `Repo pull requests` API:
* Set `RENOVATE_REPOSITORY_CACHE=enabled` on the Renovate EE Worker containers.

> [!NOTE]  
> The `Repo pull request` API only works with GitHub repositories.

## Reporting API URLs

See the table below for a list of reporting API URL formats.

| API                                       | URL format                                | Query parameters                                                                   |
|-------------------------------------------|-------------------------------------------|------------------------------------------------------------------------------------|
| [Org info](#org-info)                     | [GET] /api/orgs/{org}                     |                                                                                    |
| [Repo list](#repo-list)                   | [GET] /api/orgs/{org}/-/repos             | state=[installed,uninstalled,all] (default=installed)                              |
| [Repo info](#repo-info)                   | [GET] /api/repos/{org}/{repo}           |                                                                                    |
| [Repo dashboard](#repo-dashboard)         | [GET] /api/repos/{org}/{repo}/-/dashboard |                                                                                    |
| [Repo pull requests](#repo-pull-requests) | [GET] /api/repos/{org}/{repo}/-/pulls     | state=[open,merged,closed,all] (default=open) <br> limit (default=100, max=10,000) |

## Details of Reporting APIs

### Org info

API: [GET] /api/orgs/{org}

**Description:** Stats for a single org

**Example:** Fetch info and stats for org `my-org`

[GET] http://my.renovate.server.com/api/orgs/my-org   (Note: no trailing slash!)

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
  "renovateStatuses": {
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
  "pullRequests": {
    "merged": 2,
    "open": 4,
    "ignored": 2,
    "total": 8
  }
}
```

### Repo list

API: [GET] /api/orgs/{org}/-/repos

query parameters:
- state
    - Options = installed, uninstalled, all
    - Default = installed

**Description:** List of repos for a single org

**Example:** Fetch a list of all currently installed repos on org `my-org`

[GET] http://my.renovate.server.com/api/orgs/my-org/-/repos

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

[GET] http://my.renovate.server.com/api/orgs/my-org/-/repos?state=all

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

[GET] http://my.renovate.server.com/api/orgs/my-org/-/repos?state=uninstalled

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

API: [GET] /api/repos/{org}/{repo}

**Description:** Stats for a single repo

**Example:** Fetch info and stats for repo `my-org/demo-repo-2`

[GET] http://my.renovate.server.com/api/repos/my-org/demo-repo-2

```json
{
    "id": "ea26988f-7e8b-56b4-9fe3-68903d349251",
    "name": "demo-repo-2",
    "fullName": "my-org/demo-repo-2",
    "state": "installed",
    "status": "activated",
    "installedAt": "2024-03-07 10:56:50.55661",
    "pullRequestStats": {
        "merged": 2,
        "open": 3,
        "ignored": 2,
        "total": 7
    }
}
```

### Repo dashboard

API: [GET] /api/repos/{org}/{repo}/-/dashboard

**Description:** Replicates the Dependency Dashboard Issue contents.
Includes:
- Notes/Warnings
- Detected Dependencies (‘deps’)
- Renovate Updates (‘updates’)

**Example:** Fetch all Dependency Dashboard information for repo `my-org/demo-repo-2`

[GET] http://my.renovate.server.com/api/repos/my-org/demo-repo-2/-/dashboard

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
> 1. This API is available for GitHub repositories only.
> 2. Requires `RENOVATE_REPOSITORY_CACHE=enabled` set on Worker containers.

API: [GET] /api/repos/{org}/{repo}/-/pulls

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

[GET] http://my.renovate.server.com/api/repos/my-org/demo-repo-2/-/pulls

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