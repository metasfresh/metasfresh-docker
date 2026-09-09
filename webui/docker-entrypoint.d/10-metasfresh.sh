#!/bin/sh
# Patch config.js, set the webapi upstream, and enable SSL if certs are mounted.
set -eu

DIST=/opt/metasfresh-webui-frontend/dist
CONF_D=/etc/nginx/conf.d
CERT_DIR=/etc/nginx/certs

if [ -n "${WEBAPI_URL:-}" ]; then
    sed -i "s,http://MYDOCKERHOST:PORT,${WEBAPI_URL},g" "$DIST/config.js"
    sed -i "s,http://MYDOCKERHOST:PORT,${WEBAPI_URL},g" "$DIST/mobile/config.js"
fi

# Default plain HTTP; override with WEBAPI_UPSTREAM (e.g. https://webapi:8443).
sed -i "s|__WEBAPI_UPSTREAM__|${WEBAPI_UPSTREAM:-http://webapi:8080}|g" \
    /etc/nginx/snippets/metasfresh-locations.conf

CERT="$CERT_DIR/fullchain.pem"
KEY="$CERT_DIR/privkey.pem"

if [ ! -e "$CERT" ] && [ ! -e "$KEY" ]; then
    rm -f "$CONF_D/webui-ssl.conf"
    echo "[METASFRESH] Running Non-SSL!"
else
    [ -e "$CERT" ] || { echo "[METASFRESH] FATAL: privkey.pem present but fullchain.pem missing"; exit 1; }
    [ -e "$KEY" ]  || { echo "[METASFRESH] FATAL: fullchain.pem present but privkey.pem missing"; exit 1; }
    [ -s "$CERT" ] || { echo "[METASFRESH] FATAL: fullchain.pem is empty"; exit 1; }
    [ -s "$KEY" ]  || { echo "[METASFRESH] FATAL: privkey.pem is empty"; exit 1; }

    # Match key and cert by public key (RSA and EC).
    cert_pub=$(openssl x509 -in "$CERT" -noout -pubkey 2>/dev/null) \
        || { echo "[METASFRESH] FATAL: fullchain.pem is not a valid certificate"; exit 1; }
    key_pub=$(openssl pkey -in "$KEY" -pubout 2>/dev/null) \
        || { echo "[METASFRESH] FATAL: privkey.pem is not a valid private key"; exit 1; }
    [ "$cert_pub" = "$key_pub" ] \
        || { echo "[METASFRESH] FATAL: privkey.pem does not match fullchain.pem"; exit 1; }

    # Expiry is a warning only; an expired cert still serves.
    if ! openssl x509 -in "$CERT" -noout -checkend 0 >/dev/null 2>&1; then
        echo "[METASFRESH] WARNING: fullchain.pem is EXPIRED"
    elif ! openssl x509 -in "$CERT" -noout -checkend 2592000 >/dev/null 2>&1; then
        echo "[METASFRESH] WARNING: fullchain.pem expires within 30 days"
    fi

    cp "$CONF_D/webui-ssl.conf.disabled" "$CONF_D/webui-ssl.conf"
    sed -i 's/\bhttp\b/https/g' "$DIST/config.js" "$DIST/mobile/config.js"
    nginx -t || { echo "[METASFRESH] FATAL: nginx config test failed"; exit 1; }
    echo "[METASFRESH] Activated SSL!"
fi
