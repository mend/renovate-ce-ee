# Renovate Self-Hosted API

Mend Renovate Self-Hosted contains APIs that can self-hosted deployment administrators and Renovate users alike can use.

We document these APIs using the OpenAPI standard:

- [`openapi-enterprise.yaml`](openapi-enterprise.yaml)
- [`openapi-community.yaml`](openapi-community.yaml)

A subset of APIs are available on the Community Edition, which is why we have split the specifications, so a Community user is able to clearly see which APIs they have available to them.

## Enabling APIs via environment variables

When starting the Renovate Server, the APIs are not enabled by default, and must be enabled through environment variables.

Note that some of the API types require more than one environment variable to be set.

| API type | OpenAPI tag | Environment variables |
| -------- | ----------- | --------------------- |
| Public APIs | `API`  | `env MEND_RNV_API_ENABLED=true` |
| System APIs | `System` | `env MEND_RNV_API_ENABLED=true MEND_RNV_API_ENABLE_SYSTEM=true` |
| Jobs APIs  | `Jobs` |  `env MEND_RNV_API_ENABLED=true MEND_RNV_API_ENABLE_JOBS=true` |
| Reporting APIs  | `Reporting` | `env MEND_RNV_API_ENABLED=true MEND_RNV_API_ENABLE_REPORTING=true` |

All APIs can be enabled alongside each other, by specifying _all_ of the environment variables noted above. There is no current means to enable all APIs in a single environment variable due to security concerns.

## OpenAPI browser

You can see [a rendered copy](https://mend.github.io/renovate-ce-ee/api.html) of the current documentation on `main`.

## Breaking changes

Mend will only make breaking changes to the APis as part of a major version release, according to [Semantic Versioning (SemVer)](https://semver.org/spec/v2.0.0.html).

However, there are some endpoints and fields that do not have a backwards-compatibility guarantee. These endpoints and fields are marked with `x-no-backwards-compatibility-guarantees`.
