#!/usr/bin/env bash
set -e

# Set the backup directory
DB_DIR=$DB_BACKUP_PATH
mkdir -p $DB_DIR

# Get the current date and time
_NOW_=$(date +"%Y-%m-%d__%H-%M")

# Get the filename from the first argument, or use the current date and time
DB_FILENAME=${1:-"local-$_NOW_.sql"}

FULL_PATH="$DB_DIR/$DB_FILENAME"

# Backup database
wp db export "$FULL_PATH" --skip-plugins --skip-themes --add-drop-table
