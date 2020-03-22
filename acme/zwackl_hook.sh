#!/bin/bash

function deploy_challenge {
    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file is irrelevant for the DNS challenge, yet still provided 
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo;
    echo "Deploying challenge for domain $DOMAIN: $TOKEN_VALUE"
    CMD_OUT=$(/usr/bin/curl -s --noproxy '*' "%DDNS01URI%/update?fqdn=_acme-challenge.${DOMAIN}&txtdata=${TOKEN_VALUE}&key=%DDNS01KEY%")
    if [ $? -ne 0 ]
      then
        echo "${DOMAIN} -> ${TOKEN_VALUE}: ${CMD_OUT}"
        exit 1;
      else
        echo "OK: ${CMD_OUT}"
    fi

    echo "Sleeping for 66 seconds to avoid timing conflicts"
    sleep 66
}


function clean_challenge {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    echo;
    echo "Cleaning challenge for domain $DOMAIN"
    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.
}


function deploy_cert {
    # This hook is called once for each certificate that has been
    # produced. Here you might, for instance, copy your new certificates
    # to service-specific locations and reload the service.
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"
}

function unchanged_cert {
    # This hook is called once for each certificate that is still valid at least 30 days
    #
    # Parameters:
    # - DOMAIN
    #   The primary domain name, i.e. the certificate common
    #   name (CN).
    # - KEYFILE
    #   The path of the file containing the private key.
    # - CERTFILE
    #   The path of the file containing the signed certificate.
    # - FULLCHAINFILE
    #   The path of the file containing the full certificate chain.
    # - CHAINFILE
    #   The path of the file containing the intermediate certificate(s).
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}"

    echo "Certificate for domain $DOMAIN is still valid - no action taken"
}

generate_csr() {
    local DOMAIN="${1}" CERTDIR="${2}" ALTNAMES="${3}"
}

startup_hook() {
  # This hook is called before the cron command to do some initial tasks
  # (e.g. starting a webserver).

  :
}

exit_hook() {
  # This hook is called at the end of the cron command and can be used to
  # do some final (cleanup or other) tasks.

  :
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert|unchanged_cert|invalid_challenge|request_failure|generate_csr|startup_hook|exit_hook)$ ]]; then
  "$HANDLER" "$@"
fi

