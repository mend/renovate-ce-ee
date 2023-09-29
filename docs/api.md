# Renovate API

Renovate CE/EE exposes a REST API that you can use to interact programmatically with Renovate.

## Enabling and Authentication

The API can be enabled by setting the `MEND_RNV_ADMIN_API_ENABLED` environment variable to `true`.
You must also configure an API secret by setting the `MEND_RNV_SERVER_API_SECRET` variable.

Authentication is done via HTTP Auth, using the API secret as the password.
For example if the secret is `renovateapi` then you would authenticate with:

```
  Authorization: renovateapi
```

## Endpoints

### Health

`GET /health`

Returns 200 if API is healthy.

### Queue status

`GET /api/job/queue`

Returns the current status of the job queue, including number of pending jobs.

`GET /api/task/queue`

Returns the current status of the task queue, including number of pending tasks.
Generally speaking, tasks are internal implementation details, such as syncing.
As end-user you usually do not need to worry about tasks.
This API is exposed primarily to help you troubleshoot if something is going wrong.

### Sync and jobs

`POST /api/sync`

Triggers an immediate repository sync against the platform/server.
Normally you don't need this endpoint.
But it can be useful if you think Renovate's internal state has become out of sync: for example when a new repository is missing.

`POST /api/job/add`

This endpoint allows adding a new job to the queue.
The request body must contain a single repository:

```
{ "repository": "some-org/some-repo" }
```
