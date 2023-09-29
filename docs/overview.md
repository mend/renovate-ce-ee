# Mend Renovate Community Edition and Enterprise Edition

## Overview

Mend Renovate Community Edition (Renovate CE) and Enterprise Edition (Renovate EE) are commercial offerings of Renovate for self-hosted users, such as those running on GitHub or GitLab.

Essentially, it is an alternative to running the `renovate` CLI tool, with the following additions:

- Stateful job queue for prioritization of job importance
- Embedded job scheduler to remove the need to set up and monitor `cron`
- Webhook listener to enable dynamic reactions to repository events
- Administration APIs for probing the system state or triggering jobs

## Architecture

Logically, Mend Renovate consists of four components:

1.  In-memory DB/state
    - Used for storing the job queue and a list of known installations and repositories
    - Can be persisted to file and interrogated by SQL tools
2.  Scheduler
    - Runs according to a `cron` schedule (defaults to hourly)
    - Retrieves a list of all installed repositories and adds them to the job queue
3.  Webhook Handler
    - Listens for webhook events from GitHub/GitLab, on path `/webhook`
    - Adds high priority jobs to the job queue if event conditions are met (e.g. a merged or closed Renovate PR, an update to an existing Renovate PR, a commit to `renovate.json` in `main` branch, etc)
4.  Worker
    - A wrapper on Renovate OSS, it runs non-stop, retrieving the highest priority job (repository) from the queue one at a time

All four components run within a shared container.
As with Renovate OSS, it can also be configured to interact with an external Redis server as an alternative to the default disk-based cache.

## Downloading

The Mend Renovate CE image is available via GitHub Container Registry (ghcr.io) using the namespace [mend/renovate-ce](https://ghcr.io/mend/renovate-ce).
Use of the image is in accordance with the [Mend Terms of Service](https://www.mend.io/free-developer-tools/terms-of-use/).

## Versioning

Mend Renovate products have their own versioning and release schedule, independent of Renovate OSS versioning.

Additionally, it is intended that Mend Renovate will have a slower release cadence than Renovate OSS in order to provide greater stability for Enterprise use.

Specifically for Mend Renovate's use of SemVer:

**Major**: Used only for breaking changes

**Minor**: Used for feature additions and any bug fixes considered potentially unstable

**Patch**: Used only for bug fixes that are considered to be stabilizing

i.e. we do not want to ever "break" anyone with a patch release, or have behavior change.

Renovate OSS feature releases (i.e. minor version bumps in Renovate OSS) will therefore only be incorporated into minor releases of Mend Renovate.

Typically, multiple Renovate OSS feature releases will be rolled up into a single Mend Renovate release, and release notes will be embedded so that you do not need to look them up separately.

## Releasing and Upgrading

The release cadence of Mend Renovate is not fixed, as it will be determined largely by the importance and stability of new Renovate OSS features, which will typically be tested using the hosted Renovate GitHub App first.

When a new version of Mend Renovate is pushed to GHCR, Release Notes will be added to this [github.com/mend/renovate-ce-ee](https://github.com/mend/renovate-ce-ee) repository.

Naturally, it is recommended that you use Renovate itself for detecting and updating Mend Renovate versions if you are using a Docker Compose file internally for running Mend Renovate.

## Running Mend Renovate

[Examples using Docker Compose](https://github.com/mend/renovate-cc-ee/tree/main/examples) can be found in the `examples/` directory of this repository.

Request `/status` on your IP address hosting the deployment to check if it is running correctly.
It is recommended not to expose that endpoint to the internet as it could leak information about private repository names.
