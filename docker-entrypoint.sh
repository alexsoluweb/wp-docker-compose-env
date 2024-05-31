#!/bin/bash
set -e

# Set umask to 022 to ensure permissions of 755 for directories and 644 for files
umask 022

# Set APACHE2 log files ownership to www-data
touch "$APACHE_LOG_DIR/access.log" && chown -R www-data:www-data  "$APACHE_LOG_DIR/access.log"
touch "$APACHE_LOG_DIR/error.log" && chown -R www-data:www-data  "$APACHE_LOG_DIR/error.log"

# Stop apache2 from writing log to this file
a2disconf other-vhosts-access-log

# Start cron in the background
cron &

# Start Apache in the foreground, replacing this shell with Apache
exec /usr/sbin/apache2ctl -D FOREGROUND
