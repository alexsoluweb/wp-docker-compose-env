#!/bin/bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is for miscellaneous tasks on the remote server.
# Usage: ./update-remote-other.sh
#================================================================

# Check REMOTE_PATH exist
INFO "Checking remote path exist: $REMOTE_PATH"
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
fi

# List of plugins to deactivate
PLUGINS=(
  better-wp-security
  ithemes-security-pro
  all-in-one-wp-security-and-firewall
  wordfence
  wp-offload-ses
  wp-mail-smtp
  wp-mail-smtp-pro
  wp-rocket
  wp-optimize
  litespeed-cache
  login-lockdown
  akismet
  wp-super-cache
  wp-super-minify
  wp-fastest-cache
  wp-fastest-cache-premium
  worker
  google-site-kit
)

# Convert plugin list into a space-separated string
PLUGIN_LIST="${PLUGINS[@]}"

# Deactivate plugins
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp plugin deactivate --allow-root --skip-plugins --skip-themes $PLUGIN_LIST"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp plugin deactivate --allow-root --skip-plugins --skip-themes $PLUGIN_LIST"
fi

# Change file permissions to 644 for files and 755 for directories
INFO "Change file permissions..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "find $REMOTE_PATH -type f -exec chmod 644 {} \;"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "find $REMOTE_PATH -type d -exec chmod 755 {} \;"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "find $REMOTE_PATH -type f -exec chmod 644 {} \;"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "find $REMOTE_PATH -type d -exec chmod 755 {} \;"
fi

# flush cache
INFO "Flushing cache..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
fi
