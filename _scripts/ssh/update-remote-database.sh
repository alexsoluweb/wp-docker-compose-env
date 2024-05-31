#!/bin/bash
set -e
source "$(dirname $0)/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to update remote database.
# Usage: ./update-remote-database.sh
#================================================================

# Ask to create a database backup
read -p "Do you want to create a remote database backup? (y/n): " create_backup
if [[ "$create_backup" == "y" || "$create_backup" == "Y" ]]; then
	INFO "Creating database backup..."

	# Check if REMOTE_DB_BACKUP_PATH is set
	if [ -z "$REMOTE_DB_BACKUP_PATH" ]; then
		echo "The REMOTE_BACKUP_DIR environment variable is not set. Exiting..."
		exit 1
	fi

    # Proceed the database backup
    if [ -n "$REMOTE_PASS" ]; then
        sshpass -e ssh -p "$REMOTE_PORT" "$REMOTE_USER"@"$REMOTE_HOST" "mkdir -p \"$REMOTE_DB_BACKUP_PATH\""
        sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db export - --skip-plugins --skip-themes --add-drop-table > $REMOTE_DB_BACKUP_PATH/$_NOW_.sql"
    else
        ssh -p "$REMOTE_PORT" "$REMOTE_USER"@"$REMOTE_HOST" "mkdir -p \"$REMOTE_DB_BACKUP_PATH\""
        ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db export - --skip-plugins --skip-themes --add-drop-table > $REMOTE_DB_BACKUP_PATH/$_NOW_.sql"
    fi

	# Check last command exit status, if it's 0 then the backup was created successfully
	if [ $? -eq 0 ]; then
		echo "Database backup was created successfully."
	else
		echo "Failed to create database backup. Exiting..."
		exit 1
	fi
fi

# Ask for flushing the database
read -p "Do you want to flush the remote database before updating? (y/n): " flush_db
if [[ "$flush_db" == "y" || "$flush_db" == "Y" ]]; then
	INFO "Flushing the database..."
	if [ -n "$REMOTE_PASS" ]; then
		sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db reset --yes"
	else
		ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db reset --yes"
	fi
fi

# Dump local database
INFO "Dumping local database..."
CURRENT_DIR=$(pwd)
cd "$LOCAL_ROOT_PATH"
DB_FILENAME="local-${_NOW_}.sql"
docker compose exec -u www-data apache2 bash backup-database.sh "$DB_FILENAME"
cd "$CURRENT_DIR" # Return to the original directory after the operation

# Update remote database
INFO "Updating remote database..."
if [ -n "$REMOTE_PASS" ]; then
	cat $LOCAL_DB_BACKUP_PATH/$DB_FILENAME | sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db import -"
else
	cat $LOCAL_DB_BACKUP_PATH/$DB_FILENAME | ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp db import -"
fi

# Prompt for the old domain to search
read -p "What is the old domain to search? (leave empty for $LOCAL_DOMAIN): " old_domain
if [[ "$old_domain" != "" ]]; then
	LOCAL_DOMAIN="$old_domain"
fi

# Prompt for the new domain to replace
read -p "What is the new domain to replace? (leave empty for $REMOTE_DOMAIN): " new_domain
if [[ "$new_domain" != "" ]]; then
	REMOTE_DOMAIN="$new_domain"
fi

# Update domain
INFO "Replacing domain $LOCAL_DOMAIN => $REMOTE_DOMAIN..."
if [ -n "$REMOTE_PASS" ]; then
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	LOCAL_DOMAIN='localhost:3005'
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
else
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	LOCAL_DOMAIN='localhost:3005'
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http://$LOCAL_DOMAIN' 'https://$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http:\/\/$LOCAL_DOMAIN' 'https:\/\/$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace 'http%3A%2F%2F$LOCAL_DOMAIN' 'https%3A%2F%2F$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
	ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp search-replace '$LOCAL_DOMAIN' '$REMOTE_DOMAIN' --all-tables --skip-plugins --skip-themes"
fi

# Flush remote cache
INFO "Flushing remote cache..."
if [ -n "$REMOTE_PASS" ]; then
    sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
else
    ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH; wp cache flush"
fi