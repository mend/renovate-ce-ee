# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
