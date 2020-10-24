# Decrypt /secrets/secrets.tgz.aes

## Prerequisites
* bash
* curl
* openssl

## Dockerfile:
```
ADD ./snippets/secrets.tgz.aes/decrypt_secrets.sh /app/decrypt_secrets.sh
```

## Environment
* SECRETSKEY (required)
