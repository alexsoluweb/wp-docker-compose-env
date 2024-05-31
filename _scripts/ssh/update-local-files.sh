#!/usr/bin/env bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize local files with the remote server.
# Usage: ./update-local-files.sh
#================================================================

# Check REMOTE_PATH exist
INFO "Checking remote path exist: $REMOTE_PATH"
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
fi

# Synchronize files
INFO "Synchronizing files..."
if [ -n "$REMOTE_PASS" ]; then
    sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ $LOCAL_PATH/wp-content/plugins/
    sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ $LOCAL_PATH/wp-content/mu-plugins/
    sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ $LOCAL_PATH/wp-content/themes/
    sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ $LOCAL_PATH/wp-content/uploads/
    sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ $LOCAL_PATH/wp-content/languages/

	# Update all files
	# sshpass -e rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/ $LOCAL_PATH/ --delete
else
    rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/plugins/ $LOCAL_PATH/wp-content/plugins/
    rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/mu-plugins/ $LOCAL_PATH/wp-content/mu-plugins/
    rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/themes/ $LOCAL_PATH/wp-content/themes/
    rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/uploads/ $LOCAL_PATH/wp-content/uploads/
    rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/wp-content/languages/ $LOCAL_PATH/wp-content/languages/

	# Update all files
	# rsync -ave "ssh -p $REMOTE_PORT" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/ $LOCAL_PATH/ --delete
fi

INFO "Done update with success"
