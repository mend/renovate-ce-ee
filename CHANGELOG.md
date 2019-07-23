# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

From release 0.16.2 and onwards, this Changelog is deprecated and is replaced by GitHub Releases ([link](https://github.com/renovatebot/pro/releases)).

## 0.16.1 - 2019-07-21

This patch release udpdates the core Renovate from `18.16.11` to `18.16.19`. It includes fixes from core Renovate as well as within Renovate Pro.

### Bug fixes

* **Pro**: Update priority when upserting into jobs table after webhook
* **Pro**: Catch scheduler bulk enqueue failure and attempt enqueing repositories sequentially
* **package-rules:** check compareVersion is a version first ([bc853ad](https://togithub.com/renovatebot/renovate/commit/bc853ad)), closes [#3952](https://togithub.com/renovatebot/renovate/issues/3952)
* **got:** repoCache was not updated ([#3958](https://togithub.com/renovatebot/renovate/issues/3958)) ([5a2eb75](https://togithub.com/renovatebot/renovate/commit/5a2eb75))
* **bazel:** extract urls for new hashes ([#3980](https://togithub.com/renovatebot/renovate/issues/3980)) ([49b8e13](https://togithub.com/renovatebot/renovate/commit/49b8e13))
* **bazel:** use docker version scheme for container_pull ([#3948](https://togithub.com/renovatebot/renovate/issues/3948)) ([fc5a806](https://togithub.com/renovatebot/renovate/commit/fc5a806))
* **bundler:** brace against undefined replace ([48b74c3](https://togithub.com/renovatebot/renovate/commit/48b74c3))
* **bundler:** delete update promise after awaiting ([cc2be02](https://togithub.com/renovatebot/renovate/commit/cc2be02)), closes [#3969](https://togithub.com/renovatebot/renovate/issues/3969)
* **bundler:** handled mixed quotation types ([#4103](https://togithub.com/renovatebot/renovate/issues/4103)) ([0c92ef4](https://togithub.com/renovatebot/renovate/commit/0c92ef4))
* **docker:** pass registry-failure up ([a9ed0cf](https://togithub.com/renovatebot/renovate/commit/a9ed0cf))
* **docker:** pass registry-failure up ([31a56ae](https://togithub.com/renovatebot/renovate/commit/31a56ae))
* **git:** platform-failure, not platform-error ([b3a0b78](https://togithub.com/renovatebot/renovate/commit/b3a0b78))
* **gitFs:** handle gnutls_handshake() failed ([be719e2](https://togithub.com/renovatebot/renovate/commit/be719e2))
* **gitFs:** platform-failure for Invalid username or password ([ab3d9a9](https://togithub.com/renovatebot/renovate/commit/ab3d9a9))
* **gomod:** pass GOPROXY ([e980552](https://togithub.com/renovatebot/renovate/commit/e980552)), closes [#4071](https://togithub.com/renovatebot/renovate/issues/4071)
* **npm:** fix detecting logic of npmClient ([#4130](https://togithub.com/renovatebot/renovate/issues/4130)) ([75b8869](https://togithub.com/renovatebot/renovate/commit/75b8869))
* **npm:** full npm install if deduping ([fddc9bd](https://togithub.com/renovatebot/renovate/commit/fddc9bd)), closes [#3972](https://togithub.com/renovatebot/renovate/issues/3972)
* Pass PROXY in child Process ([#4013](https://togithub.com/renovatebot/renovate/issues/4013)) ([afa26a0](https://togithub.com/renovatebot/renovate/commit/afa26a0))
* **nuget:** allow configurable versionScheme ([3c2d842](https://togithub.com/renovatebot/renovate/commit/3c2d842)), closes [#4027](https://togithub.com/renovatebot/renovate/issues/4027)
* **packagist:** gracefully handle ETIMEDOUT and 403 ([2615f3a](https://togithub.com/renovatebot/renovate/commit/2615f3a))
* **pip:** Add the ability to handle pip's --extra-index-url ([#4056](https://togithub.com/renovatebot/renovate/issues/4056)) ([5b6aa72](https://togithub.com/renovatebot/renovate/commit/5b6aa72))
* **pypi:** use better version detection ([b510a6b](https://togithub.com/renovatebot/renovate/commit/b510a6b)), closes [#4047](https://togithub.com/renovatebot/renovate/issues/4047)
* **worker:** fix rebase requested check ([#3987](https://togithub.com/renovatebot/renovate/issues/3987)) ([6d7ffa7](https://togithub.com/renovatebot/renovate/commit/6d7ffa7))

## 0.16.0 - 2019-07-14

This feature release updates the base from `renovate@14.23.0` to `renovate@18.16.11`.

### Build changes

The `renovate/pro` image now uses `renovate/renovate` as its base image, meaning that you can determine exactly which binary files come preinstalled by looking at the [corresponding Renovate OSS Dockerfile](https://github.com/renovatebot/renovate/blob/2f2c0736f67414a2d2fc0b129ca95dfc41bf0289/Dockerfile).

A second important change is that Renovate Pro now uses `git` under the hood for all file system queries. Renovate Pro performs a shallow clone each run like a CI system typically does, and having the full repo locally also enables some advanced features such as Go Modules vendoring.

### New Package Managers

- **Maven**: Supported added for `pom.xml` parsing, including ranges
- **Pipenv**: Pipfile and lock file updating now enabled
- **Poetry**: An alternative Python package manager
- **Ruby-version**: Update `.ruby-version` files
- **Dart**: Add support for package manager
- **Scala**: sbt support
- **Homebrew**: Add support for keeping homebrew definitions up to date
- **Clojure:** Add basic support for Leiningen and `deps.edn` ([#3685](https://github.com/renovatebot/renovate/issues/3685)) ([bda25d6](https://github.com/renovatebot/renovate/commit/bda25d6))

### New Features

- Nuget: Support authenticated feeds
- Bazel: Support `git_repository` commit hashes, use commit / tag combo for `go_repository`
- Bazel: Support commit-based `http_archive`
- `postUpdateOptions`: npm and yarn deduplication opt-in
- `packageRules`: support `baseBranchList` and `datasources` selectors
- Make `parentDir`, `baseDir` metadata available to templates
- Bazel: expand support to non-WORKSPACE files
- Bazel: support "container_pull" dependency-type
- npm package aliases
- Go Modules vendoring
- Node.js: Dynamically determine LTS versions by date
- Host Rules: Allow different rules based on full endpoint prefix
- Configurable timeouts per-host
- Use GraphQL to optimize issue list retrieval
- Better displayFrom/displayTo logic for Pull Request displays
- Provide npm diff links via renovatebot.com
- Add `commitBodyTable` option to append a table of all upgrades to a commit message body
- Pipenv: support index registry URLs
- Support scheduling by weeks of year
- Lock file maintenance for Composer

### Bug fixes

- lerna: call bootstrap if yarn workspaces not used
- npm: don’t set skipInstalls when file refs found
- run glob matching with dotfile matching enabled
- Nuget: opt in to semver 2.0.0 and prereleases
- Default 60s timeout for all requests to avoid potentially hanging forever
- Rebase branch if package file not found in existing branch
- Maven: isVersion/isSingleVersion/isValid correction
- PIP: detect lockedVersion when extracting
- Docker: handle host with port correctly
- gitFs: run checkout/reset when setting base branch
- Go modules: detect gopkg.in major bumps
- Master Issue add link to edited PRs

## 0.15.5

This patch fixes one issue: URLs in complex `--index-url` lines in Pip `requirements.txt` files are now parsed correctly.

## 0.15.4

This release was removed.

## 0.15.3 - 2019-03-07

This patch fixes two issues:

- Fixes global proxy support via `HTTPS_PROXY` etc (#42)
- Fixes GitLab scheduler authentication regression introduced in 0.15.2

## 0.15.2 - 2019-02-23

This patch release adds a slight refactoring to the way token handling is configured for GitHub Enterprise in an effort to fix or track down a missing token problem experienced by one user when upgrading to 0.15.x.

## 0.15.1 - 2019-02-20

This patch releases fixes a problem for GitLab where `GITLAB_TOKEN` was still required for pre-flight checks. Now, only `RENOVATE_TOKEN` is necessary for GitLab.

## 0.15.0 - 2019-02-18

This feature release updates the base `renovate` to `v14.19.1` and includes many new features.

### Breaking Changes

Please update your environment variables to use `RENOVATE_PLATFORM`, `RENOVATE_ENDPOINT` and `RENOVATE_TOKEN` instead of the deprecated `GITHUB_` and `GITLAB_` equivalents.

Also, as the underlying image for Renovate Pro has changed, make sure to switch the Docker user from `node` to `ubuntu` if you have configured that manually, e.g. in your Docker Compose file.

### New features

Ansible: support renovating Docker images
Bazel: Go support
CircleCI: Orb support
Docker: add support for basic auth (e.g. Artifactory)
Docker: preserve registry in `depName`
GitHub: block automerging a PR if negative reviews exist
Gradle: support updating gradle wrapper version
Onboarding: warn about unresolved packages
Other: Add ability to suppress Renovate notifications configurably
Other: Add proxy supportPackage Rules: support filtering by manager, language or sourceUrl
PRs: add rebasing checkbox
Pypi: try multiple hostUrls
Pypi: add simple URL endpoint support
Yarn: support integrity hashes

### Bug fixes

Artifactory: skip npm cache permanently
Docker: fix registryUrls support for `https://` prefix
Docker: fix header for tag fetching (Artifactory compatibility)
Docker: skip lookups for images containing variables
GitHub Enterprise: Fix release notes fetching from GHE
npm: Fix `.npmrc` package-lock massage
PRs: Fix rebase checkbox when conflicted

### Other

Renovate Pro now runs on Ubuntu 18.04 as its base image. This is to align with the open source Renovate's container base as well as Renovate's companion docker containers, all of which use Ubuntu 18.04. If you are mapping any files to `/home/node` then you need to now map them to `/home/ubuntu` instead.

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
