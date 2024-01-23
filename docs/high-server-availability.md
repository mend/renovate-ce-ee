# Renovate EE High Availability Server

Renovate Enterprise Edition allows scaling of Renovate Server containers, separately to the scaling of the Worker containers. Server redundancy provides high availability for the Renovate Server by reducing bottlenecks caused by large volumes of incoming Webhook and API requests.

In order to allow multiple servers to access the one database, a requirement of the High Availability is that the DB be network accessible. The current implementation uses a PostgreSQL database. See the documentation for [PostgreSQL DB configuration](https://github.com/mend/renovate-ce-ee/blob/main/docs/configure-postgres-db.md) for further details.

## Technical Requirements

### Renovate EE feature only
High Availability Server is a feature only available with Renovate Enterprise Edition. Contact Mend.io regarding licensing for [Renovate Enterprise](https://www.mend.io/renovate-enterprise/).

### Network Database - PostgreSQL
With multiple Server containers requiring access to the information in the Renovate database, it is essential that the DB be available as a network database rather than residing only on a single Server container.
The current implementation of the Renovate database for HA Server is PostgreSQL. When hosting Renovate EE with HA Server, a Postgres instance must be available and accessible to the Renovate Server pool.

See the documentation for [PostgreSQL DB configuration](https://github.com/mend/renovate-ce-ee/blob/main/docs/configure-postgres-db.md) for further details.

## How it works
**Summary: All Renovate Servers process incoming requests. The Primary server also runs cron jobs.**

When multiple instances of the Renovate Server are running, all will be capable of processing incoming requests via Webhooks and API calls.
One server will designate itself as the Primary server, and this server will also have the additional responsibility to run system cron jobs. (ie. App sync, Job scheduling, Log cleanup).

### Selecting the Primary Server

On startup, each Renovate Server will check the database to see if a Primary server is already allocated. If not, it will allocate itself as the primary server and update the database to reflect it.
Also, all Renovate Servers will perform the Primary check every 30 seconds. This provides faster failover if one of the servers goes down.

You can check the container logs to see whether a server has taken the primary role.

### Load balancing the servers

Incoming Webhooks for a GitHub App can only point to one URL. In order to spread the load over multiple servers, a load balancing system must be implemented.
Note: Sample Docker Compose files contain examples of including an nginx load balance in the Docker environment, which will automatically handle routing the request to the servers.

# Configuration

### Enabling Renovate HA Server
High Availability Server means running more than one Renovate Server container instance. This is defined by the “replicas” property in the Docker Compose file or Helm Charts. See examples below.

Docker Compose example
```
…
  rnv-ee-server:
    restart: always
    image: ghcr.io/mend/renovate-ee-server
    deploy:
      replicas: 2
…
```

Example of Helm chart configuration (in values.yaml)
```
…
renovateServer:
  image:
    repository: ghcr.io/mend/renovate-ee-server
    tag: 6.9.1
    pullPolicy: IfNotPresent

  # Number of renovate-ee-server (for SQLite only 1 replica is allowed)
  replicas: 2
…
```