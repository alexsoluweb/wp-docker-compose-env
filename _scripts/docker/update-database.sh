#!/bin/bash

# Proceed?
read -p "This will reset the database... Are you sure? [y/N] " RESET_DB
if [ "$RESET_DB" != "y" ]; then
  echo "Aborting..."
  exit 1
fi

# Reset database
echo "Resetting database..."
wp db reset --yes --skip-plugins --skip-themes

# Chekc if DB_FILENAME was passed as an argument
if [ -n "$1" ]; then
  DB_FILENAME="$1"
else
  # Prompt for the database filename
  read -p "Enter the database filename at $DB_BACKUP_PATH (with extension): " DB_FILENAME
fi

# Check if the db file exists
if [ ! -f $DB_BACKUP_PATH/$DB_FILENAME ]; then
  echo "Database file not found: $DB_BACKUP_PATH/$DB_FILENAME. Aborting..."
  exit 1
fi

# Sync database
echo "Syncing database..."
wp db import $DB_BACKUP_PATH/$DB_FILENAME --skip-plugins --skip-themes

# Search and replace
read -p "Do you want to search and replace the database? [y/N] " SEARCH_REPLACE
if [ "$SEARCH_REPLACE" == "y" ]; then
  source search-replace.sh
fi

# Deactivate production plugins
read -p "Do you want to deactivate production plugins? [y/N] " DEACTIVATE_PLUGINS
if [ "$DEACTIVATE_PLUGINS" == "y" ]; then
	source deactivate-plugins.sh
fi

# Flush cache
echo "Flushing cache..."
wp cache flush \
  --skip-plugins \
  --skip-themes
