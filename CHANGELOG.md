# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.14.0 - 2018-11-06

This feature release adds several new package managers plus many feature improvements. It upgrades the base `renovate` to v13.121.0.

### New Package Managers

#### Go Modules

Renovate now supports updating `go.mod` and `go.sum` files - both for dependencies using semver versions as well as those still using git digests. The `go` binary is bundled with Renovate Pro and runs inside the main container.

#### Composer (PHP)

Composer support is now officially released and supports `composer.json` and `composer.lock` files. The `composer` binary is also bundled with the main Renovate Pro container.

#### Terraform Modules

Renovate Pro now supports updating Terraform Modules - both for dependencies hosted on github as well as using Terraform's official registry. No binary is necessary for this as there are no checksums or lock files.

### New Features

#### Master Issue Support

Setting `masterIssue` or `masterIssueApproval` values to `true` will result in a "master issue" being created in the repository that lists all outstanding updates, including those which are pending, open, or closed (ignored). By using GitHub's intelligent checkboxes, users are able to request manual rebases or approvals of each listed dependency.

Setting `masterIssue` to `true` makes no change to Renovate functionality and simply adds a type of "mini dashboard issue" to each repo for better visibility of Renovate's branches and PRs.

Setting `masterIssueApproval` to `true` changes Renovate's workflow so that it does not create a branch or PR until after it is "approved" within the Master Issue. Using the Master Issue means you could defer all updates until they are approved, or just defer some of them. e.g. maybe you configure approval for only `major` updates.

#### Manual Rebasing of PRs

Apart from rebasing using the Master Issue, it is also possible to request that Renovate manually rebases a PR from within the PR. You can do this with either of two ways:

1. Rename the PR to being with "rebase!", e.g. Rename it to "rebase! Upgrade dependency nock ........."
2. Add the label "rebase" to the PR

Both of these options will trigger a webhook to Renovate Pro, resulting in it immediately processing the repository and rebasing the PR in question. Having this option might mean you can set `rebaseStalePrs` to `false` in some repos to avoid the "noise" that comes with having the rebased every time automatically.

### Other Improvements

- Better caching has been added to most datasources to improve efficiency and reduce the number of requests, e.g. to github.com or Docker Hub
- Pull Request Body templates are greatly improved and also support easier customization now
- Support for GitHub's new "Check Runs" feature. Note: requires additional privileges for the Renovate Pro app
- Support autodetection for Yarn integrity hashes (Renovate will not add them unless the repository already uses them)
- Specify default Docker registry (Closes #27)
- Support upgrading "short" Docker versions, e.g. from 3.8 to 3.9
- Support an ignore instruction in `requirements.txt`
- Support Python version compatibility restriction

### New GitHub Permissions and Webhooks

Add/grant the following permissions for your Renovate Pro app if available:
- Checks: Read & write
- Security vulnerability alerts: Read-only

Also add webhook event subscriptions for "Issues" so that Renovate Pro can detect when the Master Issue has been edited.

## 0.13.1 - 2018-09-15

This maintenance release updates `renovate` from `13.51.9` to `13.51.10`.

### Bug Fixes

* move cleanRepo to finally ([6d238f7](https://github.com/renovatebot/renovate/commit/6d238f7))
* set endpoint for GITHUB_COM_TOKEN ([5bdc89f](https://github.com/renovatebot/renovate/commit/5bdc89f))
* throw error up if no disk space ([5e1a095](https://github.com/renovatebot/renovate/commit/5e1a095))
* update dependency npm to v6.4.1 ([f16bf47](https://github.com/renovatebot/renovate/commit/f16bf47))
* **ghe:** use full path for github datasource ([507e8cb](https://github.com/renovatebot/renovate/commit/507e8cb)), closes [#2518](https://github.com/renovatebot/renovate/issues/2518)
* **github:** platform-error if ENOTFOUND ([825f89f](https://github.com/renovatebot/renovate/commit/825f89f))
* **github:** throw platform error for ETIMEDOUT ([2322bbb](https://github.com/renovatebot/renovate/commit/2322bbb))
* **lerna:** detect changed lock files properly ([9e609b2](https://github.com/renovatebot/renovate/commit/9e609b2)), closes [#2519](https://github.com/renovatebot/renovate/issues/2519)
* **npm:** compare res.name or res._id ([49f7e38](https://github.com/renovatebot/renovate/commit/49f7e38))
* update languageList in manager ([bce573f](https://github.com/renovatebot/renovate/commit/bce573f))
* use full URL for changelog retrieval ([6bac962](https://github.com/renovatebot/renovate/commit/6bac962))
* **npm:** default lockfile value ([4fe9e32](https://github.com/renovatebot/renovate/commit/4fe9e32))
* **onboarding:** correct merge conflict detection ([d5fe70f](https://github.com/renovatebot/renovate/commit/d5fe70f)), closes [#2524](https://github.com/renovatebot/renovate/issues/2524)
* **pypi:** better normalize package name ([1d14145](https://github.com/renovatebot/renovate/commit/1d14145))
* **yarn:** throw errors when registry down ([8fd042d](https://github.com/renovatebot/renovate/commit/8fd042d)), closes [#2474](https://github.com/renovatebot/renovate/issues/2474) [#2475](https://github.com/renovatebot/renovate/issues/2475)

## 0.13.0 - 2018-08-31

This feature release adds GitLab support, a heartbeat endpoint, as well as many Renovate OSS core features.

### Features

#### Renovate Pro

- GitLab support: see configuration doc for details
- Heartbeat endpoint: `GET /` on the webhook port now returns `200 OK` when Renovate Pro is running

#### Renovate Core

General:

- Separate groups into major/minor/patch
- PRs: pin PRs should only block necessary PRs
- PRs: skip schedule for pin dependencies
- PRs: raise prs with lock file warning
- PRs: linkify PR bodies whenever possible
- PRs: link to both homepage and source repo
- Presets: support github hosting in addition to npm
- Onboarding: better formatting of PR body

GitHub:

- Vulnerability alerts override schedule

Package Managers:

- Composer: support short versions
- Composer: lock file support
- Docker: use generic lookup/auth
- Docker: Docker authentication
- Docker: Support `COPY --from` lines
- GitLab: Support `gitlabci.yml` files
- Kubernetes: support k8s manifest files
- Python: use PIP_INDEX_URL for repository url

## 0.12.1 - 2018-07-09

### Bug fixes

- don’t try branch automerge on first run
- npm: move ignoreNpmrcFile logic out of mirror mode
- npm: set lockedVersion only if valid semver
- `ACCEPT_LICENSE=y` typo

## 0.12.0 - 2018-06-27

This feature release updates the Renovate OSS core from 12.23.x to 13.0.x.

### Breaking Changes

- `gitAuthor` is now an admin-only configuration option
- `pinDigests` is now disabled by default
- `automergeType="branch-merge-commit"` is no longer supported, use `"branch"` instead

### Features

- New `force` configuration option allows bot admin to override a repository's configured settings
- `nuget` support (.NET)
- `pip` `requirements.txt` support (Python)
- `composer` support (PHP)
- Comment in PR to explain if it is raised as a result of failed branch automerge
- Support `=x.y.z` format for `npm` package managers
- Support bumping greater than or equal to ranges
- Support GitHub Enterprise changelogs

### Fixes

- More consistent Changelog caching for reduced churn if PR bodies
- improve compatibility with nexus private npm repo
- Handle `GITHUB_ENDPOINT` with missing traiing slash in Pro env config

## 0.11.2 - 2018-05-25

Updated Renovate to v12.21.17

### Fixed
- npmrc: don’t massage naked ‘_auth’

## 0.11.1 - 2018-05-22

### Changed
- Updated Renovate to v12.21.16

### Fixed
- Remove evaluation footer when in commercial mode

## 0.11.0 - 2018-05-09

### Changed
- Updated Renovate to v12.21.2

## 0.10.0 - 2018-04-28

### Added
- Listen on `process.env.PORT` if specified
- Use `process.env.DATABASE_URL` if present

### Changed
- Updated Renovate to v12.7.1

### Fixed
- Don't attempt to load pem app key if already set in env
- Add check to avoid undefined error in err handler

## 0.9.0 - 2018-04-24

Initial release of Renovate Pro
