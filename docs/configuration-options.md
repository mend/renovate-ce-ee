# Mend Renovate Configuration Options

## Configure Mend Renovate

Mend Renovate Enterprise Edition runs with one or more **_Server_** containers and one or more **_Worker_** containers.
Mend Renovate Community Edition runs on a single Server container that also performs the Worker actions. 
See below for a list of environment variables that relate to each.

### Environment variables for Community Edition and Enterprise Server

The following environment variables apply to **Mend Renovate Community Edition** and the **Mend Renovate Enterprise Edition Server**.<br/>
Environment variables for the **Mend Renovate Enterprise Worker** are in the next section.

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: For a Renovate Enterprise license key, contact Mend via the [Renovate Enterprise webpage](https://www.mend.io/renovate-enterprise/).

**`MEND_RNV_PLATFORM`**: Set this to `github`.

**`MEND_RNV_ENDPOINT`**: This is the API endpoint for your GitHub Enterprise installation. Required for GitHub Enterprise Server; not for GitHub.com. Include the trailing slash.

**`MEND_RNV_GITHUB_APP_ID`**: The GitHub App ID of the provisioned Renovate app on GitHub.

**`MEND_RNV_GITHUB_APP_KEY`**: A string representation of the private key of the provisioned Renovate app on GitHub. To insert the value directly into a Docker Compose environment variable, open the PEM file in a text editor and replace all new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to the path specified by `RNV_GITHUB_PEM_FILE_PATH`, as shown in the example Docker Compose file.

**`RNV_GITHUB_PEM_FILE_PATH`**: The file path for GitHub app key. Defaults to `/usr/src/app/renovate.private-key.pem`.

**`MEND_RNV_WEBHOOK_SECRET`**: Optional: Defaults to `renovate`

**`MEND_RNV_SERVER_API_SECRET`**: Set an API secret. Must match the Worker instances and Admin APIs for communicating with the Server.

**`MEND_RNV_ADMIN_API_ENABLED`**: Optional: Set to 'true' to enable Admin APIs. Defaults to 'false'.

**`MEND_RNV_SERVER_PORT`**: The port on which the server listens for webhooks and api requests. Defaults to 8080.

**`MEND_RNV_SQLITE_FILE_PATH`**: Optional: Provide a path to persist the database. (eg. '/db/renovate-ce.sqlite', where 'db' is defined as a volume)

> [!IMPORTANT]  
> The container running the Renovate EE server service requires read, write, and execute (rwx) permissions for the parent folder of the SQLite file. Additionally, the process inside the container executes with uid=1000 (node) and gid=1000 (node).

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

**`MEND_RNV_CRON_JOB_SCHEDULER`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 * * * *` (i.e. once per hour exactly on the hour). This cron job triggers the Renovate bot against the projects in the SQLite database. If decreasing the interval then be careful that you do not exhaust the available hourly rate limit of the app on GitHub server or cause too much load.

**`MEND_RNV_CRON_APP_SYNC`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 0,4,8,12,16,20 \* \* \*` (every 4 hours, on the hour). This cron job performs autodiscovery against the platform and fills the SQLite database with projects.

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. _not_ an account on your GitHub Enterprise instance). This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to. It needs only read-only access privileges. Note: This is required if you are using a self-hosted GitHub Enterprise instance but should not be configured if your `RENOVATE_ENDPOINT` is `https://api.github.com`.

**`MEND_RNV_AUTODISCOVER_FILTER`**: a string of a comma separated values (e.g. `org1/*, org2/test*, org2/test*`). Same behavior as Renovate [autodiscoverFilter](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter)

> [!WARNING]  
> The Renovate CLI [autodiscover](https://docs.renovatebot.com/self-hosted-configuration/#autodiscover) configuration option is disabled at the client level. Repository filtering should solely rely on server-side filtering using `MEND_RNV_AUTODISCOVER_FILTER`.

**`MEND_RNV_ENQUEUE_JOBS_ON_STARTUP`**: The job enqueue behavior on start (or restart). Defaults to `discovered`. (Note that the behavior can be different if the database is persisted or not)
- `enabled`: enqueue a job for all available repositories
- `discovered`: enqueue a job only for newly discovered repositories
- `disabled`: No jobs are enqueued

**`MEND_RNV_MC_TOKEN`**: The merge confidence token used for Smart-Merge-Control authentication

**`MEND_RNV_LOG_HISTORY_DIR`**: Optional: Specify a directory path to save Renovate job log files, recommended to be an external volume to preserve history between multiple workers. Log files will be saved in a `./ORG_NAME/REPO_NAME/` hierarchy under the specified folder. Log file name structure is as follows: `(<timestamp>_<log_context>.log)`.

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

**`MEND_RNV_LOG_HISTORY_TTL_DAYS`**: Optional: The number of days to save log files. Defaults to 30.

**`MEND_RNV_LOG_HISTORY_CLEANUP_CRON`**: Optional: Specifies a 5-part cron schedule. Defaults to `0 0 * * *` (every midnight). This cron job cleans up log history in the directory defined by `MEND_RNV_LOG_HISTORY_DIR`. It deletes any log file that exceeds the `MEND_RNV_LOG_HISTORY_TTL_DAYS` value.

> [!IMPORTANT]  
> Logs are saved by the Renovate OSS cli, so the corresponding folder must exist in the CE/EE-Worker container.

### Environment variables for Enterprise Worker

The Worker container needs to define only the following variables:

* **`MEND_RNV_SERVER_HOSTNAME`**: The hostname of the Renovate Enterprise `server` container (eg. http://renovate-ee-server:8080)
* **`MEND_RNV_SERVER_API_SECRET`**: Set to same as Server
* **`MEND_RNV_ACCEPT_TOS`**: Set to same as Server
* **`MEND_RNV_LICENSE_KEY`**: Set to same as Server
* **`MEND_RNV_WORKER_EXECUTION_TIMEOUT`**: Optional: Sets the maximum execution duration of a Renovate CLI scan in minutes. Defaults to 60.

## Configure Renovate Core

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Mend Renovate container to `/usr/src/app/config.js`. Both settings should be done in the worker.

**npm Registry** If using your own npm registry, you may find it easiest to update your Docker Compose file to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.