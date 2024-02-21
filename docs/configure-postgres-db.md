# Postgres DB Configuration

To configure renovate to use a PostgreSQL database, the following environment variables should be supplied to the Server containers (not required for Worker environment config).

| Environment variable name      | Description                                                   |
|--------------------------------|---------------------------------------------------------------|
| MEND_RNV_DATA_HANDLER_TYPE     | Set to ‘postgresql’ to use a PostgreSQL database              |
| MEND_RNV_POSTGRES_SSL_PEM_PATH | The `.pem` file location in the container for SSL connection  |
| PGDATABASE                     | Name of the database instance. Eg. ‘postgres’                 |
| PGUSER                         | Postgres User name. Must have Create Schema permission.       |
| PGPASSWORD                     | Postgres User password                                        |
| PGHOST                         | Host name of the PostgreSQL instance                          |
| PGPORT                         | Host Port for the PostgreSQL instance                         |

**Note:** DB size is related to the number of repositories installed for Renovate.

## Example configuration

Example configuration in a Docker Compose file is shown below.
Swap out the values of PGXXX parameters for your own instances of the PostgreSQL database.

```
  rnv-ee-server:
    restart: always
    image: ghcr.io/mend/renovate-ee-server
    depends_on:
      - postgres-database
    ports:
      - "8080"
    environment:
      MEND_RNV_DATA_HANDLER_TYPE: postgresql
      PGDATABASE: postgres
      PGUSER: postgres
      PGPASSWORD: password
      PGHOST: postgres-database
      PGPORT: 5432
```

Details of the PostgreSQL user, password, host and port must match your hosted instance of the Renovate PostgreSQL DB.
This could be an externally managed PostgreSQL server, or an instance started inside your Docker Compose configuration.

## Spinning up a PostgreSQL DB container

For convenience, you can spin up your own instance of a PostgreSQL DB, and an  optional frontend Web UI.

###  Docker Compose example

An example of using a PostgreSQL DB server container with Docker Compose is shown below.

```
  postgres-database:
    restart: always
    image: postgres:16.1-alpine3.17
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
```

### Helm Charts example

An example of using PostgreSQL in Helm Charts is available in the [Helm chart example](https://github.com/mend/renovate-ce-ee/tree/main/helm-charts/mend-renovate-ee).

