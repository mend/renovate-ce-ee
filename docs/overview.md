# Mend Renovate Self-hosted - Community Edition and Enterprise Edition

## Overview

Mend Renovate Self-hosted (Community Edition and Enterprise Edition) are commercial offerings of Renovate for self-hosted users, such as those running on GitHub, GitLab or Bitbucket Server/Data Center.

Essentially, it is an alternative to running the `renovate` CLI tool, with the following additions:

- Stateful job queue for prioritization of job importance
- Embedded job scheduler to remove the need to set up and monitor `cron`
- Webhook listener to enable dynamic reactions to repository events
- Administration APIs for probing the system state or triggering jobs

## Mend Renovate Self-hosted features

#### Job scheduler

The Docker containers for Mend Renovate Self-hosted contain a built-in job scheduler that defaults to enqueing all repositories once per hour.
This saves the need for configuring and monitoring any external `cron` process.

#### Webhook handler

Mend Renovate Self-hosted also supports a webserver to listen for system webhooks received from the SCM (GitHub, GitLab, Bitbucket).

In particular, it checks webhooks for:

- Projects it has just been added to
- Commits to `main` branch for "important" files such as `package.json` and `renovate.json`
- Any commits made to Renovate's branches
- Closing or merging of Renovate PRs

Each of the above results in a job being enqueued for the relevant repository, so that the bot will appear responsive to users.

#### Priority job queue

Priority-based queuing is essential for providing a responsive experience for bot users.
For example, if a user makes an update to the config in an onboarding PR, they ideally want to see the results immediately.
By assigning onboarding updates the highest priority in the queue, the bot's update to the onboarding PR can proceed as the very next job, even if many others were in the queue already.

In general, job priority is based on the probability that a user may be "waiting" for the bot to do something.
That's why onboarding updates are highest priority, and other high priority updates include merging of Renovate PRs because that very often results in other PRs needing updates or rebasing afterwards.

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
    - A wrapper on Renovate CLI, it runs non-stop, retrieving the highest priority job (repository) from the queue one at a time

All four components run within a shared container.
As with Renovate CLI, it can also be configured to interact with an external Redis server as an alternative to the default disk-based cache.

## Downloading

The Docker images for Mend Renovate Self-hosted are available via GitHub Container Registry (ghcr.io)

Use of the images are in accordance with the [Mend Terms of Service](https://www.mend.io/terms-of-service/).

- Community Edition: [mend/renovate-ce](https://ghcr.io/mend/renovate-ce).

- Enterprise Edition:
Enterprise Edition uses two separate Docker images: The Server image, and the Worker image.
  - Server image: [mend/renovate-ee-server](https://ghcr.io/mend/renovate-ee-server)
  - Worker image: [mend/renovate-ee-worker](https://ghcr.io/mend/renovate-ee-worker)

## Versioning

Mend Renovate Self-hosted products have their own versioning and release schedule, independent of Renovate CLI versioning.

Additionally, it is intended that Mend Renovate will have a slower release cadence than Renovate CLI in order to provide greater stability for Enterprise use.

Specifically, use of SemVer for Mend Renovate Self-hosted:

**Major**: Used only for breaking changes

**Minor**: Used for feature additions and any bug fixes considered potentially unstable

**Patch**: Used only for bug fixes that are considered to be stabilizing

i.e. we do not want to ever "break" anyone with a patch release, or have behavior change.

Renovate CLI feature releases (i.e. minor version bumps in Renovate CLI) will therefore only be incorporated into minor releases of Mend Renovate.

Typically, multiple Renovate CLI feature releases will be rolled up into a single Mend Renovate release, and release notes will be embedded so that you do not need to look them up separately.

## Releasing and Upgrading

The release cadence of Mend Renovate is not fixed, as it will be determined largely by the importance and stability of new Renovate CLI features, which will typically be tested using the hosted Renovate GitHub App first.

When a new version of Mend Renovate is pushed to GHCR, Release Notes will be added to this [github.com/mend/renovate-ce-ee](https://github.com/mend/renovate-ce-ee) repository.

Naturally, it is recommended that you use Renovate itself for detecting and updating Mend Renovate versions if you are using a Docker Compose file internally for running Mend Renovate.

## Running Mend Renovate Self-hosted

See the Setup Guides to get started with Mend Renovate Self-hosted
- [Setup guide for GitHub](setup-for-github.md)
- [Setup guide for GitLab](setup-for-gitlab.md)
- [Setup guide for Bitbucket Data Center](setup-for-bitbucket.md)

Examples using Docker Compose can be found at in the [examples directory](../examples).

## Testing Mend Renovate Self-hosted

Request `/health` on your IP address hosting the deployment to check if it is running correctly.

For further testing, use the [Admin APIs](./api.md) to:
- check the status of the server
- see the contents of the Job and Task queues
- perform an App sync
- run a job

It is recommended not to expose the API endpoint to the internet as it could leak information about private repository names.
