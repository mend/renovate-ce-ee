# Amazon RDS PostgreSQL IAM Authentication

The Server can authenticate to a PostgreSQL database hosted on Amazon RDS using [IAM database authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.html) instead of a static password. A short-lived token is generated for each new database connection, so no database password needs to be stored or rotated.

To enable it, the following environment variables should be supplied to the Server containers (not required for Worker environment config).

| Environment variable name            | Description                                                                                            |
|--------------------------------------|--------------------------------------------------------------------------------------------------------|
| `MEND_RNV_DATA_HANDLER_TYPE`           | Set to `postgresql` to use a PostgreSQL database                                                       |
| `MEND_RNV_POSTGRES_IAM_AUTH_ENABLED`   | Set to `true` to authenticate with an IAM token instead of `PGPASSWORD`. Defaults to `false`.           |
| `MEND_RNV_POSTGRES_SSL_PEM_PATH`       | Required. The RDS CA bundle `.pem` file location in the container                                      |
| `PGDATABASE`                           | Name of the database instance                                                                          |
| `PGUSER`                               | Required. The database user granted the `rds_iam` role. Must have Create Schema permission.            |
| `PGHOST`                               | Required. The RDS instance endpoint                                                                    |
| `PGPORT`                               | Host Port for the PostgreSQL instance. Defaults to `5432`.                                               |
| `AWS_REGION`                           | The region of the RDS instance, unless already resolved from the environment                           |

**Note:** `PGPASSWORD` must not be set. The Server fails to start if a password is supplied while `MEND_RNV_POSTGRES_IAM_AUTH_ENABLED` is enabled.

**Note:** `PGHOST` must be the actual RDS endpoint, not a Route 53 record or another DNS alias, because the endpoint is part of the signed token.

For the standard password-based setup, see [Postgres DB Configuration](configure-postgres-db.md).

## AWS prerequisites

1. Enable [IAM database authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.Enabling.html) on the RDS instance.
2. Create the database user, grant it the `rds_iam` role, and grant it the privileges required by the Server. See [Creating a database account using IAM authentication](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.DBAccounts.html).
3. Attach an [`rds-db:connect` policy](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.IAMDBAuth.IAMPolicy.html) for that database user to the IAM role used by the Server workload. The resource must use the RDS DB *resource ID* (`db-XXXXXXXXXXXX`), not the DB instance identifier:

   ```
   arn:aws:rds-db:<region>:<account-id>:dbuser:<db-resource-id>/<database-user>
   ```

4. Download the RDS CA bundle and mount it into the Server container. The bundle is public, not a secret: <https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem>.

The AWS SDK obtains credentials from its [default credential provider chain](https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html). When running in AWS, attach the policy above to the workload identity of the container - for example an EKS IAM role for service accounts (IRSA), an ECS task role, or an EC2 instance profile.

## Example configuration

Example configuration in a Docker Compose file is shown below.

```yaml
  rnv-ee-server:
    restart: always
    image: ghcr.io/mend/renovate-ee-server
    ports:
      - "8080"
    environment:
      MEND_RNV_DATA_HANDLER_TYPE: postgresql
      MEND_RNV_POSTGRES_IAM_AUTH_ENABLED: "true"
      MEND_RNV_POSTGRES_SSL_PEM_PATH: /certs/rds-ca.pem
      PGDATABASE: renovate
      PGUSER: renovate
      PGHOST: database.abc123.us-east-1.rds.amazonaws.com
      PGPORT: 5432
      AWS_REGION: us-east-1
    volumes:
      - ./certs/global-bundle.pem:/certs/rds-ca.pem:ro
```

### Helm Charts example

Both Helm charts expose the `postgresql.iamAuthEnabled` value. It takes precedence over `postgresql.password`: when set to ‘true’, the chart renders `MEND_RNV_POSTGRES_IAM_AUTH_ENABLED=true` and does not render `PGPASSWORD`, even if a password is provided. This applies to the chart rendering only - if `PGPASSWORD` reaches the container by another route, such as `extraEnvVars` or `extraEnvFromSecrets`, the Server still fails to start.

The CA bundle and its path are supplied with the generic `extraVolumes`, `extraVolumeMounts` and `extraEnvVars` values. Both examples below use a ConfigMap created with `kubectl create configmap rds-ca-bundle --from-file=rds-ca.pem=global-bundle.pem`.

Renovate EE (`mend-renovate-ee`):

```yaml
postgresql:
  enabled: true
  iamAuthEnabled: true
  host: database.abc123.us-east-1.rds.amazonaws.com
  port: 5432
  database: renovate
  user: renovate

renovateServer:
  extraEnvVars:
    - name: MEND_RNV_POSTGRES_SSL_PEM_PATH
      value: /certs/rds-ca.pem
    - name: AWS_REGION
      value: us-east-1
  extraVolumes:
    - name: rds-ca-bundle
      configMap:
        name: rds-ca-bundle
  extraVolumeMounts:
    - name: rds-ca-bundle
      mountPath: /certs
      readOnly: true
  serviceAccount:
    create: true
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<renovate-server-role>
```

Renovate CE (`mend-renovate-ce`), where `extraEnvVars` is set under `renovate` and the volume and service account values are at the top level of the chart:

```yaml
postgresql:
  enabled: true
  iamAuthEnabled: true
  host: database.abc123.us-east-1.rds.amazonaws.com
  port: 5432
  database: renovate
  user: renovate

renovate:
  extraEnvVars:
    - name: MEND_RNV_POSTGRES_SSL_PEM_PATH
      value: /certs/rds-ca.pem
    - name: AWS_REGION
      value: us-east-1

extraVolumes:
  - name: rds-ca-bundle
    configMap:
      name: rds-ca-bundle

extraVolumeMounts:
  - name: rds-ca-bundle
    mountPath: /certs
    readOnly: true

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<renovate-server-role>
```
