#!/usr/bin/with-contenv bashio
# Freehold Captive Portal — add-on entrypoint.
# Reads add-on options into the env the bundled server expects, then execs node.

set -e

export PORT=8099
export PORTAL_CONTROLLER_VENDOR="unifi"
export UNIFI_HOST="$(bashio::config 'unifi_host')"
export UNIFI_SITE="$(bashio::config 'unifi_site')"
export UNIFI_USERNAME="$(bashio::config 'unifi_username')"
export UNIFI_PASSWORD="$(bashio::config 'unifi_password')"
export FREEHOLD_ORG_ID="$(bashio::config 'org_id')"
export PORTAL_SSID_MAP="$(bashio::config 'ssid_map')"
export PORTAL_AUTHORIZE_MINUTES="$(bashio::config 'authorize_minutes')"

if bashio::config.true 'unifi_verify_tls'; then
  export UNIFI_VERIFY_TLS="1"
else
  export UNIFI_VERIFY_TLS="0"
fi

if bashio::config.has_value 'default_property_id'; then
  export PORTAL_DEFAULT_PROPERTY_ID="$(bashio::config 'default_property_id')"
fi

export PORTAL_BRANDING="$(jq -n \
  --arg n "$(bashio::config 'property_name')" \
  --arg c "$(bashio::config 'primary_color')" \
  '{propertyName:$n, primaryColor:$c}')"

bashio::log.info "Starting Freehold Captive Portal on :${PORT} (controller ${UNIFI_HOST})"
exec node /usr/src/portal-server.cjs
