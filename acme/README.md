# ACME - snippet to obtain let´s encrpyt certificates authenticated by DNS-01

## Prerequisites
* bash
* curl
* openssl
* cron

## Dockerfile:
```
ADD ./snippets/acme/dehydrated /dehydrated/
ADD ./snippets/acme/config /dehydrated/config
ADD ./snippets/acme/get_cert_ddns01.sh /app/get_cert_ddns01.sh
ADD ./snippets/acme/zwackl_hook.sh /app/zwackl_hook.sh
ADD ./snippets/acme/cronjob.daily /etc/periodic/daily/acme
```
**Do not forget to include the cron snippet!**

## Environment
* ACME_FQDNS (required)
* ACME_RELOAD_CMD (required)
* ACME_STAGING_ENABLED (optional)
* STAGING_URI (optional)
* DDNS01URI (required)
* DDNS01KEY (required)
* DDNS01_ONECERT (optional)
