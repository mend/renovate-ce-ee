# Job APIs

Enabling jobs APIs is done by setting both `MEND_RNV_API_ENABLED: true` and `MEND_RNV_API_ENABLE_JOBS: true` (both are backward compatible with `MEND_RNV_API_ENABLED`)

Job Logs APIs provide a summary of and content for the Job Logs generated by the Renovate CLI.

The Run Job API schedules a Renovate job to run against a given repository.

## Available Job APIs

The list below describes the available Job Logs APIs. Follow the links on the API names for full details.

- [List Jobs by Repo](#list-jobs-by-repo) ← Lists all jobs for a given repo
- [Get Job Logs by Repo](#get-job-logs-by-repo) ← Fetch job logs for a given repo (latest, or by JobID)
- [Get Job Logs by JobID](#get-job-logs-by-jobid) ← Fetch job logs by Job ID
- [Run Job on a Repo](#run-job-on-a-repo) ← Run a Renovate job against a given repo

## Enable Job Logs APIs

Job Logs APIs are enabled with Renovate Admin APIs, which is off by default.

Authentication is done via HTTP Auth, using the API secret as the password.
For example if the secret is `renovateapi` then you would authenticate by adding the following request header:

```
  Authorization: Bearer renovateapi
  or
  Authorization: renovateapi
```

## Job Logs API URLs

See the table below for a list of Job Logs API URL formats.

| API                                             | URL format                                                | Query parameters                |
|-------------------------------------------------|-----------------------------------------------------------|---------------------------------|
| [List Jobs by Repo](#list-jobs-by-repo)      | [GET] /api/v1/repos/{org}/{repo}/-/jobs                   | limit (default=100, max=10,000) |
| [Get Job Logs by Repo](#get-job-logs-by-repo)   | [GET] /api/v1/repos/{org}/{repo}/-/jobs/<latest\|{jobId}> |                                 |
| [Run Job on a Repo](#run-job-on-a-repo)      | [POST] /api/v1/repos/{org}/{repo}/-/jobs/run              |                                 |

## Details of Job Logs APIs

### List Jobs by Repo

API: [GET] /api/v1/repos/{org}/{repo}/-/jobs

query parameters:
- limit
  - Max = 10,000
  - Default = 100

Pagination is not supported. Results are sorted with most recent job first.

**Description:** Lists all known Job Logs for a given repo

**Example:** Fetch job list for repo `my-org/my-repo`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/my-repo/-/jobs   (Note: no trailing slash!)

```json
[
  {
    "jobId": "5a3572bf-49fe-42bb-a066-ff1146fe83d1",
    "reason": "api-request",
    "addedAt": "2024-05-13 12:41:49.760008",
    "startedAt": "2024-05-13 12:41:51.443102",
    "completedAt": "2024-05-13 12:42:32.807422",
    "logLocation": "S3://job-logs/my-org/my-repo/5a3572bf-49fe-42bb-a066-ff1146fe83d1.log.gz",
    "status": "success"
  },
  {
    "jobId": "fccefbdc-de1e-49b7-bd9a-bfe530ee7547",
    "reason": "repositories-added",
    "addedAt": "2024-05-13 09:01:20.227617",
    "startedAt": "2024-05-13 09:01:25.735557",
    "completedAt": "2024-05-13 09:03:22.818254",
    "logLocation": "S3://job-logs/my-org/my-repo/fccefbdc-de1e-49b7-bd9a-bfe530ee7547.log.gz",
    "status": "success",
    "artifactErrors": {
      "renovate/husky-8.x": [
        {
          "stderr": "npm ERR! code ETARGET\nnpm ERR! notarget No matching version found for nanoid@3.31.4.\nnpm ERR! notarget In most cases you or one of your dependencies are requesting\nnpm ERR! notarget a package version that doesn't exist.\n\nnpm ERR! A complete log of this ru<truncated>",
          "lockFile": "package-lock.json"
        }
      ]
    }
  }
]
```

### Get Job Logs by Repo

API: [GET] /api/v1/repos/{org}/{repo}/-/jobs/<latest|{jobId}>

**Description:** Get the contents of a single job log for a given repo

Options:
- "latest" - returns the most recent job logs for the given repo
- {jobId} - returns the job logs for the specified jobId
  - Note: this variation returns the same as [Get Job Logs by JobID](#get-job-logs-by-jobid)

**Example 1:** Fetch latest job logs for repo `my-org/my-repo`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/my-repo/-/jobs/latest

**Example 2:** Fetch job logs for JobID `5a3572bf-49fe-42bb-a066-ff1146fe83d1` in repo `my-org/my-repo`

[GET] http://my.renovate.server.com/api/v1/repos/my-org/my-repo/-/jobs/5a3572bf-49fe-42bb-a066-ff1146fe83d1

**Sample output:**

```json
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","config":{},"msg":"File config","time":"2024-05-13T12:41:58.139Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","config":{},"msg":"CLI config","time":"2024-05-13T12:41:58.143Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","config":{},"msg":"Env config","time":"2024-05-13T12:41:58.152Z","v":0}
{"......many rows removed......"}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","repository":"my-org/my-repo","hosts":[],"msg":"dns cache","time":"2024-05-13T12:42:29.346Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":30,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","repository":"my-org/my-repo","cloned":false,"durationMs":29063,"msg":"Repository finished","time":"2024-05-13T12:42:29.348Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","msg":"Checking file package cache for expired items","time":"2024-05-13T12:42:29.351Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","msg":"Verifying and cleaning cache: /tmp/renovate/cache/renovate/renovate-cache-v1","time":"2024-05-13T12:42:29.521Z","v":0}
{"name":"renovate","hostname":"271939e11491","pid":21,"level":20,"logContext":"5a3572bf-49fe-42bb-a066-ff1146fe83d1","msg":"Deleted 0 of 29 file cached entries in 840ms","time":"2024-05-13T12:42:30.193Z","v":0}
```


### Run Job on a Repo

API: [POST] /api/v1/repos/{org}/{repo}/-/jobs/run

**Description:** Schedules a job to run Renovate on the given repository
