# Mend Renovate Self-hosted App Configuration Options

Mend Renovate Enterprise Edition runs with one or more **_Server_** containers and one or more **_Worker_** containers.
Mend Renovate Community Edition runs on a single Server container that also performs the Worker actions. 
See below for a list of environment variables that relate to each.

Separately, you can provide configuration for the Renovate Core. See the end of this doc for details.

## Contents

<!-- TOC -->
* [Environment variables for Community Edition and Enterprise Server](#environment-variables-for-community-edition-and-enterprise-server)
  * [Mend Licensing Config](#mend-licensing-config)
  * [Connection to the Source Code Management (SCM)](#connection-to-the-source-code-management-scm)
    * [GitHub connection variables](#github-connection-variables)
    * [GitLab connection variables](#gitlab-connection-variables)
    * [Bitbucket connection variables](#bitbucket-connection-variables)
  * [Server Config Options](#server-config-options)
  * [SSL/TLS Communication (Secure HTTPS)](#ssltls-communication-secure-https)
  * [Local Database Configuration](#local-database-configuration)
  * [Startup and Sync behavior](#startup-and-sync-behavior)
  * [Job Scheduling Options](#job-scheduling-options)
  * [Logging Configuration Options](#logging-configuration-options)
  * [Other Server Config Options](#other-server-config-options)
  * [Postgres DB Configuration](#postgres-db-configuration)
* [Environment variables for Enterprise Worker](#environment-variables-for-enterprise-worker)
  * [Mandatory Worker config](#mandatory-worker-config)
  * [Optional Worker config](#optional-worker-config)
* [Configure Renovate Core](#configure-renovate-core)
<!-- TOC -->

## Environment variables for Community Edition and Enterprise Server

The following environment variables apply to **Mend Renovate Community Edition** and the **Mend Renovate Enterprise Edition Server**.
Environment variables for the **Mend Renovate Enterprise Worker** are in the next section.

### Mend Licensing Config

**`MEND_RNV_ACCEPT_TOS`**: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

**`MEND_RNV_LICENSE_KEY`**: Provide a valid license key for Renovate Community Edition or Enterprise Edition

> [!Note]
>
> To run Renovate Community Edition with **up to 10 repositories**, you can use this unregistered license key:
>
> `eyJsaW1pdCI6IjEwIn0=.30440220457941b71ea8eb345c729031718b692169f0ce2cf020095fd328812f4d7d5bc1022022648d1a29e71d486f89f27bdc8754dfd6df0ddda64a23155000a61a105da2a1`
>
> For a free license key for an **unrestricted number of repositories** on Renovate Community Edition, register with the form on the [Renovate Community Edition web page](https://www.mend.io/mend-renovate-community/).
>
> For an Enterprise license key, contact Mend at http://mend.io.

**`MEND_RNV_MC_TOKEN`**: [Enterprise only] The authentication token required when using Merge Confidence Workflows. Set this to 'auto' (default), or provide the value of a merge confidence API token.

### Connection to the Source Code Management (SCM)

This section contains configuration variables for connecting to your source code repository.
Use the appropriate settings to define connection details to your specific SCM.

**`MEND_RNV_PLATFORM`**: The type of SCM. Options: `github`, `gitlab`, `bitbucket-server`.

**`MEND_RNV_ENDPOINT`**: This is the API endpoint for your SCM. Not required for GitHub.com. Include the trailing slash.

#### GitHub connection variables

**`MEND_RNV_GITHUB_APP_ID`**: The GitHub App ID of the provisioned Renovate app on GitHub.

**`MEND_RNV_GITHUB_APP_KEY`**: A string representation of the private key of the provisioned Renovate app on GitHub. To insert the value directly into a Docker Compose environment variable, open the PEM file in a text editor and replace all new lines with "\n" so that the entire key is on one line. Alternatively, you can skip setting this key as an environment variable and instead mount it as a file to the path specified by `MEND_RNV_GITHUB_PEM_FILE_PATH`, as shown in the example Docker Compose file.

**`MEND_RNV_GITHUB_PEM_FILE_PATH`**: The file path for GitHub app key. Defaults to `/usr/src/app/renovate.private-key.pem`.

**`MEND_RNV_GITHUB_BOT_USER_ID`**: Optional: The bot user ID that will be used in `gitAuthor` (example author `myBotName[bot] <123456+myBotName[bot]@users.noreply.github.com` and the user id is `123456`). The value can be found by calling `https://api.github.com/users/{appName}[bot]` under the `id` key (replace the `{appName}` with the actual app name).
Note: By default Renovate server will attempt to call this endpoint once during startup (both CE and EE server) and it does not require authentication. If you wish to skip this call for any reason you will need to provide the value in `MEND_RNV_GITHUB_BOT_USER_ID=<id-number>`

#### GitLab connection variables

**`MEND_RNV_GITLAB_PAT`**: Personal Access Token for the GitLab bot account.

#### Bitbucket connection variables

**`MEND_RNV_BITBUCKET_USER`**: Renovate Bot user account (“Bitbucket User” access only)

**`MEND_RNV_BITBUCKET_PAT`**: BitBucket access token for the bot user `MEND_RNV_BITBUCKET_USER`

### Server Config Options

**`GITHUB_COM_TOKEN`**: A Personal Access Token for a user account on github.com (i.e. _not_ an account on your GitHub Enterprise instance).
This is used for retrieving changelogs and release notes from repositories hosted on github.com and it does not matter who it belongs to.
It needs only read-only access privileges. Not required if SCM is GitHub.com.

**`MEND_RNV_WEBHOOK_SECRET`**: Optional: Defaults to `renovate`

**`MEND_RNV_WEBHOOK_URL`**: [GitLab, Bitbucket Data Center only] Optional.
When set, webhooks will be installed on repos when Renovate is enabled.
The URL of the Renovate Server plus '/webhook'. (e.g. `http://renovate.yourcompany.com:8080/webhook` or `https://1.2.3.4/webhook`)
Must be accessible to receive incoming calls from the BitBucket Data Center.

** `MEND_RNV_WEBHOOK_BASE_BRANCHES`: Optional: Set to add values to the default base branches list that are considered for webhook evens (default list: `['master', 'main', 'develop']`)

** `MEND_RNV_WEBHOOK_BRANCH_PREFIXES`: Optional: Set to add values to the default Renovate branches list that are considered for webhook evens (default list: `['renovate/']`)

** `MEND_RNV_WEBHOOK_DISABLED_REPOS_HANDLING`: allows reduced number of jobs from incoming webhook events by skipping jobs for `disabled` repositories 

values:
- `minimal` (default) when a repository's last run result is `disabled`, only trigger jobs for push/commit webhook event affecting a base branch and include a Renovate config in the list of changed files  
- `full`: trigger jobs for any "importatn" webhook even if the repository is `disabled`

Notes: 
- Bitbucket webhook event does not include the list of changed files. 
- To trigger a job for a `disabled` repository in case webhook events are not an option:
  - wait for `MEND_RNV_CRON_JOB_SCHEDULER_ALL` (it adds jobs for all repositories including `disabled` ones)
  - use `POST /system/v1/jobs/add` to trigger a job
  - use `POST /api/v1/repos/{org}/{repo}/-/jobs/run` to trigger a job
  

**`MEND_RNV_SYNC_MODE`**: [GitHub only] Performance tuning for the App Sync operation. Set to 'batch' for orgs with very large numbers of repos.

values:
- `bulk` (default) - will process all repos in one operation
- `batch` - will process repos in smaller batches



**`MEND_RNV_ADMIN_TOKEN`**: [GitLab, Bitbucket Data Center only] Optional: A token used for searching/add/removing repository webhooks.
Defaults to the primary Renovate user PAT when not provided in GitLab config.
Important: Webhooks will be only installed on repos that the account has at least `Maintainer` access to.

** `MEND_RNV_API_ENABLED`: Optional: Set to 'true' to enable System, Jobs, and Reporting [APIs](./api.md). Defaults to 'false'. (renamed from `MEND_RNV_ADMIN_API_ENABLED`)

**`MEND_RNV_API_SERVER_SECRET`**: [Required if APIs enabled. Required on Renovate Enterprise Server] Set an API secret. Must match the Worker instances and Admin APIs for communicating with the Server. (renamed from `MEND_RNV_SERVER_API_SECRET`)

**`MEND_RNV_API_ENABLE_PROMETHEUS_METRICS`**: Optional: Set to 'true' to enable Prometheus `/metrics` endpoint. Defaults to 'false'. (renamed from `MEND_RNV_PROMETHEUS_METRICS_ENABLED`)

**`MEND_RNV_API_ENABLE_SYSTEM`**: Optional: Set to 'true' to enable [System APIs](./api-system.md). Defaults to 'false'. (backward compatibility with `MEND_RNV_ADMIN_API_ENABLED`)

**`MEND_RNV_API_ENABLE_JOBS`**: Optional: Set to 'true' to enable [Jobs APIs](./api-jobs.md). Defaults to 'false'. (backward compatibility with `MEND_RNV_ADMIN_API_ENABLED`)

**`MEND_RNV_API_ENABLE_REPORTING`**: Optional: Set to 'true' to enable [Reporting APIs](./api-reporting.md). Defaults to 'false'. (backward compatibility with `MEND_RNV_ADMIN_API_ENABLED`)

**`MEND_RNV_REQUEST_LOGGER_ENABLED`**: Optional: Set to 'true' to output the details of all incoming API requests to DEBUG logger. Defaults to 'false'.

**`MEND_RNV_DEBUG_MODE`**: Optional: Set to 'true' to display full configuration details in DEBUG logs. Defaults to 'false'. **WARNING: Will display secrets in plain text.**

**`MEND_RNV_REPORTING_ENABLED`**: [Enterprise Only. From v7.0.0] Optional: Set to 'true' to enable Reporting APIs. Defaults to 'false'.

**`MEND_RNV_SERVER_PORT`**: The port on which the server listens for webhooks and api requests. Defaults to 8080.

### SSL/TLS Communication (Secure HTTPS)

Note: For more information about TLS configuration, see separate docs for [TLS communication](tls.md).

**`MEND_RNV_SERVER_HTTPS_PORT`**: Required for secure communication. Defaults to 8443. Note: Ensure `MEND_RNV_SERVER_HOSTNAME` is updated in Worker (eg. https://rnv-ee-server:8443).

**`MEND_RNV_HTTP_SERVER_DISABLED`**: Set to 'true' to ensure that non-secure requests are rejected.

**`MEND_RNV_SERVER_HTTPS_CONFIG`**: TLS server config (JSON format). Takes precedence over `MEND_RNV_SERVER_HTTPS_CONFIG_PATH`. 

**`MEND_RNV_SERVER_HTTPS_CONFIG_PATH`**: File for defining TLS server config. Note: Ensure volume is defined.

**`MEND_RNV_CLIENT_HTTPS_CONFIG`**: TLS client config (JSON format). Takes precedence over `MEND_RNV_CLIENT_HTTPS_CONFIG_PATH`.

**`MEND_RNV_CLIENT_HTTPS_CONFIG_PATH`**: File for defining TLS client config. Note: Ensure volume is defined.

### Local Database Configuration

**`MEND_RNV_SQLITE_FILE_PATH`**: Defaults to '/tmp/database.sqlite'. Optional: Provide a path to persist the database. (eg. '/db/renovate-ce.sqlite', where 'db' is defined as a volume)

> [!IMPORTANT]  
> The container running either the Renovate EE server service or the Renovate CE service requires read, write, and execute (rwx) permissions for the parent folder of the SQLite file. 
> Additionally, the process inside the container executes with `uid=12021` (ubuntu) and `gid=12021`.

> [!NOTE]
> In versions before `v9`, the process executed with `uid=1000` (node) and `gid=1000`.

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

### Startup and Sync behavior

> [!IMPORTANT]
> 
> When running Renovate Enterprise with multiple Server instances, unpredictable behavior can occur when more than one server attempts to sync repos or enqueue jobs.
> Therefore, it is recommended NOT to run App Sync or to enqueue jobs when the server starts, and instead to rely on the primary server to perform these tasks when the related cron jobs are triggered.
> 
> **Recommended settings when running with multiple Server instances:**
> - Set `MEND_RNV_SYNC_ON_STARTUP` = false
> - Set `MEND_RNV_ENQUEUE_JOBS_ON_STARTUP` = disabled

**`MEND_RNV_SYNC_ON_STARTUP`**: Defines if App Sync will be performed when the server starts. Defaults to `true`.

Note: This should be set to `false` when running multiple Server instances.

**`MEND_RNV_SYNC_MODE`**: [GitHub only] Performance tuning for the App Sync operation. Set to 'batch' for orgs with very large numbers of repos.

values:
- `bulk` (default) - will process all repos in one operation
- `batch` - will process repos in smaller batches

**`MEND_RNV_CRON_APP_SYNC`**: Optional: Accepts a 5-part cron schedule. Defaults to `0 0,4,8,12,16,20 * * *` (every 4 hours, on the hour). This cron job performs autodiscovery against the platform and fills the SQLite database with projects.

**`MEND_RNV_ENQUEUE_JOBS_ON_STARTUP`**: The job enqueue behavior on start (or restart). Defaults to `discovered`. (Note that the behavior can be different if the database is persisted or not)
- `enabled`: enqueue a job for all available repositories
- `discovered`: enqueue a job only for newly discovered repositories
- `disabled`: No jobs are enqueued

Note: This should be set to `disabled` when running multiple Server instances.

**`MEND_RNV_AUTODISCOVER_FILTER`**: Accepts a comma-separated string of minimatch-compatible globs or RE2-compatible regular expressions, following the same input format as Renovate’s `autodiscoverFilter`. For examples and full documentation, see the [Renovate autodiscoverFilter docs](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter).

> [!WARNING]  
> The Renovate CLI [autodiscover](https://docs.renovatebot.com/self-hosted-configuration/#autodiscover) configuration option is disabled at the client level. Repository filtering should solely rely on server-side filtering using `MEND_RNV_AUTODISCOVER_FILTER`.

> [!IMPORTANT]
> Do not use commas inside individual filters, commas are treated as delimiters between filters.

### Job Scheduling Options

> [!IMPORTANT]  
> Job scheduling options are different between Community Edition and Enterprise Edition.
> 
> **Renovate Enterprise Edition** allows job scheduling to be customized so that active repos run more frequently and stale repos run less often.
> The Enterprise job schedulers are:
> - `MEND_RNV_CRON_JOB_SCHEDULER_HOT` (Default Hourly - Active repos: new, activated)
> - `MEND_RNV_CRON_JOB_SCHEDULER_COLD` (Default Daily - Semi-active repos: onboarded, onboarding, failed)
> - `MEND_RNV_CRON_JOB_SCHEDULER_CAPPED` (Default Weekly - Blocked repos: resource-limit, timeout)
> - `MEND_RNV_CRON_JOB_SCHEDULER_ALL` (Default Monthly - All enabled repos: not disabled)
> 
> **Renovate Community Edition** has a single job scheduler that runs against all repos, regardless of their repo state.
> - `MEND_RNV_CRON_JOB_SCHEDULER_ALL` (Default Hourly - All repos)
> 
> See below for details

> [!Note]
> 
> `MEND_RNV_CRON_JOB_SCHEDULER` is deprecated from v7.3.0.
> - For Renovate Community Edition: use `MEND_RNV_CRON_JOB_SCHEDULER_ALL` (see below)
> - For Renovate Enterprise Edition: use `MEND_RNV_CRON_JOB_SCHEDULER_HOT` (see below)

**`MEND_RNV_CRON_JOB_SCHEDULER_HOT`**: [Enterprise Only] Runs all activate and new repositories. Defaults to hourly (0 * * * *)
  * Runs repos with status: `new`, `activated`
 
Note: An `activated` repository is one that has onboarded and also accepted at least one Renovate PR.

Note: This option overrides the deprecated MEND_RNV_CRON_JOB_SCHEDULER flag.

**`MEND_RNV_CRON_JOB_SCHEDULER_COLD`**: [Enterprise Only] Runs all semi-active repositories. Defaults to daily (10 0 * * *)
* Runs repos with status: `onboarded`, `onboarding`, `failed`

**`MEND_RNV_CRON_JOB_SCHEDULER_CAPPED`**: [Enterprise Only] Runs all repositories that are blocked. Defaults to weekly (20 0 * * 0)
* Runs repos with status: `resource-limit`, `timeout`

**`MEND_RNV_CRON_JOB_SCHEDULER_ALL`**: Runs jobs for all enabled repositories.
  * Runs repos: ALL enabled repos (including repos that fall into HOT, COLD, and CAPPED statuses)
  * Does not run on repos that are `disabled`
  * Defaults to hourly (0 * * * *) for Community Edition and monthly (30 0 1 * *) for Enterprise Edition

Note: For CE this option overrides the deprecated `MEND_RNV_CRON_JOB_SCHEDULER` flag.

### Logging Configuration Options

**`MEND_RNV_LOG_HISTORY_DIR`**: Optional. Specify a directory path to save Renovate job log files. Defaults to `/tmp/renovate`.

Log files will be saved in a `./ORG_NAME/REPO_NAME/` hierarchy under the specified folder. Log file name structure is as follows: `(<timestamp>_<log_context>.log)`

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

Note: 
- Recommended to be an external volume to preserve history between multiple workers
- For disk cleanup use `MEND_RNV_LOG_HISTORY_TTL_DAYS` and `MEND_RNV_LOG_HISTORY_CLEANUP_CRON`

**`MEND_RNV_LOG_HISTORY_S3`**: Optional. Format: `s3://bucket/dir1/dir2`. Defines S3 storage location for saving job logs. Supports connection to AWS or MinIO S3 storage.
Uses standard AWS environment variables to establish connection. (Also see `MEND_RNV_S3_FORCE_PATH_STYLE`.)

**`MEND_RNV_S3_FORCE_PATH_STYLE`**: Optional. Set to 'true' if the endpoint for your S3 storage must be used without manipulation - eg. connecting to MinIO S3. Defaults to 'false'. (See `MEND_RNV_LOG_HISTORY_S3`)

**`MEND_RNV_LOG_HISTORY_TTL_DAYS`**: Optional: The number of days to save log files. Defaults to 30.

**`MEND_RNV_LOG_HISTORY_CLEANUP_CRON`**: Optional: Specifies a 5-part cron schedule. Defaults to `0 0 * * *` (every midnight). This cron job cleans up log history in the directory defined by `MEND_RNV_LOG_HISTORY_DIR`. It deletes any log file older than `MEND_RNV_LOG_HISTORY_TTL_DAYS`.

> [!IMPORTANT]  
> Logs are saved by the Renovate OSS cli, so the corresponding folder must exist in the CE/EE-Worker container.

### Other Server Config Options

**`MEND_RNV_WORKER_CLEANUP`**: [from v7.0.0] Optional. Defines how often to perform file cleanup on Worker containers. Defaults to "off".

Values:
- `off` - no cleanup is preformed
- `always` - cleanup is done after every job completion.
- (cron schedule) - all other values will be treated as a cron time. If it is invalid, the service will shut down. Otherwise, a cron scheduler will run at the specified intervals.<br>
  e.g. `MEND_RNV_WORKER_CLEANUP="0 0 * * *"` will perform cleanup daily at midnight.

**`MEND_RNV_WORKER_CLEANUP_DIRS`**: [From v7.0.0] Optional. Comma separated list of directories to clean during Worker cleanup (see `MEND_RNV_WORKER_CLEANUP`)

By default, all files within these folders that were created _after_ the worker/CE booted will be removed.
```
/opt/containerbase
/tmp/renovate/cache
/tmp/renovate/repos
/home/ubuntu
```

Note: Setting this variable will **_replace_** the default list of directories. To add a directory to the existing default list, you must include all the default folders in the new value.

**`MEND_RNV_VERSION_CHECK_INTERVAL`**: [Enterprise only] Escalation period (minutes) for mismatching Server/Worker versions. Defaults to 60.

When an API call is received by the Server, it compares the version of the Worker that sent the request. If the Server and Worker have different versions, a message will be logged to the Server console.

```
INFO: Mismatching versions of Server XXX and Worker YYY
```

Only one message will be printed during the version check interval. If mismatches continue to occur after the interval, the log messages will escalate from INFO to WARN and ERROR.
Escalation is reset when no mismatching versions are found during the version check interval.

Note: You can inspect the `Renovate-EE-Version` in the response header of any Renovate API call to see the current version of the responding Server. 

**`MEND_RNV_FORK_PROCESSING`**: controls the value of Renovate `forkProcessing` in the worker. valid values

- `disabled`: sets Renovate `forkProcessing=disabled` for all jobs
- `enabled`: sets Renovate `forkProcessing=enabled` for all jobs
- unset: `forkProcessing` will not be set by the server (Renovate CLI defaults to forkProcessing=auto)  *default value*
- `managed`: value per platform
  - for GitHub the value will be decided based on repository selection value for each installation
    - `forkProcessing=enabled` if "Selected repositories"
    - `forkProcessing=disabled` if "All repositories"
  - others platforms: `forkProcessing=disabled`

**`MEND_RNV_MERGE_CONFIDENCE_ENDPOINT`**: [Enterprise only] defines the endpoint used to retrieve Merge Confidence data by querying this API. 
this config option only need to be defined in the server, and it will be passed to the worker automatically. 
defaults to https://developer.mend.io/.

Notes: This option overrides the deprecated `RENOVATE_X_MERGE_CONFIDENCE_API_BASE_URL` flag.

**`MEND_RNV_DISABLE_GLOBAL_AGENT`**: Disable the use of GlobalProxyAgent. Defaults to `false`.

**`MEND_RNV_ENABLE_HTTP2`**: Enable got HTTP/2 support. Defaults to `false`.


### Postgres DB Configuration

To configure Mend Renovate to use a PostgreSQL database, the following environment variables should be supplied to the Server containers (not required for Worker environment config).

For more information, see the [Postgres DB Configuration](configure-postgres-db.md) documentation.

* **`MEND_RNV_DATA_HANDLER_TYPE`**: Set to ‘postgresql’ to use a PostgreSQL database
* **`MEND_RNV_POSTGRES_SSL_PEM_PATH`**: The `.pem` file location in the container for SSL connection
* **`PGDATABASE`**: Name of the database instance. Eg. ‘postgres’
* **`PGUSER`**: Postgres User name. Must have Create Schema permission.
* **`PGPASSWORD`**: Postgres User password
* **`PGHOST`**: Host name of the PostgreSQL instance
* **`PGPORT`**: Host Port for the PostgreSQL instance

## Environment variables for Enterprise Worker

The following variables apply to Worker containers (Renovate Enterprise only):

### Mandatory Worker config

* **`MEND_RNV_SERVER_HOSTNAME`**: The hostname of the Renovate Enterprise `server` container (eg. http://renovate-ee-server:8080)
* **`MEND_RNV_SERVER_API_SECRET`**: Set to same as Server
* **`MEND_RNV_ACCEPT_TOS`**: Set to same as Server
* **`MEND_RNV_LICENSE_KEY`**: Set to same as Server

### Optional Worker config

* **`MEND_RNV_DEBUG_MODE`**: Set to 'true' to display full configuration details in DEBUG logs. Defaults to 'false'. **WARNING: Will display secrets in plain text.**
* **`MEND_RNV_WORKER_EXECUTION_TIMEOUT`**: Sets the maximum execution duration of a Renovate CLI scan in minutes. Defaults to 60.
* **`MEND_RNV_DISK_USAGE_WARN_THRESHOLD`**: A numeric percentage threshold for disk storage warnings. The default is 70. This feature will execute `df --output=source,pcent` after each completed job, match sources based on the set filter, and log a warning for each source that exceeds the threshold.
* **`MEND_RNV_DISK_USAGE_FILTER`**: A comma-separated list of regex or glob patterns for matching device paths. Default is `/dev/**`. The glob/regex filter behaves similarly to [autodiscoverFilter](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter).
* **`MEND_RNV_SINGLE_JOB_WORKER`**: When set to 'true', a Worker machine will make exactly one attempt to fetch and run a job and then shut down. To be used by KEDA to scale jobs; not intended for use with standard Docker pods. Default is 'false'.
* **`MEND_RNV_DISABLE_GLOBAL_AGENT`**: Disable the use of GlobalProxyAgent. Defaults to `false`.
* **`MEND_RNV_ENABLE_HTTP2`**: Enable got HTTP/2 support. Defaults to `false`.
* **`MEND_RNV_CLIENT_HTTPS_CONFIG`**: TLS client config (JSON format). Takes precedence over `MEND_RNV_CLIENT_HTTPS_CONFIG_PATH`.
* **`MEND_RNV_CLIENT_HTTPS_CONFIG_PATH`**: File for defining TLS client config. Note: Ensure volume is defined.
* **`MEND_RNV_NODE_OPTIONS`**: Defines `NODE_OPTIONS` for the `Node.js` runtime

## Configure Renovate Core

The core Renovate OSS functionality can be configured using environment variables (e.g. `RENOVATE_XXXXXX`) or via a `config.js` file that you mount inside the Mend Renovate container to `/usr/src/app/config.js`. Both settings should be done in the worker.

**npm Registry** If using your own npm registry, you may find it easiest to update your Docker Compose file to include a volume that maps an `.npmrc` file to `/home/ubuntu/.npmrc`. The RC file should contain `registry=...` with the registry URL your company uses internally. This will allow Renovate to find shared configs and other internally published packages.
