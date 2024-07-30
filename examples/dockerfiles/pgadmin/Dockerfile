FROM dpage/pgadmin4:8.10

# pgadmin server user attributes
ARG P_USER=pgadmin
ARG P_DOMAIN=mend.io
ARG P_PASSWORD=admin

# This allows connection information to be pre-loaded into the instance of pgAdmin in the container.
# https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#mapped-files-and-directories
#{
#  "Servers": {
#    "1": {
#      "Name": "Renovate-Pro",
#      "Group": "Servers",
#      "Port": 5432,
#      "Username": "admin",
#      "Host": "postgres-database",
#      "SSLMode": "prefer",
#      "PassFile": "/pgpass",
#      "MaintenanceDB": "postgres"
#    }
#  }
#}
ARG SERVERS='{"Servers":{"1":{"Name":"Renovate-Pro","Group":"Servers","Port":5432,"Username":"postgres","Host":"postgres-database","SSLMode":"prefer","PassFile":"/pgpass","MaintenanceDB":"postgres"}}}'

# remote database password file
# https://www.postgresql.org/docs/current/libpq-pgpass.html
# hostname:port:database:username:password
ARG PGPASS='postgres-database:5432:postgres:postgres:password'

# pgadmin home dir
ARG PGADMIN_DIR=/var/lib/pgadmin/storage/${P_USER}_${P_DOMAIN}

# pgadmin required environment variables
ENV PGADMIN_DEFAULT_EMAIL=${P_USER}@${P_DOMAIN}
ENV PGADMIN_DEFAULT_PASSWORD=${P_PASSWORD}

# Create postgres password file
USER ${P_USER}
RUN mkdir -p  ${PGADMIN_DIR}
RUN echo ${PGPASS} > ${PGADMIN_DIR}/pgpass

# Disallow any access to the password file
# https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#mapped-files-and-directories
USER root
RUN chown -R 5050:5050  ${PGADMIN_DIR}/pgpass
RUN chmod 0600          ${PGADMIN_DIR}/pgpass

# Create server definitions file
RUN echo ${SERVERS} > /pgadmin4/servers.json

USER ${P_USER}
ENTRYPOINT ["/entrypoint.sh"]
