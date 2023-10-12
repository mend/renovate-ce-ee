# Configuration - Mend Renovate Enterprise Edition for GitLab

## Configure Renovate Bot Account on GitLab

### Renovate Bot Account

Create a GitLab user account to act as the "Renovate Bot".
If you are running your own instance of GitLab, it's suggested to name the account "Renovate Bot" with username "renovate-bot".

Note: In GitLab, the "Renovate Bot" is not an App or Plugin; it's a GitLab user account that's been given the right permissions and System Hooks.
You should use a dedicated "bot account" for Renovate, instead of using someone's personal user account.
Apart from reducing the chance of conflicts, it is better for teams if the actions they see from Renovate are clearly marked as coming from a dedicated bot account and not from a teammate's account, which could be confusing at times.
e.g. Did the bot automerge that PR, or did a human do it?

### Personal Access Token

Once the account is created, create a Personal Access Token for it with the following permissions:
  * `api`
  * `read_user`
  * `write_repository`

### System Hook

To activate Mend Renovate's webhook ability, create a System Hook that points to the Renovate installation.

Create a System Hook (in Admin area)

1. Set the webhook URL to point to the Renovate server url followed by `/webhook`. (e.g. `http://renovate.yourcompany.com:8080/webhook` or `https://1.2.3.4/webhook`)
2. Set the webhook secret to the same value configured for `MEND_RNV_WEBHOOK_SECRET` (defaults to `renovate`)
3. Set Hook triggers for:
  * `Push events`
  * `Merge request events`

Remember: Renovate's webhook listener binds to port 8080 inside its container, but you can map it (using Docker) to whatever external port you require, including port 80.

Set the "Secret Token" to the same value configured for `MEND_RNV_WEBHOOK_SECRET`, or set it to `"renovate"` if you left it as default.

Once your System Hook is added, Renovate's webhook handler will receive events from _all_ repositories.
Therefore, Renovate maintains a list of all repositories it has access to and discards events from all others.

### Repo Webhooks

Because Issue events aren't included in System hooks, a webhook must be individually configured for each repository in which you want the Dependency Dashboard issue to be interactive.

In the Repository settings, create a Webhook with the following settings:
1. Set the webhook URL - same as System Hook URL
2. Set the webhook secret - same as System Hook secret
3. Set Hook triggers for:
  * `Issue events`

This will need to be repeated for every repository that is onboarded to the Renovate Bot account.
It is usually easiest to create the repo webhook while adding the Renovate Bot account to a repo.


## Configure Mend Renovate EE

Renovate Enterprise runs with one **_Server_** container and one or more **_Worker_** containers.
See below for a list of environment variables that relate to each.

### Environment variables - Renovate Enterprise Server

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: For a Renovate Enterprise license key, contact Mend via the [Renovate Enterprise webpage](https://www.mend.io/renovate-enterprise/).

**`MEND_RNV_PLATFORM`**: Set this to `gitlab`.

**`MEND_RNV_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation. Required for GitHub Enterprise Server; not for GitHub.com. Include the trailing slash.

**`MEND_RNV_GITLAB_PAT`**: Personal Access Token for the GitLab bot account.

**`MEND_RNV_WEBHOOK_SECRET`**: Optional: Defaults to `renovate`

**`MEND_RNV_SERVER_API_SECRET`**: Set an API secret. Must match the Worker instances and Admin APIs for communicating with the Server.

**`MEND_RNV_ADMIN_API_ENABLED`**: Optional: Set to 'true' to enable Admin APIs. Defaults to 'false'.

**`MEND_RNV_SQLITE_FILE_PATH`**: Optional: Provide a path to persist the database. (eg. '/db/renovate-ce.sqlite', where 'db' is defined as a volume)

**`MEND_RNV_CRON_JOB_SCHEDULER`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 * * * *` (i.e. once per hour exactly on the hour). This cron job triggers the Renovate bot against the projects in the SQLite database. If decreasing the interval then be careful that you do not cause too much load.

**`MEND_RNV_CRON_APP_SYNC`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 0,4,8,12,16,20 \* \* \*` (every 4 hours, on the hour). This cron job performs autodiscovery against the platform and fills the SQLite database with projects.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. _not_ an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to. It needs only read-only access privileges.

**`MEND_RNV_AUTODISCOVER_FILTER`**: a string of a comma separated values (e.g. `org1/*, org2/test*, org2/test*`)

**`MEND_RNV_ENQUEUE_JOBS_ON_STARTUP`**: The job enqueue behavior on start (or restart). Defaults to `discovered`. (Note that the behavior can be different if the database is persisted or not)
- `enabled`: enqueue a job for all available repositories
- `discovered`: enqueue a job only for newly discovered repositories
- `disabled`: No jobs are enqueued

**`MEND_RNV_MC_TOKEN`**: The merge confidence token used for Smart-Merge-Control authentication

### Environment variables - Renovate Enterprise Worker

The Worker container needs to define only the following variables:

* **`MEND_RNV_SERVER_HOSTNAME`**: The hostname of the Renovate Enterprise `server` container (eg. http://renovate-ee-server:8080)
* **`MEND_RNV_SERVER_API_SECRET`**: Set to same as Server
* **`MEND_RNV_ACCEPT_TOS`**: Set to same as Server
* **`MEND_RNV_LICENSE_KEY`**: Set to same as Server


## Configure Renovate Core

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Mend Renovate container to `/usr/src/app/config.js`.

**npm Registry** If using your own npm registry, you may find it easiest to update your Docker Compose file to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.

## Run Mend Renovate

You can run Mend Renovate from a Docker command line prompt, or by using a Docker Compose file. An example is provided below.

**Docker Compose File**: Renovate EE on GitHub

```yaml
version: '3.6'

x-controller-shared-variables: &variables-controller
  MEND_RNV_SERVER_HOSTNAME: http://renovate-ee-server:8080
  MEND_RNV_SERVER_API_SECRET: # This secret will be used by the Worker and by Admin APIs
  # Provide Mend License and accept Terms of Service
  MEND_RNV_ACCEPT_TOS: # Set to 'y' to accept the Mend Renovate Terms of Service
  MEND_RNV_LICENSE_KEY: # Set this to the Renovate Enterprise key obtained from Mend

services:
  renovate-ee-server:
    restart: on-failure
    image: ghcr.io/mend/renovate-ee-server:6.0.0
    ports:
      - "80:8080" # Receive webhooks on port 80
    environment:
      <<: *variables-controller
      # Optional: Define log level. Set to Debug for more verbose output
      # LOG_LEVEL: debug
      # Provide connection details for the Renovate Bot/App
      MEND_RNV_PLATFORM: # Set to `github` or `gitlab`
      MEND_RNV_ENDPOINT: # Required for GitLab or GitHub Enterprise Server; not for GitHub.com. Include the trailing slash.
      MEND_RNV_GITHUB_APP_ID: # GitHub Only! GitHub App ID
      MEND_RNV_GITHUB_APP_KEY: # GitHub Only! GitHub App Key (PEM file). Alternatively mount as a volume below
      MEND_RNV_WEBHOOK_SECRET: # Optional: defaults to 'renovate'
      # Optional settings for Mend Renovate
      # MEND_RNV_ADMIN_API_ENABLED: # Optional: Set to 'true' to enable Admin APIs. Defaults to 'false'.
      # MEND_RNV_SQLITE_FILE_PATH: /db/renovate-ee.sqlite # Optional: Provide a path to persist the database. Needs 'db' volume defined (below).
      # MEND_RNV_CRON_JOB_SCHEDULER: # Optional Job enqueue schedule: defaults to '0 * * * *' (hourly, on the hour)
      # MEND_RNV_CRON_APP_SYNC: # Optional AppSync schedule: defaults to '0 0,4,8,12,16,20 * * *' (every 4 hours, on the hour)
      # Core Renovate settings
      # GITHUB_COM_TOKEN: # Personal Access Token for github.com (used for retrieving changelogs)
    # volumes:
      # Optional: You can use a file mount to persist the database between sessions
      # - "/tmp/db/:/db/" # Unix-style file mounting for the db
      # - "C:\\tmp/db/:/db/" # Windows-style file mounting for the db
    healthcheck:
      test: curl --fail http://renovate-ee-server:8080/health || exit 1
      interval: 60s
      retries: 5
      start_period: 20s
      timeout: 10s

  renovate-ee-worker:
    restart: on-failure
    deploy:
      # Post deploy:
      # $ docker-compose -f docker-compose-renovate-ee.yml up --scale renovate-ee-worker=3 -d --no-recreate
      replicas: 2
    image: ghcr.io/mend/renovate-ee-worker:6.0.0-full
    depends_on:
      - renovate-ee-server
    environment:
      <<: *variables-controller
      # Optional: Define log level. Set to Debug for more verbose output
      # LOG_LEVEL: debug
```
