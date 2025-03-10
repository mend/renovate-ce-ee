# Instructions for using TLS communication for Renovate EE with Docker Compose files

### Contents

<!-- TOC -->
* [1. Generate local certificate keys and files](#1-generate-local-certificate-keys-and-files)
  * [Example certificate generation file (cert.conf)](#example-certificate-generation-file-certconf)
  * [Example script for generating local certificates (cert_create.sh)](#example-script-for-generating-local-certificates-cert_createsh-)
* [2. Update Docker Compose configuration](#2-update-docker-compose-configuration)
<!-- TOC -->

## 1. Generate local certificate keys and files
- Create a file `cert.conf` to hold certificate configuration. ([See example](#example-certificate-generation-file-certconf))
- Create file `cert_create.sh` and run from a command prompt with OpenSSL installed. ([See example](#example-script-for-generating-local-certificates-cert_createsh-))

- Running the script will generate three files:
  - local_ca.pem
  - local_server.key
  - local_server.pem

- Reference these files in the TLS configuration:
  - tls_server_config.json (key: local_server.key, cert: local_server.pem)
  - tls_worker_config.json (ca: local_ca.pem)

### Example certificate generation file (cert.conf)
```
[ local_san ]
keyUsage                = digitalSignature, nonRepudiation, keyEncipherment
extendedKeyUsage        = serverAuth
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
subjectAltName          = @local_san_subject
basicConstraints        = CA:FALSE

[ local_san_subject ]
# Valid local addresses
DNS.1       = localhost
DNS.2       = 127.0.0.1
DNS.3       = ::1
DNS.4       = test.local
DNS.5       = api.localhost
DNS.6       = rnv-ee-server
## Example local IPs for testing
# IP.1        = 192.168.1.100
# IP.2        = 192.168.1.101
```

### Example script for generating local certificates (cert_create.sh) 
```sh
#!/bin/sh

# inspired by https://gist.github.com/nathanielks/88e7827a653e8696021ed436481b42dc
#

common_name="localhost"

# Step 1: Generate a 4096-bit private key for the Certificate Authority (CA)
openssl genrsa -out local_ca.key 4096

# Step 2: Create a self-signed CA certificate valid for 1000 days
openssl req -x509 -new -nodes -key local_ca.key -days 1000 -sha256 \
  -subj "/CN=$common_name" -out local_ca.pem

# Step 3: Generate a 2048-bit private key for the server
openssl genrsa -out local_server.key 2048

# Step 4: Create a Certificate Signing Request (CSR) for the server
openssl req -new -subj "/CN=$common_name" -key local_server.key -out local_server.csr

# Step 5: Sign the CSR with the local CA, using extensions from cert.conf
openssl x509 -req -sha256 -CAcreateserial \
  -CA local_ca.pem \
  -CAkey local_ca.key \
  -days 1000 \
  -extfile cert.conf \
  -extensions local_san \
  -in local_server.csr \
  -out local_server.pem

# Step 6: Clean up sensitive intermediate files
rm local_ca.key
rm local_ca.srl
rm local_server.csr
chmod 600 local_server.key # Restrict server key permissions for better security
```

## 2. Update Docker Compose configuration

Update the Docker Compose examples as follows:

Ensure that the `tls` directory is mounted in both the SERVER and WORKER configurations:
- volumes:
  - `/<renovate-ce-ee dir>/examples/tls:/tls`   # Linux version
  - `C:\<renovate-ce-ee dir>\examples\tls:/tls`  # Windows version

Add/update the following environment variables:
- SERVER
  - `MEND_RNV_SERVER_HTTPS_PORT: 8443`
  - `MEND_RNV_SERVER_HTTPS_CONFIG_PATH: /tls/tls_server_config.json`
- WORKER
  - `MEND_RNV_SERVER_HOSTNAME: https://rnv-ee-server:8443`
  - `MEND_RNV_CLIENT_HTTPS_CONFIG_PATH: /tls/tls_worker_config.json`
