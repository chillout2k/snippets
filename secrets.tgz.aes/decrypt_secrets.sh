#!/bin/sh

if [ -z "${SECRETSKEY+x}" ]; then
  echo "ENV[SECRETSKEY] not set! Continue without secrets..."
else
  if [ -f /secrets/secrets.tgz.aes ]; then
    cd /secrets \
    && openssl aes-256-cbc -in secrets.tgz.aes -out secrets.tgz -d -k "${SECRETSKEY}" \
    && tar xvzf secrets.tgz
  else
    echo "/secrets/secrets.tgz.aes not found!"
    exit 1
  fi
fi
