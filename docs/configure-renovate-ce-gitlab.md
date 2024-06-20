# Configuration - Mend Renovate Community Edition for GitLab

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


## Configure Mend Renovate CE

### Mend Renovate environment variables

Mend Renovate requires configuration via environment variables in addition to Renovate OSS's regular configuration:

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: This should be the license key you obtained after registering at [https://www.mend.io/renovate-community/](https://www.mend.io/renovate-community/).

**`MEND_RNV_PLATFORM`**: Set this to `gitlab`.

**`MEND_RNV_ENDPOINT`**: This is the API endpoint for your GitLab host. e.g. like `https://gitlab.company.com/api/v4/`. Include the trailing slash.

**`MEND_RNV_GITLAB_PAT`**: Personal Access Token for the GitLab bot account.

**`MEND_RNV_WEBHOOK_SECRET`**: Optional: Defaults to `renovate`

**`MEND_RNV_ADMIN_API_ENABLED`**: Optional: Set to 'true' to enable Admin APIs. Defaults to 'false'.

**`MEND_RNV_SERVER_API_SECRET`**: Required if Admin APIs are enabled.

**`MEND_RNV_SERVER_PORT`**: The port on which the server listens for webhooks and api requests. Defaults to 8080.

**`MEND_RNV_SQLITE_FILE_PATH`**: Optional: Provide a path to persist the database. (eg. '/db/renovate-ce.sqlite', where 'db' is defined as a volume)

> [!IMPORTANT]  
> The container running the Renovate CE service requires read, write, and execute (rwx) permissions for the parent folder of the SQLite file. Additionally, the process inside the container executes with uid=1000 (ubuntu) and gid=0 (root).

The [sqlite3](https://sqlite.org/cli.html) CLI tool is preinstalled in the Renovate CE/EE(server) images, allowing direct interaction with the underlying SQLite database.

For example, Let `MEND_RNV_SQLITE_FILE_PATH=/db/renovate-ce.sqlite`:
```shell
ubuntu@23cf5aaa72ed:/usr/src/app$ sqlite3
SQLite version 3.31.1 2020-01-27 19:55:54
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> .open -readonly /db/renovate-ce.sqlite
sqlite> .tables
job_queue   migrations  org         repo        task_queue
sqlite> 
```

**`MEND_RNV_CRON_JOB_SCHEDULER`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 * * * *` (i.e. once per hour exactly on the hour). This cron job triggers the Renovate bot against the projects in the SQLite database. If decreasing the interval then be careful that you do not cause too much load.

**`MEND_RNV_CRON_APP_SYNC`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 0,4,8,12,16,20 * * *` (every 4 hours, on the hour). This cron job performs autodiscovery against the platform and fills the SQLite database with projects.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. _not_ an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to. It needs only read-only access privileges. Note: This is required if you are using a self-hosted GitHub Enterprise or GitLab instance but should not be configured if your `RENOVATE_ENDPOINT` is `https://api.github.com`.

**`MEND_RNV_AUTODISCOVER_FILTER`**: a string of a comma separated values (e.g. `org1/*, org2/test*, org2/test*`). Same behavior as Renovate [autodiscoverFilter](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter)

> [!WARNING]  
> The Renovate CLI [autodiscover](https://docs.renovatebot.com/self-hosted-configuration/#autodiscover) configuration option is disabled at the client level. Repository filtering should solely rely on server-side filtering using `MEND_RNV_AUTODISCOVER_FILTER`.

**`MEND_RNV_ENQUEUE_JOBS_ON_STARTUP`**: The job enqueue behavior on start (or restart). Defaults to `discovered`. (Note that the behavior can be different if the database is persisted or not)
- `enabled`: enqueue a job for all available repositories
- `discovered`: enqueue a job only for newly discovered repositories
- `disabled`: No jobs are enqueued

**`MEND_RNV_LOG_HISTORY_DIR`**: Optional: Specify a directory path to save Renovate job log files, recommended to be an external volume to preserve history. Log files will be saved in a `./ORG_NAME/REPO_NAME/` hierarchy under the specified folder. Log file name structure is as follows: `(<timestamp>_<log_context>.log)`.

Where:
- `<timestamp>`: timestamp in the format `YYYYMMDD_HHmmss` local time
- `<log_context>`: random 10 character alphanumeric string used as
  [Renovate log context](https://docs.renovatebot.com/self-hosted-configuration/#logcontext) for cross referencing logs.

For Example:
Let `MEND_RNV_LOG_HISTORY_DIR=/home/renovate/logs`, repository=`org/repo`

The corresponding Renovate job log file will be saved as:

```
/home/renovate/logs/org/repo/20231025_104229_6e4ecdc343.log
```

> [!IMPORTANT]  
> Logs are saved by the Renovate OSS cli, so the corresponding folder must exist in the CE/EE-Worker container.

**`MEND_RNV_LOG_HISTORY_TTL_DAYS`**: Optional: The number of days to save log files. Defaults to 30.

**`MEND_RNV_LOG_HISTORY_CLEANUP_CRON`**: Optional: Specifies a 5-part cron schedule. Defaults to `0 0 * * *` (every midnight). This cron job cleans up log history in the directory defined by `MEND_RNV_LOG_HISTORY_DIR`. It deletes any log file that exceeds the `MEND_RNV_LOG_HISTORY_TTL_DAYS` value.

**`MEND_RNV_WORKER_EXECUTION_TIMEOUT`**: Optional: Sets the maximum execution duration of a Renovate CLI scan in minutes. Defaults to 60.

### Core Renovate Configuration

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Mend Renovate container to `/usr/src/app/config.js`.

**npm Registry** If using your own npm registry, you may find it easiest to update your `docker-compose.yml` to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.

## Enabling Renovate on Repositories

To enable Renovate on a repository, in the project's _Settings -> Members_ section, add the bot user and give it `Developer` permissions.

Remember to add a webhook with "Issue events" to the repository if you wish to enable interactive dashboard issues. (See _Create Repo Webhooks_ above)

Adding Renovate as a Developer to a repository cause a system hook to be sent to Renovate which in turn enqueues a job for the Renovate Worker.
The repository should receive an onboarding PR immediately after.

## Run Mend Renovate

You can run Mend Renovate from a Docker command line prompt, or by using a Docker Compose file. An example is provided below.

**Docker Compose File**: Renovate CE on GitLab

```yaml
version: "3.6"
services:
  renovate:
    image: ghcr.io/mend/renovate-ce:<VERSION>-full
    restart: on-failure
    environment:
      # Optional: Define log level. Set to Debug for more verbose output
      # - LOG_LEVEL=DEBUG
      # Provide Mend License and accept Terms of Service
      - MEND_RNV_ACCEPT_TOS # Set to 'y' to accept the Mend Renovate Terms of Service
      - MEND_RNV_LICENSE_KEY # Set this to the key you received by email
      # Provide connection details for the GitLab Bot
      - MEND_RNV_PLATFORM=gitlab
      - MEND_RNV_ENDPOINT # GitLab endpoint, include trailing slash
      - MEND_RNV_GITLAB_PAT # Personal Access Token for bot account
      - MEND_RNV_WEBHOOK_SECRET # Optional: defaults to 'renovate'
      # Optional settings for Mend Renovate
      # - MEND_RNV_ADMIN_API_ENABLED # Optional: Set to 'true' to enable Admin APIs. Defaults to 'false'.
      # - MEND_RNV_SERVER_API_SECRET # Required if Admin APIs are enabled
      # - MEND_RNV_SQLITE_FILE_PATH=/db/renovate-ce.sqlite # Optional: Provide a path to persist the database. Needs 'db' volume defined (below).
      # - MEND_RNV_CRON_JOB_SCHEDULER # Optional Job enqueue schedule: defaults to '0 * * * *' (hourly, on the hour)
      # - MEND_RNV_CRON_APP_SYNC # Optional AppSync schedule: defaults to '0 0,4,8,12,16,20 * * *' (every 4 hours, on the hour)
      # Core Renovate settings
      # - GITHUB_COM_TOKEN # Personal Access Token for github.com (used for retrieving changelogs)
    ports:
      - "80:8080" # Receive webhooks on port 80
    # volumes:
      # Optional: You can use a file mount to persist the database between sessions
      # - "/tmp/db/:/db/" # Unix-style file mounting for the db
      # - "C:\\tmp/db/:/db/" # Windows-style file mounting for the db
```
