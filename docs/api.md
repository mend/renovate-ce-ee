# Renovate API

Renovate CE/EE exposes a REST API that you can use to interact programmatically with Renovate.

## Enabling and Authentication

The APIs can be enabled by setting the `MEND_RNV_API_ENABLED: true` (renamed from `MEND_RNV_ADMIN_API_ENABLED`).
You must also configure an API secret by setting the `MEND_RNV_API_SERVER_SECRET` (renamed from `MEND_RNV_SERVER_API_SECRET`) variable.

Authentication is done via HTTP Auth, using the API secret as the password.
For example if the secret is `renovateapi` then you would authenticate with:

```
  Authorization: Bearer renovateapi
  or
  Authorization: renovateapi
```

## Endpoints

Endpoints are divided into different sections

### Health

* `GET /health`

Returns 200 if API is healthy.

### Prometheus Metrics

* `GET /metrics`

This endpoint exposes Prometheus-compatible metrics.

Controlled by `MEND_RNV_API_ENABLE_PROMETHEUS_METRICS` (backward compatible with `MEND_RNV_PROMETHEUS_METRICS_ENABLED`)

### System API Routes

```
GET  /system/v1/status
GET  /system/v1/tasks/queue
GET  /system/v1/jobs/queue
GET  /system/v1/jobs/logs/:jobId
POST /system/v1/jobs/add
POST /system/v1/sync
```

Controlled by both:
* `MEND_RNV_API_ENABLED: true`  (backward compatible with `MEND_RNV_ADMIN_API_ENABLED`)
* `MEND_RNV_API_ENABLE_SYSTEM: true` (backward compatible with `MEND_RNV_ADMIN_API_ENABLED`)


See separate [System APIs documentation](api-system.md) for information about the Jobs APIs.

### Jobs API Routes

```
POST /api/v1/repos/{org}/{repo}/-/jobs/run
GET  /api/v1/repos/{org}/{repo}/-/jobs/:jobId
GET  /api/v1/repos/{org}/{repo}/-/jobs
```

Controlled by both:
* `MEND_RNV_API_ENABLED: true`  (backward compatible with `MEND_RNV_ADMIN_API_ENABLED`)
* `MEND_RNV_API_ENABLE_JOBS: true` (backward compatible with `MEND_RNV_ADMIN_API_ENABLED`)


See separate [Job APIs documentation](api-jobs.md) for information about the Jobs APIs.


### Reporting APIs

```
GET /api/v1/orgs
GET /api/v1/orgs/{org}
GET /api/v1/orgs/{org}/-/repos

GET /api/v1/repos/{org}/{repo}
GET /api/v1/repos/{org}/{repo}/-/pulls
GET /api/v1/repos/{org}/{repo}/-/dashboard

GET /api/v1/orgs/-/libyears
GET /api/v1/orgs/{org}/-/libyears
GET /api/v1/repos/{org}/{repo}/-/libyears
```

Controlled by both:
* `MEND_RNV_API_ENABLED: true` (backward compatible with `MEND_RNV_ADMIN_API_ENABLED`)
* `MEND_RNV_API_ENABLE_REPORTING: true` (backward compatible with `MEND_RNV_REPORTING_ENABLED`)

See separate [Reporting APIs documentation](api-reporting.md) for information about the Reporting APIs.
