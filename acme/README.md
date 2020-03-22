# ACME - snippet to obtain let´s encrpyt certificates authenticated by DNS-01

## Dockerfile:
```
ADD ./snippets/acme/dehydrated /dehydrated/
ADD ./snippets/acme/config /dehydrated/config
ADD ./snippets/acme/get_cert_ddns01.sh /app/get_cert_ddns01.sh
ADD ./snippets/acme/zwackl_hook.sh /app/zwackl_hook.sh
```
**Do not forget to include the cron snippet!**

## Cronjob
`/etc/periodic/daily/acme`:
```
#!/bin/bash

. /cron_env && /dehydrated/dehydrated --cron -t dns-01 -k /app/zwackl_hook.sh && ${ACME_RELOAD_CMD}
```

## Environment
* ACME_FQDNS (required)
* ACME_RELOAD_CMD (required)
* ACME_STAGING_ENABLED (optional)
* STAGING_URI (optional)
* DDNS01URI (required)
* DDNS01KEY (required)
