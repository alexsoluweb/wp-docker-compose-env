#!/bin/bash

# Prompt for the old domain to search
read -p "What is the old domain to search? (leave empty for $REMOTE_DOMAIN): " old_domain
if [[ "$old_domain" != "" ]]; then
  REMOTE_DOMAIN="$old_domain"
fi

# Prompt for the new domain to replace
read -p "What is the new domain to replace? (leave empty for $LOCAL_DOMAIN): " new_domain
if [[ "$new_domain" != "" ]]; then
  LOCAL_DOMAIN="$new_domain"
fi

# Ask for https or http
read -p "Using https for the local site? ('y' or leave empty for 'no'): " is_https
if [[ "$is_https" == "y" ]]; then
  PROTOCOL="https"
else
  PROTOCOL="http"
fi

# Replace domain
echo "Replacing domain... $REMOTE_DOMAIN -> $LOCAL_DOMAIN"
wp search-replace "https://$REMOTE_DOMAIN" "$PROTOCOL://$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "http://$REMOTE_DOMAIN" "$PROTOCOL://$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "https:\/\/$REMOTE_DOMAIN" "$PROTOCOL:\/\/$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "http:\/\/$REMOTE_DOMAIN" "$PROTOCOL:\/\/$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "https%3A%2F%2F$REMOTE_DOMAIN" "$PROTOCOL%3A%2F%2F$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "http%3A%2F%2F$REMOTE_DOMAIN" "$PROTOCOL%3A%2F%2F$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes
wp search-replace "$REMOTE_DOMAIN" "$LOCAL_DOMAIN" --all-tables --skip-plugins --skip-themes

# Replace the admin email with WP_ADMIN_EMAIL environment variable
echo "Replacing admin email... $WP_ADMIN_EMAIL"
wp option update admin_email "$WP_ADMIN_EMAIL"