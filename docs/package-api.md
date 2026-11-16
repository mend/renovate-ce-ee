<!-- omit in toc -->
# Package APIs

Use the package APIs to find dependencies across repositories, inspect the updates
Renovate has detected, and trigger jobs for repositories using a package.
This guide follows that workflow. For authentication, parameters, and status codes,
see [API Documentation](./api.md) and the [Enterprise OpenAPI specification](./openapi-enterprise.yaml).

> [!IMPORTANT]
> Package APIs are available as an opt-in beta in Renovate Enterprise Edition and are subject to change.

<!-- omit in toc -->
## Contents

- [Enable package APIs](#enable-package-apis)
- [Find a package](#find-a-package)
- [Inspect usages and updates](#inspect-usages-and-updates)
  - [Pagination](#pagination)
- [Inspect one repository](#inspect-one-repository)
- [Trigger matching repositories](#trigger-matching-repositories)
- [Related documentation](#related-documentation)

## Enable package APIs

Enable these settings on the server:

```sh
MEND_RNV_API_ENABLED=true
MEND_RNV_API_ENABLE_REPORTING=true
MEND_RNV_API_BETA_PACKAGES_ENABLED=true
MEND_RNV_API_ENABLE_SYSTEM=true # Required for system-wide queries and job triggers
```

Package data is collected after each Renovate job when reporting is enabled. Results include only enabled repositories in enabled organizations.

## Find a package

Search for package names containing `go` across organizations. `packageNameContains` is a case-insensitive substring filter. `searchPackages` returns distinct package/registry pairs across datasources; use `searchUsages` to find where a selected package is used.

```sh
export MEND_RNV_SERVER_HOSTNAME='https://<SERVER_HOST>'
export MEND_RNV_API_SERVER_SECRET='<SERVER_API_SECRET>'

export GRAPHQL_REQUEST="$(jq -n --arg query '
query Packages($nameContains: String) {
  searchPackages(packageNameContains: $nameContains, first: 50) {
    nodes {
      datasource
      packageName
      registryUrl
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
' '{
  "query": $query,
  "variables": {
    "nameContains": "go"
  }
}')"

curl -sS "$MEND_RNV_SERVER_HOSTNAME/system/v1beta1/packages/graphql" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H 'Content-Type: application/json' \
  --data-binary "$GRAPHQL_REQUEST" | jq .
```

Response (`200`):

```json
{
  "data": {
    "searchPackages": {
      "nodes": [
        {
          "datasource": "golang-version",
          "packageName": "go",
          "registryUrl": "https://raw.githubusercontent.com/golang/website"
        },
        {
          "datasource": "go",
          "packageName": "golang.org/x/text",
          "registryUrl": "__unknown__"
        },
        {
          "datasource": "npm",
          "packageName": "got",
          "registryUrl": "https://registry.npmjs.org"
        }
      ],
      "pageInfo": {
        "hasNextPage": false,
        "endCursor": "<CURSOR>"
      }
    }
  }
}
```

Check the response for GraphQL `errors`, even when the HTTP status is `200`.

The [system and organization GraphQL schema](./graphql/packages.graphql)
describes all available fields and filters. Use the organization endpoint to
search within one organization. To search within a repository, use `searchUsages`
on the repository endpoint; see [Inspect one repository](#inspect-one-repository).

## Inspect usages and updates

Find usages of the npm package `lodash` in an organization, including package file paths and detected updates.

```sh
export GRAPHQL_REQUEST="$(jq -n --arg query '
query Usages($datasource: String, $packageName: String, $after: String) {
  searchUsages(
    datasource: $datasource
    packageName: $packageName
    first: 50
    after: $after
  ) {
    nodes {
      repository {
        fullName
      }
      depName
      packageFilePath
      currentValue
      updateTargets {
        updateType
        toValue
        updateState {
          branchName
          state
        }
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
' '{
  "query": $query,
  "variables": {
    "datasource": "npm",
    "packageName": "lodash",
    "after": null
  }
}')"

curl -sS "$MEND_RNV_SERVER_HOSTNAME/api/v1beta1/orgs/<ORG>/-/packages/graphql" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H 'Content-Type: application/json' \
  --data-binary "$GRAPHQL_REQUEST" | jq .
```

Response (`200`):

```json
{
  "data": {
    "searchUsages": {
      "nodes": [
        {
          "repository": {
            "fullName": "<ORG>/<REPO>"
          },
          "depName": "lodash",
          "packageFilePath": "package.json",
          "currentValue": "4.0.0",
          "updateTargets": [
            {
              "updateType": "minor",
              "toValue": "4.18.1",
              "updateState": {
                "branchName": "renovate/lodash-4.x",
                "state": "pr-edited"
              }
            }
          ]
        },
        {
          "repository": {
            "fullName": "<ORG>/<REPO_2>"
          },
          "depName": "lodash",
          "packageFilePath": "package.json",
          "currentValue": "4.0.0",
          "updateTargets": [
            {
              "updateType": "minor",
              "toValue": "4.18.1",
              "updateState": {
                "branchName": "renovate/lodash-4.x",
                "state": "pr-edited"
              }
            }
          ]
        },
        {
          "repository": {
            "fullName": "<ORG>/<REPO_3>"
          },
          "depName": "lodash",
          "packageFilePath": "package.json",
          "currentValue": "4.0.0",
          "updateTargets": [
            {
              "updateType": "minor",
              "toValue": "4.18.1",
              "updateState": {
                "branchName": "renovate/lodash-4.x",
                "state": "pr-edited"
              }
            }
          ]
        }
      ],
      "pageInfo": {
        "hasNextPage": false,
        "endCursor": "eyJyZXBvc2l0b3J5SWQiOiI3ZDA3MmRiMi1mNGM0LTUxMmYtYWMyOC02NTFlMTY1OTg1ZjEiLCJiYXNlQnJhbmNoIjoibWFpbiIsIm9jY3VycmVuY2VJbmRleCI6MH0"
      }
    }
  }
}
```

> [!NOTE]
> Update targets and branch state reflect the last indexed Renovate scan, rather
> than live registry or pull request status. An empty `updateTargets` array means
> no updates were indexed for that usage.

### Pagination

When `pageInfo.hasNextPage` is `true`, pass `pageInfo.endCursor` as the `after`
argument in the next request. Keep all filters unchanged and continue until
`hasNextPage` is `false`.

Results reflect current indexed data, so scans between requests can change
subsequent pages.

## Inspect one repository

The repository endpoint supports `searchUsages` only. Omit the package filters to
list the repository's dependencies, or supply them to narrow the results.

```sh
export GRAPHQL_REQUEST="$(jq -n --arg query '
{
  searchUsages(first: 50) {
    nodes {
      datasource
      packageName
      packageFilePath
      currentValue
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
' '{
  "query": $query
}')"

curl -sS "$MEND_RNV_SERVER_HOSTNAME/api/v1beta1/repos/<ORG>/<REPO>/-/packages/graphql" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H 'Content-Type: application/json' \
  --data-binary "$GRAPHQL_REQUEST" | jq .
```

Response (`200`):

```json
{
  "data": {
    "searchUsages": {
      "nodes": [
        {
          "datasource": "npm",
          "packageName": "lodash",
          "packageFilePath": "package.json",
          "currentValue": "4.0.0"
        },
        {
          "datasource": "npm",
          "packageName": "got",
          "packageFilePath": "package.json",
          "currentValue": "14.4.7"
        },
        {
          "datasource": "npm",
          "packageName": "graceful-fs",
          "packageFilePath": "package.json",
          "currentValue": "4.2.4"
        }
      ],
      "pageInfo": {
        "hasNextPage": false,
        "endCursor": "<CURSOR>"
      }
    }
  }
}
```

See the [repository GraphQL schema](./graphql/repository-packages.graphql) for the
available fields and filters.

## Trigger matching repositories

Trigger jobs for repositories in an organization that use the npm package `lodash`
with a declared value of `4.0.0`.

```sh
curl -sS -X POST \
  "$MEND_RNV_SERVER_HOSTNAME/api/v1beta1/orgs/<ORG>/-/packages/npm/lodash/jobs?currentValue=4.0.0" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" | jq .
```

Response (`202`):

```json
{
  "matchedRepositories": 3
}
```

Three repositories matched. Each repository counts once, even if the package
appears in multiple files.

For system-wide job triggering, use `/system/v1beta1/packages/npm/lodash/jobs`.

> [!TIP]
> URI-encode package names used in the URL path.

> [!NOTE]
> Jobs run asynchronously using each repository's Renovate configuration.
> Triggering a job does not guarantee an update or pull request for the requested
> package. Support for package-targeted updates is planned.

## Related documentation

- [API Documentation](./api.md): enabling APIs and authentication.
- [Enterprise OpenAPI specification](./openapi-enterprise.yaml): endpoint contract.
- [Package GraphQL schema](./graphql/packages.graphql): system and organization queries.
- [Repository GraphQL schema](./graphql/repository-packages.graphql): repository queries.
