#!/usr/bin/env bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to synchronize local database with the remote server.
# Usage: ./update-local-database.sh
#================================================================

# Remember current directory
CURRENT_DIR=$(pwd)
# Set database backup filename
DB_FILENAME="${_NOW_}.sql"

# Prompt to backup local database
read -p "Do you want to backup local database? (y/n): " backup_database
if [[ "$backup_database" == "y" || "$backup_database" == "Y" ]]; then
  INFO "Backup local database..."
  cd "$LOCAL_ROOT_PATH"
  docker compose exec -u www-data apache2 bash backup-database.sh "local-$DB_FILENAME"
  cd "$CURRENT_DIR" # Return to the original directory after the operation

  # Exit if the database backup was not created
  if [ ! -f "$LOCAL_DB_BACKUP_PATH/local-$DB_FILENAME" ]; then
    ERROR "The database backup was not created for some reason. Exiting..."
  fi
fi

# Fetch remote database
INFO "Fetching remote database..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -p $REMOTE_PASS ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table" | cat >"$LOCAL_DB_BACKUP_PATH/remote-$_NOW_.sql"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp db export - --allow-root --skip-plugins --skip-themes --add-drop-table" | cat >"$LOCAL_DB_BACKUP_PATH/remote-$_NOW_.sql"
fi

# Prompt to confirm the local database update
read -p "Do you want to update the local database? (y/n): " update_database
if [[ "$update_database" == "y" || "$update_database" == "Y" ]]; then
  INFO "Updating local database..."
  # Check if the database backup exists
  if [ -f "$LOCAL_DB_BACKUP_PATH/remote-$_NOW_.sql" ]; then
    cd "$LOCAL_ROOT_PATH"
    docker compose exec -u www-data apache2 bash update-database.sh "remote-$_NOW_.sql"
    cd "$CURRENT_DIR" # Return to the original directory after the operation
  else
    ERROR "The remote database backup was not created for some reason. Exiting..."
  fi
fi

INFO "Done update with success"
