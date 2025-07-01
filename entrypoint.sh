#!/bin/sh

set -e

CONFIG_TEMPLATE="/srv/ossftp/config.template.json"
CONFIG_FINAL="/srv/ossftp/config.json"

# Prepare default config
cp "$CONFIG_TEMPLATE" "$CONFIG_FINAL"

# If ACCOUNTS_JSON is provided, use it directly
if [ -n "$ACCOUNTS_JSON" ]; then
  echo "Using ACCOUNTS_JSON to set accounts"
  jq --argjson accounts "$ACCOUNTS_JSON" '.modules.accounts = $accounts' "$CONFIG_FINAL" > "$CONFIG_FINAL.tmp" && mv "$CONFIG_FINAL.tmp" "$CONFIG_FINAL"

# Or use individual ACCOUNT_XXX variables
elif [ -n "$ACCOUNT_LOGIN_USERNAME" ]; then
  echo "Using single ACCOUNT_* env vars to set one account"

  jq --arg access_id "$ACCOUNT_ACCESS_ID" \
     --arg access_secret "$ACCOUNT_ACCESS_SECRET" \
     --arg bucket_name "$ACCOUNT_BUCKET_NAME" \
     --arg home_dir "$ACCOUNT_HOME_DIR" \
     --arg login_password "$ACCOUNT_LOGIN_PASSWORD" \
     --arg login_username "$ACCOUNT_LOGIN_USERNAME" \
     '.modules.accounts = [
        {
          access_id: $access_id,
          access_secret: $access_secret,
          bucket_name: $bucket_name,
          home_dir: $home_dir,
          login_password: $login_password,
          login_username: $login_username
        }
      ]' "$CONFIG_FINAL" > "$CONFIG_FINAL.tmp" && mv "$CONFIG_FINAL.tmp" "$CONFIG_FINAL"
else
  echo "No ACCOUNTS_JSON or ACCOUNT_* vars provided; using default accounts"
fi

# Run the main app
exec "$@"
