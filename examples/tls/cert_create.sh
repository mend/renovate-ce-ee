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
