#!/bin/bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize the remote server files and database with the local server.
# Usage: ./update-remote.sh
#================================================================

# Check REMOTE_PATH exist
INFO "Checking remote path exist: $REMOTE_PATH"
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
fi

# Build project
if [ "$LOCAL_BUILD_PATH" != "" ]; then
  INFO "Building project..."
	yarn --cwd $LOCAL_BUILD_PATH build
fi

# Updating files
INFO "Updating files..."
if [ -n "$REMOTE_PASS" ]; then
  rsync -ave "sshpass -e ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/themes/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ --exclude-from="$_DIR_/.exclude_files" --delete
  rsync -ave "sshpass -e ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/languages/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/
  rsync -ave "sshpass -e ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/uploads/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/
  rsync -ave "sshpass -e ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/
  # rsync -ave "sshpass -e ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/mu-plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/
else
  rsync -ave "ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/themes/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ --exclude-from="$_DIR_/.exclude_files" --delete
  rsync -ave "ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/languages/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/
  rsync -ave "ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/uploads/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/
  rsync -ave "ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/
  # rsync -ave "ssh -p $REMOTE_PORT" $LOCAL_PATH/wp-content/mu-plugins/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/
fi

INFO "Building project on remote server..."
if [ -z $REMOTE_BUILD_PATH ]; then
  ERROR "REMOTE_BUILD_PATH is not defined!"
fi

# Remove vendor folder and composer.lock
INFO "Removing vendor folder and composer.lock..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_BUILD_PATH && rm -rf vendor && rm composer.lock" && INFO 'Vendor folder and composer.lock removed!' || ERROR 'Vendor folder and composer.lock not removed!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_BUILD_PATH && rm -rf vendor && rm composer.lock" && INFO 'Vendor folder and composer.lock removed!' || ERROR 'Vendor folder and composer.lock not removed!'
fi

# Composer install on remote server
INFO "Composer install on remote server..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_BUILD_PATH && composer install" && INFO 'Composer install ok!' || ERROR 'Composer install not ok!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_BUILD_PATH && composer install" && INFO 'Composer install ok!' || ERROR 'Composer install not ok!'
fi

# Flush remote cache
INFO "Flushing remote cache..."
if [ -n "$REMOTE_PASS" ]; then
    sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
else
    ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
fi