#!/bin/bash
set -e
source "`dirname $0`/common.sh"

#================================================================
# SYNOPSYS
#================================================================
# This script is used to install Wordpress on remote server.
# Must create the database and user on the remote server first.
#================================================================

WP_ADMIN_USER=''
WP_ADMIN_EMAIL=''
WP_ADMIN_PASS=''
WP_PREFIX=''
DB_NAME=''
DB_USER=''
DB_PASS=''

# # Check required script variables
if [[ -z "$WP_ADMIN_USER" || -z "$WP_ADMIN_EMAIL" || -z "$WP_ADMIN_PASS" || -z "$WP_PREFIX" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
  ERROR "Could not determine Wordpress environment variables. Please verify $_DIR_/.env.sh"
fi

# Check REMOTE_PATH exist
INFO "Checking remote path exist: $REMOTE_PATH"
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "ls -la $REMOTE_PATH" && INFO 'Remote path ok!' || ERROR 'Remote path not ok!'
fi

# # Install Wordpress
INFO "Installing Wordpress..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core download --force --skip-content"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config create --dbname='$DB_NAME' --dbuser='$DB_USER' --dbpass='$DB_PASS' --dbprefix='$WP_PREFIX'"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core install --url='$REMOTE_DOMAIN' --title='$PROJECT_NAME' --admin_user='$WP_ADMIN_USER' --admin_email='$WP_ADMIN_EMAIL' --admin_password='$WP_ADMIN_PASS' --skip-email"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core download --force --skip-content"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config create --dbname='$DB_NAME' --dbuser='$DB_USER' --dbpass='$DB_PASS' --dbprefix='$WP_PREFIX'"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp core install --url='$REMOTE_DOMAIN' --title='$PROJECT_NAME' --admin_user='$WP_ADMIN_USER' --admin_email='$WP_ADMIN_EMAIL' --admin_password='$WP_ADMIN_PASS' --skip-email"
fi

# # Create subdirectories in wp-content and set permissions to 775
INFO "Add folders..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content && chmod 775 wp-content"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/themes && chmod 775 wp-content/themes"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/plugins && chmod 775 wp-content/plugins"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/uploads && chmod 775 wp-content/uploads"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/languages && chmod 775 wp-content/languages"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content && chmod 775 wp-content"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/themes && chmod 775 wp-content/themes"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/plugins && chmod 775 wp-content/plugins"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/uploads && chmod 775 wp-content/uploads"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && mkdir -p wp-content/languages && chmod 775 wp-content/languages"
fi

# # Create debug options
INFO "Create debug options..."
if [ -n "$REMOTE_PASS" ]; then
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG 'true' --raw"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG_DISPLAY 'false' --raw"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set SCRIPT_DEBUG 'true' --raw"
  sshpass -e ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG_LOG \'$REMOTE_PATH/_error.log\' --raw"
else
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG 'true' --raw"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG_DISPLAY 'false' --raw"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set SCRIPT_DEBUG 'true' --raw"
  ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && wp config set WP_DEBUG_LOG \'$REMOTE_PATH/_error.log\' --raw"
fi

# Setup .htaccess
# Check if .htaccess exists remotely, otherwise create it
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "if [ ! -f $REMOTE_PATH/.htaccess ]; then touch $REMOTE_PATH/.htaccess; fi"

# Create a temporary file with WordPress rewrite rules and concatenate the original .htaccess to it
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "cat <<EOL > $REMOTE_PATH/temp.htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
	RewriteEngine On
	RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
	RewriteBase /
	RewriteRule ^index\.php$ - [L]
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOL
cat $REMOTE_PATH/.htaccess >> $REMOTE_PATH/temp.htaccess"

# Rename the temporary file to .htaccess
ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "mv $REMOTE_PATH/temp.htaccess $REMOTE_PATH/.htaccess"