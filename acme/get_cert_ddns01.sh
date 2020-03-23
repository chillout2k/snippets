#!/bin/bash

# ACME@LETSENCRYPT - DEHYDRATED
if [ ! -z "${ACME_FQDNS+x}" ]; then
  if [ -f /dehydrated/lock ]; then
    unlink /dehydrated/lock
  fi
  if [ -z "${ACME_RELOAD_CMD}" ]; then
    echo "ENV[ACME_RELOAD_CMD] is mandatory!"
    exit 1
  fi
  if [ ! -d /secrets/ssl ]; then
    install -d -m 775 /secrets/ssl
  fi
  if [ ! -z "${ACME_STAGING_ENABLED+x}" ]; then
    STAGING_URI='CA="https://acme-staging-v02.api.letsencrypt.org/directory"' \
    ESCAPED=$(echo "${STAGING_URI}" | sed -e 's/\//\\\//g')
    sed -i -e "s/%STAGING%/${ESCAPED}/g" /dehydrated/config
  else
    sed -i -e "s/%STAGING%//g" /dehydrated/config
  fi
  if [ ! -z "${DDNS01URI+x}" ]; then
    ESCAPED=$(echo "${DDNS01URI}" | sed -e 's/\//\\\//g')
    sed -i -e "s/%DDNS01URI%/${ESCAPED}/g" /app/zwackl_hook.sh
  else
    echo "ENV[DDNS01URI] is mandatory!"
    exit 1
  fi
  if [ ! -z "${DDNS01KEY+x}" ]; then
    ESCAPED=$(echo "${DDNS01KEY}" | sed -e 's/\//\\\//g')
    sed -i -e "s/%DDNS01KEY%/${ESCAPED}/g" /app/zwackl_hook.sh
  else
    echo "ENV[DDNS01KEY] is mandatory!"
    exit 1
  fi
  if [ -d /dehydrated ]; then
    ONELINE=''
    if [ ! -z "${DDNS01_ONECERT}" ]; then
      ONELINE='-n'
    fi
    echo -n "" > /dehydrated/domains.txt
    for fqdn in ${ACME_FQDNS}; do
      echo "${fqdn}"
      echo "${ONELINE}" "${fqdn} " >> /dehydrated/domains.txt
      if [ ! -d "/secrets/ssl/${fqdn}" ]; then
        install -d -m 775 "/secrets/ssl/${fqdn}"
      fi
    done
    if [ ! -z "${ONELINE}" ]; then
      echo "" >> /dehydrated/domains.txt
    fi
    chmod +x /app/zwackl_hook.sh
    if [ -z "$(ls -A /dehydrated/accounts)" ]; then
      cd /dehydrated && /dehydrated/dehydrated --register --accept-terms
    fi
    RUN_DEHYDRATED=''
    for fqdn in ${ACME_FQDNS}; do
      if [ ! -f "/dehydrated/certs/${fqdn}/fullchain.pem" ]; then
        RUN_DEHYDRATED='yes'
      fi
      ln -f -s "/dehydrated/certs/${fqdn}/privkey.pem" "/secrets/ssl/${fqdn}/key.pem"
      ln -f -s "/dehydrated/certs/${fqdn}/fullchain.pem" "/secrets/ssl/${fqdn}/cert.pem"
    done
    if [ ! -z "${RUN_DEHYDRATED}" ]; then
      /dehydrated/dehydrated --cron -t dns-01 -k /app/zwackl_hook.sh
    fi
    export CROND_ENABLE='acme'
    chmod -R +x /dehydrated/certs
  else
    echo "Directory /dehydrated not found!"
    exit 1
  fi
fi

