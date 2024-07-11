# Configuration - Mend Renovate CE/EE for Bitbucket Server


# Table of Content
* [Available Renovate CE/EE Configurations](#available_config)
* [Installation Stages](#stages)
  * [Stage 1: Configure Renovate Bot account on Bitbucket Server](#stg_1)
    * [1a: Create a Renovate Bot user account (“Bitbucket User” access only)](#stg_1a)
    * [1b: Fetch an HTTP Access Token for the Renovate Bot user (Project Read, Repo Write)](#stg_1b)
  * [Stage 2: Install Renovate CE/EE application server (Docker-compose or Kubernetes)](#stg_2)
  * [Stage 3: Install Renovate Bot and Webhooks on BitBucket project or repository](#stg_3)
    * [3a: Install the Renovate Bot on Repositories](#stg_3a)
    * [3b: Add Webhooks to Repositories(/Projects)](#stg_3b)

<a id="available_config"></a>
# Available Configurations for CE/EE

`MEND_RNV_ACCEPT_TOS`: Set this environment variable to `y` to consent to [Mend's Terms of Service](https://www.mend.io/terms-of-service/).

`MEND_RNV_LICENSE_KEY`: This should be the license key you obtained after registering at [https://www.mend.io/renovate-community/](https://www.mend.io/renovate-community/).

`MEND_RNV_PLATFORM`: Set this to `bitbucket-server`.

`MEND_RNV_ENDPOINT`: This is the API endpoint for your BitBucket Server installation.

`MEND_RNV_BITBUCKET_USER`: Renovate Bot user account (“Bitbucket User” access only)

`MEND_RNV_BITBUCKET_PAT`: BitBucket access token for the bot user `MEND_RNV_BITBUCKET_USER`

`MEND_RNV_WEBHOOK_SECRET`: Optional: Defaults to `renovate`

`MEND_RNV_WEBHOOK_URL`: Optional: The URL of the Renovate Server plus `/webhook`. Must be accessible to receive incoming calls from the BitBucket server.

`MEND_RNV_ADMIN_TOKEN`: Optional: A token used for searching/add/removing repository webhooks. required if `MEND_RNV_WEBHOOK_URL` is set.

`MEND_RNV_ADMIN_API_ENABLED`: Optional: Set to `true` to enable Admin APIs. Defaults to `false`.

`MEND_RNV_SERVER_API_SECRET`: Required if Admin APIs are enabled.

`MEND_RNV_SERVER_PORT`: The port on which the server listens for webhooks and api requests. Defaults to 8080.

`MEND_RNV_CRON_JOB_SCHEDULER`: Optional: Accepts a 5-part cron schedule. Defaults to `0 * * * *` (i.e. once per hour exactly on the hour). This cron job triggers the Renovate bot against the projects in the SQLite database. If decreasing the interval then be careful that you do not exhaust the available hourly rate limit of the app on GitHub server or cause too much load.

`MEND_RNV_CRON_APP_SYNC`: Optional: Accepts a 5-part cron schedule. Defaults to `0 0,4,8,12,16,20 * * *` (every 4 hours, on the hour). This cron job performs autodiscovery against the platform and fills the SQLite database with projects.

`MEND_RNV_WORKER_EXECUTION_TIMEOUT`: Optional: Sets the maximum execution duration of a Renovate CLI scan in minutes. Defaults to 60.

`MEND_RNV_AUTODISCOVER_FILTER`: a string of a comma separated values. (e.g. `org1/*, org2/test*, org2/test*`). Same behavior as Renovate [autodiscoverFilter](https://docs.renovatebot.com/self-hosted-configuration/#autodiscoverfilter)

> [!WARNING]  
> The Renovate CLI [autodiscover](https://docs.renovatebot.com/self-hosted-configuration/#autodiscover) configuration option is disabled at the client level. Repository filtering should solely rely on server-side filtering using `MEND_RNV_AUTODISCOVER_FILTER`.

`MEND_RNV_ENQUEUE_JOBS_ON_STARTUP`: The job enqueue behavior on start (or restart). Defaults to `discovered`. (Note that the behavior can be different if the database is persisted or not)
- `enabled`: enqueue a job for all available repositories
- `discovered`: enqueue a job only for newly discovered repositories
- `disabled`: No jobs are enqueued

`MEND_RNV_SQLITE_FILE_PATH`: Optional: Provide a path to persist the database. (eg. '/db/renovate-ce.sqlite', where 'db' is defined as a volume)

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

`MEND_RNV_LOG_HISTORY_DIR`: Optional: Specify a directory path to save Renovate job log files, recommended to be an external volume to preserve history. Log files will be saved in a `./ORG_NAME/REPO_NAME/` hierarchy under the specified folder. Log file name structure is as follows: `(<timestamp>_<log_context>.log)`.

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
> Note for EE: Logs are saved by the workers but clean is done by the server, so the corresponding folder must be shared between the Worker and Server containers.

`MEND_RNV_LOG_HISTORY_TTL_DAYS`: Optional: The number of days to save log files. Defaults to 30.

`MEND_RNV_LOG_HISTORY_CLEANUP_CRON`: Optional: Specifies a 5-part cron schedule. Defaults to `0 0 * * *` (every midnight). This cron job cleans up log history in the directory defined by `MEND_RNV_LOG_HISTORY_DIR`. It deletes any log file that exceeds the `MEND_RNV_LOG_HISTORY_TTL_DAYS` value.

`MEND_RNV_MC_TOKEN` _(EE only)_: The merge confidence token used for Smart-Merge-Control authentication

<a id="stages"></a>
# Installation Stages

<a id="stg_1"></a>
## Stage 1

<a id="stg_1a"></a>
### 1.a. Configure Renovate Bot User Account

The following configuration instructions are to be performed on Bitbucket Server by a user account with “Admin” or “System admin” global permissions on the Bitbucket Server.

- Log in to Bitbucket Server with admin user (eg. http://localhost:7990)<br>
Note: Bitbucket Admin user permissions - Must be at least “Admin” to create a new user account.<br>
Also, only repo admins can add the Renovate Bot user and webhooks.

- Navigate to the User settings page in Administration (Settings → Accounts/Users)<br>
eg. http://localhost:7990/admin/users

![bb-admin-users.png](images%2Fbb-admin-users.png)

- Click “Create user” to create an account for the Renovate Bot user.  (eg. http://localhost:7990/admin/users?create)

We recommend calling the account “Renovate Bot”.
- Username: “renovate-bot”
- Full name: “Renovate Bot”

![bb-create-user.png](images%2Fbb-create-user.png)

- Note: The Renovate Bot user will be the author of Renovate pull requests.

![bb-renovate-bot.png](images%2Fbb-renovate-bot.png)

- Give the Renovate Bot user basic Bitbucket user access (only required so a HTTP Token can be created through the UI)
  - Under Global permissions, in the User Access section, click into the table header bar (where it says “Add Users”) and search for the Renovate Bot user.
  - Leave the access level at “Bitbucket User”.
  - Press “Add”

![bb-user-access-1.png](images%2Fbb-user-access-1.png)

- The end results should be a Renovate Bot user with “Bitbucket User” access only.

![bb-user-access-2.png](images%2Fbb-user-access-2.png)

<div style="padding: 3px; outline: grey solid 1px; outline-offset: 5px;">
Note: It is essential that the Renovate Bot user does NOT have Admin or System admin access. Because Bitbucket Admin and System admin users have full access to all projects and repos, there will be no way to control which repos Renovate will run against, and so Renovate will run against all repos. When the Renovate Bot user has only basic user access, administrators can control which repos run with Renovate by adding the Renovate Bot user to specific repos.
</div>

<a id="stg_1b"></a>
# Stage 1b: Fetch HTTP Access Token for the Renovate Bot user

Once the Renovate Bot user account is created, log in to Bitbucket with the Renovate User account to fetch an HTTP access token for it. This will be used as the `MEND_RNV_BITBUCKET_PAT` in the Renovate CE/EE configuration.
It will be used by Renovate OSS CLI to connect to repos on Bitbucket that the Renovate User has access to.

- Log in to Bitbucket as the Renovate User<br>
http://localhost:7990/login

**_Don’t use the Admin user account!_**
- If logged in as an Admin user account, log out of Bitbucket first.
- Alternatively, open a new web browser in incognito mode. _(Ctrl+Shift+N from a web browser)_

![bb-log-in.png](images%2Fbb-log-in.png)

- Go to the Account management page (eg. http://localhost:7990/account)

You can expand the menu on the user profile icon (top right of page) and click “Manage account”.

![bb-manage-account.png](images%2Fbb-manage-account.png)

- Navigate to the HTTP access tokens page

- Press “Create token” to create a new HTTP access token

![bb-access-token.png](images%2Fbb-access-token.png)

- Create an HTTP access token (with `Repository Write` permission)
  - Token name: Can be anything (eg. “Renovate User PAT”)
  - Permissions:
    - Project permissions: `Project read`
    - Repository permissions: `Repository write`

![bb-new-token.png](images%2Fbb-new-token.png)

- Copy the token and store it for later use.<br>
This will be used as the `MEND_RNV_BITBUCKET_PAT` in the Renovate CE/EE configuration.

<hr>

<a id="stg_2"></a>
# Stage 2: Install Renovate CE/EE Application Server

## Configure the Docker files / Helm charts
Fetch the example docker-compose file or Helm chart configuration files and edit accordingly.
Example files available here:
- Docker files (Renovate CE / Renovate EE)
- Helm charts (Renovate CE / Renovate EE)

Edit the docker files / helm chart values to provide the required environment variables.
Refer to [Available Configurations section](#available_config) for a full list of Renovate CE/EE server variables.

You will need the following information to proceed.

#### Mend Licence Keys
Renovate CE or Renovate EE licence key
Accept Terms of Service  (‘Y’)
Merge Confidence API token - only required if using Smart Merge Control with Renovate EE (ie. `matchConfidence` in package rules)

#### Bitbucket Server Connection details
Bitbucket server URL   (eg, http://localhost:7990/)
Bitbucket Renovate Bot User PAT - See instructions above for getting HTTP access token for Renovate Bot user on Bitbucket

#### Other strongly recommended Renovate Server environment settings
`MEND_RNV_ADMIN_API_ENABLED` - APIs are off by default. Set this to true to enable admin APIs.
Needs `MEND_RNV_SERVER_API_SECRET` to be set.
`MEND_RNV_SQLITE_FILE_PATH` - Mount the DB file to disc. Ensure volume mount is configured below.
`MEND_RNV_LOG_HISTORY_DIR` - Mount the Renovate job logs (Note: This is the Job logs; Not the server/worker machine logs.)
`RENOVATE_REPOSITORY_CACHE` - Faster performance running Renovate on repos on subsequent scans.

## Run the Server
If using Docker, run the Docker Compose file after all values have been correctly inserted.

> docker-compose -f docker-compose-bitbucket.yaml up

If using Kubernetes, install the Helm charts after all values have been correctly inserted in the values.yaml.

> helm install renovate-ce

## Test and Troubleshoot

#### First, look for Licence Key check
When running the Renovate Application Server, the first thing you should notice is the check for Licence and Terms of Service acceptance.
If you see an error for Licence or Terms of Service, it is a good sign - it means the server is running. Go back and check that the licence key is correctly referenced in the yaml files.

#### Next, check connection with the Bitbucket Server
The Renovate Server will attempt to validate the Bitbucket Server endpoint and the Renovate User PAT. Errors will be thrown if the endpoint or PAT are incorrect.
Check that the Bitbucket Server is up and running and available on the given endpoint.
The endpoint needs “/api/1.0” on the end  [Check this]

#### Renovate will App Sync and run Renovate on new Repos
If connecting to the Bitbucket Server, an App Sync will occur (by default). Watch this in the logs. No repos will be synced at this stage if the Renovate Bot user has not been added to any repos. However, if the Renovate Bot user has Admin global permission, Renovate will run on ALL repositories on the Bitbucket server.
If there are repos with Renovate Bot installed, watch the logs to see it run. Open the installed repos to see Pull Requests created by “Renovate Bot”.

#### Check the APIs
- Call the health check			- GET /health
- Call the status check			- GET /api/status
- Call the task queue			- GET /api/task/queue
- Call the job queue			- GET /api/job/queue
- Force an app sync			- POST /api/sync
- Force a Renovate job on a repo	- POST /api/job/add   { "repository": ”PROJECT/repo” }

<a id="stg_3"></a>
# Install Renovate Bot and Webhooks on BitBucket project or repository

<a id="stg_3a"></a>
## Stage 3a: Install Renovate Bot on Repositories(/Projects)
### Overview
Add the Renovate Bot user to any repo (or project) you want Renovate to run on.
Needs “Repository Write” permission so that it can create pull requests on the repo.

### How it works
Renovate will run scans and create PRs on repositories in which the Renovate Bot user has Write access.
So, to install Renovate on a repository, add the Renovate Bot user to the Repository permissions for the repositories or projects you want it installed on.

### Permissions required to install the Renovate Bot user
This must be done by a user with Repository Admin permission to the specific repository being added.
Note: Any Bitbucket user with global permissions of Admin or System admin has full access to every project and repository.

### Note:
- Adding the Renovate Bot user to a **project** will install Renovate on **all repositories** in the project (current and future).
- Giving the Renovate Bot user `global Admin` user access will install Renovate on **all repositories** on the Bitbucket server.

### How to add Renovate Bot to a Repository

- Navigate to the Repository Settings page for a specific repository.<br>
Repo → Repository Settings → Repository permissions

Repo settings page: http://localhost:7990/projects/PROJ1/repos/repo-1/permissions
![bb-repo-permissions.png](images%2Fbb-repo-permissions.png)

- Click the “Add user or group” button (Top right corner)

- Add the Renovate Bot user with permission: Repository Write<br>
  Note: The Renovate Bot user needs write permission so it can create pull requests on the repository.

![bb-add-user.png](images%2Fbb-add-user.png)

Now the Renovate Bot is installed on the repo.

The Renovate server will detect the new repo on the next App Sync.

### Run App Sync to detect new repositories

**App Sync on schedule**

App Sync runs on a schedule, which defaults to every 4 hours.
To update the schedule, set the EnvVar MEND_RNV_CRON_APP_SYNC on the Renovate Server.
Accepts a 5-part cron schedule. Defaults to `0 */4* * * *` (every 4 hours, on the hour).

**Force App Sync via API call**

To trigger the sync immediately, call the sync API (/api/sync) using a tool like Postman.
Requires

Note: To run APIs, ensure Renovate Server has EnvVar `MEND_RNV_ADMIN_API_ENABLED=true`

```
[POST]   http://<RENOVATE-SERVER-URL>/api/sync
Authorization: <MEND_RNV_SERVER_API_SECRET>
```

![bb-postman-sync.png](images%2Fbb-postman-sync.png)

<hr>

<a id="stg_3b"></a>
## Stage 3b: Add Webhooks to Repositories(/Projects)

Webhooks enable a message to be sent from the Bitbucket repository to the Renovate server to trigger a Renovate job on a repository when important files have changed (ie. package files, Renovate config files).

Webhooks can be enabled at the project level or at the repository level.

Note: Only a Bitbucket user with Admin or System Admin global permissions can create web hooks on a project or repository.
Create webhooks via the Bitbucket UI

**To create a webhook on a repository:**

- Navigate to the repository in which you want to add a webhook

- Go to the Repository settings and the Webhooks settings page (under Workflow menu)<br>
  [Repo → Repository Settings → Webhooks]<br>
  http://localhost:7990/projects/PROJ1/repos/repo-1/settings

![bb-repo-webhooks.png](images%2Fbb-repo-webhooks.png)

- Click “Create webhook” to open the Create webhook page

![bb-create-webhook-1.png](images%2Fbb-create-webhook-1.png)

**Provide the following values for the webhook:**
- Name: Can be anything. Duplicates are allowed.
- URL: The URL of the Renovate Server plus “/webhook”. Must be accessible to receive incoming calls from the Bitbucker server.
- Status: Active (true)
- Secret: Must match the value in `MEND_RNV_WEBHOOK_SECRET`. (Defaults to ‘renovate’)
- Authentication: None
- SSL/TLS: (Do not skip certificate verification)
- Events:
  - Project: Modified     (Only available when creating Project webhooks)
  - Repository: Push, Modified
  - Pull request: Modified

![bb-create-webhook-2.png](images%2Fbb-create-webhook-2.png)

- Click “Save” to finish creating the webhook

Webhooks will now be triggered when relevant events occur on the repository.
Renovate jobs will automatically run on the triggering repository as required.

### Create webhooks via the Bitbucket API

Run Bitbucket API to create webhooks on repositories and projects.

**Permissions**

Only Bitbucket users with Admin or System admin global permissions can create webhooks on projects or repositories.
To create a webhook using the Bitbucket APIs, the APIs must pass an HTTP access token as a Bearer Authorization token in the API header.

#### Fetch the Authorization Bearer token

- Log in to Bitbucket as a user with Admin or System admin global permissions
- Navigate to the HTTP access tokens page<br>
  http://localhost:7990/plugins/servlet/access-tokens/users/admin/manage

![bb-admin-token.png](images%2Fbb-admin-token.png)

- Press “Create token” to create the Bearer token required for calling the Bitbucket Server webhook APIs.

Note:
- To create **project** webhooks, the HTTP access token must have `Project Admin` permissions.<br>
- To create **repository** webhooks, the HTTP access token must have `Repository Admin` permissions. (Project Admin not required.)

![bb-create-admin-token.png](images%2Fbb-create-admin-token.png)

- Click “Create” to finish creating the access token
- Copy the access token when it is presented. Store it for use when calling Bitbucket Admin APIs.

### Create Repository webhooks via Bitbucket API

```
[POST] - http://<Bitbucket.Server.URL>/rest/api/latest/projects/<PROJ>/repos/<REPO>/webhooks

Authorization: Bearer <Bitbucket Admin User Http access token with Repository Admin access>
```

Body: (raw - JSON)
```json
{
  "name": "renovate",
  "url": "https://<Renovate.Server.URL>/webhook",
  "configuration": { "secret": "renovate" },    ← Must match MEND_RNV_WEBHOOK_SECRET
  "events": [
    "repo:refs_changed",
    "repo:modified",
    "pr:modified"
  ],
  "active": true,
  "statistics": {},
  "scopeType": "repository",
  "sslVerificationRequired": false
}
```

### Create Project webhooks via Bitbucket API

```
POST  http://<Bitbucket.Server.URL>/rest/api/latest/projects/<PROJ>/webhooks

Authorization: Bearer <Bitbucket Admin User Http access token with Project Admin access>
```

Body: (raw - JSON)
```json
{
  "name": "renovate",
  "url": "https://<Renovate.Server.URL>/webhook",
  "configuration": { "secret": "renovate" },    ← Must match MEND_RNV_WEBHOOK_SECRET
  "events": [
    "pr:modified",                    ← Optional: Add this if you want ALL repos on the project to trigger
    "repo:refs_changed",        ← Optional: Add this if you want ALL repos on the project to trigger
    "repo:modified",                ← Optional: Add this if you want ALL repos on the project to trigger
    "project:modified"
  ],
  "active": true,
  "statistics": {},
  "scopeType": "repository",
  "sslVerificationRequired": false
}
```

**Provide the following values:**
- name: Can be anything. Duplicate names are allowed.
- url: The URL and port of the Renovate Server.
  - Note: Ensure ports are open to receiving incoming calls from the Bitbucket server.
- secret: The Webhook secret defined in the MEND_RNV_WEBHOOK_SECRET environment variable on the Renovate Server.

### Allow Renovate CE/EE to create Repository webhooks via Bitbucket API

By setting the values of the two environment variables `MEND_RNV_WEBHOOK_URL` and `MEND_RNV_ADMIN_TOKEN` 
the server will manage the repositories webhooks automatically 


Notes: `MEND_RNV_ADMIN_TOKEN` 
1. Recommended to use a different token than the token for Renovate bot user
2. This admin token is only used for searching/adding and removing of webhooks on repository level
