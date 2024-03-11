# Mend Renovate - Example Configuration Files

To get started with Mend Renovate Community Edition or Enterprise Edition, you can use the examples provided in this repository.

There are Docker Compose files created for:
- Mend Renovate Community Edition
- Mend Renovate Enterprise Edition

See the [helm-charts](../helm-charts) folder for examples of using Helm Charts.

## Example Docker Compose files

### Mend Renovate Community Edition

| File                                                                | Description                                                                                                                                                               | Containers created                                                                  |
|---------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| [renovate-ce-github.yml](docker-compose/renovate-ce-github.yml)     | Starts a single container for Mend Renovate Community Edition.                                                                                                            | <li>1 x Mend Renovate CE container</li>            |
| [renovate-ce-postgres.yml](docker-compose/renovate-ce-postgres.yml) | Starts a single container for Mend Renovate Community Edition.<li>Uses network accessible PostgreSQL DB</li><br/><br/>Requires additional files: <li>[pgAdmin Dockerfile](dockerfiles/pgadmin/Dockerfile)</li> | <li>1 x Mend Renovate CE</li><li>Postgres DB</li><li>Postgres Web UI (pgAdmin)</li> |

### Mend Renovate Enterprise Edition

| File                                                                                    | Description                                                                                                                                                                                                                                                                                                                                                 | Containers created                                                                                                                                               |
|-----------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [renovate-ee-simple.yml](docker-compose/renovate-ee-simple.yml)                         | Starts containers for Mend Renovate Enterprise Edition.<br/><li>Runs a single Server with multiple Worker containers.</li><li>Uses internal SQLite DB.                                                                                                                                                                                                      | <li>1 x Renovate EE Server </li><li>2 x Renovate EE Workers</li>                                                                                                 |
| [renovate-ee-server-ha-postgres.yml](docker-compose/renovate-ee-server-ha-postgres.yml) | Starts containers for Mend Renovate Enterprise Edition.<br/><li>Runs with multiple Server containers.</li><li>Uses network accessible PostgreSQL DB</li><li>APIs enabled</li><li>Job logs written to mounted volume</li><br/><br/>Requires additional files: <li>[NGINX conf file](conf/nginx.conf)<li>[pgAdmin Dockerfile](dockerfiles/pgadmin/Dockerfile) | <li>2 x Renovate EE Servers</li><li>2 x Renovate EE Workers</li><li>NGINX load balancer (for Servers)</li><li>Postgres DB</li><li>Postgres Web UI (pgAdmin)</li> |

## Example Env files

Instead of having all Server and Worker environment variables defined in the Docker Compose files, variables can be defined in separate env files and referenced from the Docker Compose file in the 'env_file' section.
One primary reason to do this is to separate license keys and access tokens from the other files that are committed to source code.
Another reason is to manage swapping between different running environments and targets.

The [env directory](env) provides some templates for environment variables required to run Mend Renovate and connect to the supported platforms.<br/>
Check the [docs directory](../docs) for information about additional variables and options.

### Env file templates

| File              | Description                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------|
| mend-renovate.env | Env vars associated with the Mend Renovate application. Includes License key and API secret. |
| github.env        | Env vars for connecting Mend Renovate to a Renovate App on GitHub                            |
| gitlab.env        | Env vars for connecting Mend Renovate to a Renovate Bot user account on GitLab               |