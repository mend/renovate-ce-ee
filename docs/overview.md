# WhiteSource Renovate On-Premises Overview

## Introduction

WhiteSource Renovate On-Premises ("WhiteSource Renovate") is a commercial offering of Renovate for self-hosted users, such as those running GitHub Enterprise or GitLab CE/EE.

Essentially, it is an alternative to running the `renovate` CLI tool, with the following additions:

- Stateful job queue for prioritization of job importance
- Embedded job scheduler to remove the need to set up and monitor `cron`
- Webhook listener to enable dynamic reactions to repository events

## Architecture

Logically, WhiteSource Renovate consists of four components:

1.  In-memory DB
    - Used for keeping the job queue and a list of known installations and repositories
2.  Scheduler
    - Runs according to a `cron` schedule (defaults to hourly)
    - Retrieves a list of all installed repositories and adds them to the job queue
3.  Webhook Handler
    - Listens for webhook events from GitHub/GitLab
    - Adds high priority jobs to the job queue if event conditions are met (e.g. a merged or closed Renovate PR, an update to an existing Renovate PR, a commit to `renovate.json` in `master` branch, etc)
4.  Worker
    - Runs non-stop, retrieving the highest priority job (repository) from the queue one at a time

All four components run within a shared container.

## Downloading

The WhiteSource Renovate image is available via public Docker Hub using the namespace [whitesource/renovate](https://hub.docker.com/r/whitesource/renovate/).
Use of the image is as described on Docker Hub, i.e. in accordance with the [WhiteSource Terms of Service](https://renovate.whitesourcesoftware.com/terms-of-service/).

## Versioning

WhiteSource Renovate On-Premises uses its own versioning and release schedule, independent of Renovate OSS versioning.

Additionally, it is intended that WhiteSource Renovate will have a slower release cadence than Renovate OSS in order to provide greater stability for Enterprise use.

Specifically for WhiteSource Renovate's use of SemVer:

**Major**: Used only for breaking changes

**Minor**: Used for feature additions and any bug fixes considered potentially unstable

**Patch**: Used only for bug fixes that are considered to be stabilizing

i.e. we do not want to ever "break" anyone with a patch release, or have behavior change.

Renovate OSS feature releases (i.e. minor version bumps in Renovate OSS) will therefore only be incorporated into minor releases of WhiteSource Renovate.

Typically, multiple Renovate OSS feature releases will be rolled up into a single WhiteSource Renovate release, and release notes will be embedded so that you do not need to look them up separately.

## Releasing and Upgrading

The release cadence of WhiteSource Renovate is not fixed, as it will be determined largely by the importance and stability of new Renovate OSS features, which will typically be tested using the hosted Renovate GitHub App first.

When a new version of WhiteSource Renovate is pushed to Docker Hub, Release Notes will be added to this [github.com/whitesource/renovate](https://github.com/whitesource/renovate) repository.

Naturally, it is recommended that you use Renovate itself for detecting and updating WhiteSource Renovate versions if you are using a Docker Compose file internally for running WhiteSource Renovate.

## Running WhiteSource Renovate

[Examples using Docker Compose](https://github.com/whitesource/renovate/blob/master/examples/) can be found in the `examples/` directory of this repository.

Request `/status` on your IP address hosting the deployment to check if it is running correctly.
It is recommended not to expose that endpoint to the internet as it could leak information about private repository names.
