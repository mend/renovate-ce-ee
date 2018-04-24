# Renovate Pro Overview

## Architecture

Logically, Renovate Pro consists of four components:

1. Database (PostgreSQL)
    - Used for keeping the job queue, job log, and a list of known installations and repositories
2. Scheduler
    - Runs according to a `cron` schedule (defaults to hourly)
    - Retrieves a list of all installed repositories and adds them to the job queue with lowest priority
3. Webhook Handler
    - Listens for webhook events from GitHub
    - Adds higher priority jobs to the job queue if event conditions are met (e.g. a merged or closed Renovate PR, an update to an existing Renovate PR, a commit to `renovate.json` in `master` branch, etc)
4. Worker
    - Runs non-stop, retrieving the highest priority job (repository) from the queue one at a time

The database runs within its own container (`db`) while the scheduler, webhook handler, and worker run within a shared container (`server`).  You should be running 1 of each container at all times, and never more.

## Downloading

The Renovate Pro image is available via public Docker Hub using the namespace [renovate/pro](https://hub.docker.com/r/renovate/pro/). 
Use of the image is as described on Docker Hub, i.e. in accordance with the [Renovate User Agreement](https://renovatebot.com/user-agreement).

The PostgreSQL image can also be downloaded via Docker Hub according to its license conditions, and version 10 is supported by Renovate Pro.

## Versioning

Renovate Pro uses its own semantic versioning, separate from Renovate OSS versioning. 
Additionally, it is intended that Renovate Pro will have a slower release cadence than Renovate OSS in order to provide greater stability for Enterprise use.

Specifically for Renovate Pro's use of SemVer:

**Major**: Used only for breaking changes

**Minor**: Used for feature additions and any bug fixes considered potentially unstable

**Patch**: Used only for bug fixes that are considered to be stabilising

i.e. we do not want to ever "break" anyone with a patch release, or have behaviour change. 

Renovate OSS feature releases (i.e. minor version bumps in Renovate OSS) will therefore only be incorporated into minor releases of Renovate Pro.

Typically, multiple Renovate OSS feature releases will be rolled up into a single Renovate Pro release, and release notes will be embedded so that you do not need to look them up separately.

## Releasing and Upgrading

The release cadence of Renovate Pro is not fixed, as it will be determined largely by the importance and stability of new Renovate OSS features, which will typically be tested using the hosted Renovate GitHub App first.
When a new version of Renovate Pro is pushed to Docker Hub, Release Notes will be added to this [github.com/renovatebot/pro](https://github.com/renovatebot/pro) repository.

Meanwhile, we may publish unversioned "latest" images to Docker Hub between releases, e.g. incorporating bleeding edge updates of Renovate Pro features and/or Renovate OSS.

It is not recommended that you adopt "latest" as your source tag for Renovate Pro, but there may be times when you wish to test a new Renovate OSS feature and that is the recommended option.

Naturally, it is recommended that you use Renovate itself for detecting and updating Renovate Pro versions if you are using a Docker Compose file internally for running Renovate Pro.

## Running Renovate Pro

Renovate Pro runs inside a single Docker container, however it requires a sibling PostgreSQL container for running the job queue.

An [example using Docker Compose](https://github.com/renovatebot/pro/blob/master/examples/docker-compose.yml) can be found in the `examples/` directory of this repository.
