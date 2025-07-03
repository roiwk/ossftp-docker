#!/bin/sh
set -e

CONFIG_TEMPLATE="/srv/ossftp/config.template.json"
CONFIG_FINAL="/srv/ossftp/config.json"


# ✅ 若用户已挂载 config.json，则跳过生成步骤
if [ -f "$CONFIG_FINAL" ] && [ ! -f "$CONFIG_TEMPLATE" ]; then
  echo "Detected mounted config.json, skipping environment-based generation."
  exec "$@"
fi

# Prepare default config
cp "$CONFIG_TEMPLATE" "$CONFIG_FINAL"

# Inject accounts from JSON or env
if [ -n "$ACCOUNTS_JSON" ]; then
  echo "Using ACCOUNTS_JSON to set accounts"
  jq --argjson accounts "$ACCOUNTS_JSON" \
    '.modules.accounts = $accounts' \
    "$CONFIG_FINAL" > "$CONFIG_FINAL.tmp" && mv "$CONFIG_FINAL.tmp" "$CONFIG_FINAL"

elif [ -n "$ACCOUNT_LOGIN_USERNAME" ]; then
  echo "Using ACCOUNT_* env vars to set single account"
  jq --arg access_id "$ACCOUNT_ACCESS_ID" \
     --arg access_secret "$ACCOUNT_ACCESS_SECRET" \
     --arg bucket_name "$ACCOUNT_BUCKET_NAME" \
     --arg home_dir "$ACCOUNT_HOME_DIR" \
     --arg login_password "$ACCOUNT_LOGIN_PASSWORD" \
     --arg login_username "$ACCOUNT_LOGIN_USERNAME" \
     '.modules.accounts = [{
        access_id: $access_id,
        access_secret: $access_secret,
        bucket_name: $bucket_name,
        home_dir: $home_dir,
        login_password: $login_password,
        login_username: $login_username
     }]' \
     "$CONFIG_FINAL" > "$CONFIG_FINAL.tmp" && mv "$CONFIG_FINAL.tmp" "$CONFIG_FINAL"
else
  echo "Using default accounts from template"
fi

# Optional overrides for OSSFTP config
BUCKET_ENDPOINTS=${BUCKET_ENDPOINTS:-""}
LOG_LEVEL=${LOG_LEVEL:-"INFO"}

jq --arg endpoints "$BUCKET_ENDPOINTS" \
   --arg loglevel "$LOG_LEVEL" \
   '.modules.ossftp.bucket_endpoints = $endpoints |
    .modules.ossftp.log_level = $loglevel' \
   "$CONFIG_FINAL" > "$CONFIG_FINAL.tmp" && mv "$CONFIG_FINAL.tmp" "$CONFIG_FINAL"

# Start the main process
exec "$@"
