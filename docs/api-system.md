# System APIs

Enabling system APIs is done by setting both `MEND_RNV_API_ENABLED: true` and `MEND_RNV_API_ENABLE_SYSTEM: true` (both are backward compatible with `MEND_RNV_API_ENABLED`)

### Queue status

`GET /system/v1/jobs/queue`

Returns the current status of the job queue, including number of pending jobs.

`GET /system/v1/tasks/queue`

Returns the current status of the task queue, including number of pending tasks.
Generally speaking, tasks are internal implementation details, such as syncing.
As end-user you usually do not need to worry about tasks.
This API is exposed primarily to help you troubleshoot if something is going wrong.

### Sync and jobs

`POST /system/v1/sync`

Triggers an immediate repository sync against the platform/server.
Normally you don't need this endpoint.
But it can be useful if you think Renovate's internal state has become out of sync: for example when a new repository is missing.

`POST /system/v1/jobs/add`

This endpoint allows adding a new job to the queue.
The request body must contain a single repository:

```json
{ "repository": "some-org/some-repo" }
```

### Status

`GET /system/v1/status`

Return the current status of the service since boot time. This information includes job history, job queue size, in-progress jobs, scheduler status, webhook status, Renovate version, and more. All timestamps in the response body are in UTC.


### Logs

#### Get Job Logs by JobID

API: [GET] /system/v1/jobs/logs/{jobId}

**Description:** Returns the job logs for the specified JobID

Note: This returns the same as [Get Job Logs by Repo](#get-job-logs-by-repo) with JobID variation, but conveniently does not require the {org}/{repo} in the API endpoint.

**Example:** Fetch job logs for JobID `5a3572bf-49fe-42bb-a066-ff1146fe83d1`

[GET] http://my.renovate.server.com/system/v/1/jobs/logs/5a3572bf-49fe-42bb-a066-ff1146fe83d1

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