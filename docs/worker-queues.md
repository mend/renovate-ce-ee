<!-- omit in toc -->
# Worker Queues 

Worker queues let you isolate Renovate workloads across dedicated worker pools, instead of sending all jobs to the default shared workers.

This document covers the worker queue workflow and routing model.

For general API documentation, see [API Documentation](./api.md). For the exact worker queue API contract, see [the OpenAPI spec for Enterprise APIs](./openapi-enterprise.yaml) or the [rendered API documentation](https://mend.github.io/renovate-ce-ee/api.html).

> [!IMPORTANT]
> Worker queues are an Enterprise only feature.

<!-- omit in toc -->
# Table of Content

- [How routing works](#how-routing-works)
- [Required environment variables](#required-environment-variables)
  - [Server](#server)
  - [Worker](#worker)
- [Queue Management](#queue-management)
- [Queue Assignment](#queue-assignment)
- [Worker Configuration](#worker-configuration)
- [Metrics and Autoscaling](#metrics-and-autoscaling)
- [End to End Example](#end-to-end-example)
  - [1. Create a queue](#1-create-a-queue)
  - [2. Assign an entity to the queue](#2-assign-an-entity-to-the-queue)
  - [3. Verify the queue configuration](#3-verify-the-queue-configuration)
  - [4. Configure a worker to consume the queue](#4-configure-a-worker-to-consume-the-queue)
  - [5. Result](#5-result)
- [Related documentation](#related-documentation)


## How routing works

Worker queue routing follows this precedence order:

1. Repository queue assignment
2. Organization queue assignment
3. default queue (`main`)

If both an organization and a repository are assigned to queues, the repository level queue wins.

## Required environment variables

### Server

```sh
MEND_RNV_API_ENABLED=true
MEND_RNV_API_ENABLE_SYSTEM=true
MEND_RNV_API_SERVER_SECRET=<server_secret>
```

Enable these settings on the server to manage queues through the System API.

To expose worker queue metrics, also enable:

```sh
MEND_RNV_API_ENABLE_PROMETHEUS_METRICS=true
```

See [Metrics and Autoscaling](#metrics-and-autoscaling).

### Worker

```sh
MEND_RNV_WORKER_QUEUES=<queue_name>
```

Set this on workers that should consume from specific queues instead of the default `main` queue. See [Worker Configuration](#worker-configuration) for supported values and examples.

## Queue Management

The endpoint summaries below do not include full request and response schemas. For request bodies, response payloads, validation rules, and status codes, see [openapi-enterprise.yaml](./openapi-enterprise.yaml) or the [rendered API documentation](https://mend.github.io/renovate-ce-ee/api.html).

| Endpoint                               | Purpose                                                                |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `POST /system/v1/queues`               | Create a named worker queue such as `arm`, `large-repos`, or `team-a`. |
| `GET /system/v1/queues`                | List queues and their current pending and running job counts.          |
| `PATCH /system/v1/queues/{queueName}`  | Update queue metadata such as description or lock state.               |
| `DELETE /system/v1/queues/{queueName}` | Delete a queue after it has been unlocked.                             |

## Queue Assignment

| Endpoint                                  | Purpose                                                                                                                                    |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `PATCH /system/v1/orgs/{org}/queue`       | Assign a named queue to an organization. Use this when most repositories in an organization should run on the same worker pool by default. |
| `DELETE /system/v1/orgs/{org}/queue`      | Remove the explicit organization queue assignment.                                                                                         |
| `PATCH /system/v1/repos/{orgRepo}/queue`  | Assign a queue to a repository. Use this to override the organization queue or to pin a repository explicitly to `main`.                   |
| `DELETE /system/v1/repos/{orgRepo}/queue` | Remove the explicit repository queue assignment so routing falls back to the organization assignment or `main`.                            |

## Worker Configuration

Use `MEND_RNV_WORKER_QUEUES` to define which queues a worker can process (default: `main`).

Examples:

```sh
# General purpose workers on the default queue
MEND_RNV_WORKER_QUEUES=main

# Dedicated workers for ARM routed jobs
MEND_RNV_WORKER_QUEUES=arm

# Workers that can drain both shared and dedicated queues
MEND_RNV_WORKER_QUEUES=main,arm,x86

# Workers that should consume from every queue
MEND_RNV_WORKER_QUEUES=all
```

In practice, queue isolation depends on both sides being configured:

- The server side assignment decides which queue a job is routed to
- The worker configuration decides which queues a worker is allowed to consume

Special handling:

- `all` is reserved in the API and cannot be used as a named worker queue
- In worker configuration, `all` is a wildcard value that means "consume from every queue"
- If `all` is present, it overrides the need to list specific queues

## Metrics and Autoscaling

If Prometheus metrics are enabled on the server, worker queue state is exposed through the metrics output.

Use these metrics to monitor queue backlog and job wait time from your metrics system or autoscaler.

For the metrics overview currently documented in this repository, see [Prometheus metrics](./prometheus-metrics.md).

## End to End Example

This example shows the full flow for creating a queue, assigning an entity to it, and configuring a worker to consume it.

### 1. Create a queue

Create a queue named `arm`:

```sh
MEND_RNV_SERVER_HOSTNAME=<server_url>
MEND_RNV_API_SERVER_SECRET=<server_secret>

curl --request POST "$MEND_RNV_SERVER_HOSTNAME/system/v1/queues" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "arm",
    "description": "ARM worker pool"
  }'
```

This creates the queue definition that routing can target.

### 2. Assign an entity to the queue

Assign an organization to `arm`:

```sh
curl --request PATCH "$MEND_RNV_SERVER_HOSTNAME/system/v1/orgs/example-org/queue" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "queue": "arm"
  }'
```

At this point, repositories in `example-org` will route to `arm` unless a repository has its own explicit queue assignment.

You can do the same at repository level instead:

```sh
curl --request PATCH "$MEND_RNV_SERVER_HOSTNAME/system/v1/repos/example-org/example-repo/queue" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "queue": "arm"
  }'
```

### 3. Verify the queue configuration

List queues to confirm that `arm` exists:

```sh
curl --request GET "$MEND_RNV_SERVER_HOSTNAME/system/v1/queues" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET"
```

Filter for a specific queue:

```sh
curl --request GET "$MEND_RNV_SERVER_HOSTNAME/system/v1/queues?name=arm" \
  -H "Authorization: Bearer $MEND_RNV_API_SERVER_SECRET"
```

### 4. Configure a worker to consume the queue

Configure one or more workers with:

```sh
MEND_RNV_WORKER_QUEUES=arm
```

Now that worker pool will consume jobs routed to `arm`.

### 5. Result

The flow is now complete:

- The queue exists
- The organization or repository is routed to that queue
- A worker is subscribed to that queue

That is the minimum setup needed for dedicated queue based execution.

## Related documentation

- [API Documentation](./api.md)
- [OpenAPI spec for Enterprise APIs](./openapi-enterprise.yaml)
- [Rendered API documentation](https://mend.github.io/renovate-ce-ee/api.html)
- [Prometheus metrics](./prometheus-metrics.md)
- [Advanced details](./advanced.md)
