# Instructions for using TLS communication for Renovate EE with Docker Compose files

## Generating local certificate keys and files
- Check the certificate configuration in cert.conf. Update values as necessary.
- Run 'cert_create.sh' from a linux prompt with OpenSSL installed.
  - `/renovate-ce-ee/examples/tls# ./cert_create.sh`
- It will generate three files:
  - local_ca.pem
  - local_server.key
  - local_server.pem
- Reference these files in the TLS configuration:
  - tls_server_config.json (key: local_server.key, cert: local_server.pem)
  - tls_worker_config.json (ca: local_ca.pem)

## Docker Compose file updates
- Ensure that the tls directory is mounted in both the SERVER and WORKER configuration:
  - volumes:
    - /<renovate-ce-ee dir>/examples/tls:/tls   # Linux version
    - C:\<renovate-ce-ee dir>\examples\tls:/tls  # Windows version
- Add/update the following Env Vars:
  - SERVER and WORKER
    - `MEND_RNV_SERVER_HOSTNAME: https://rnv-ee-server:8443`
    - `MEND_RNV_SERVER_HTTPS_PORT: 8443  # Optional. Defaults to 8443`
  - SERVER
    - `MEND_RNV_SERVER_HTTPS_CONFIG_PATH: /tls/tls_server_config.json`
  - WORKER
    - `MEND_RNV_CLIENT_HTTPS_CONFIG_PATH: /tls/tls_worker_config.json`
