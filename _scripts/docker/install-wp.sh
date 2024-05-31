#!/bin/bash
# Will use ENV variables from .env file

# Ask if we run the wp-core-download and wp-core-config commands
read -p "Do you want to run the wp-core-download and wp-core-config commands? (y/n): " run_wp_core
if [[ "$run_wp_core" == "y" || "$run_wp_core" == "Y" ]]; then

    # Prompt for the version to install, if empty, use the latest version
    read -p "Which version of WordPress do you want to install? (leave empty for latest version): " wp_version
    if [[ "$wp_version" == "" ]]; then
        wp_version="latest"
    fi

    # Download WordPress core
    wp core download --version="$wp_version"

    # Create wp-config.php file
    wp core config --dbname="$WP_DB_NAME" --dbuser="$WP_DB_USER" --dbpass="$WP_DB_PASS" --dbhost="$WP_DB_HOST" --dbprefix="$WP_TABLE_PREFIX"
fi

# Check if WordPress database is installed according to wp-config.php
if wp core is-installed; then
    # Ask user for database reset
    read -r -p "WordPress is already installed. Do you want to reset the database? (y/n) "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        wp db reset --yes
    fi
fi

# Install WordPress database
wp core install --url="http://$LOCAL_DOMAIN" --title="$PROJECT_NAME" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email="$WP_ADMIN_EMAIL" --skip-email

# Create debug options
wp config set WP_DEBUG 'true' --raw  
wp config set WP_DEBUG_DISPLAY 'false' --raw  
wp config set SCRIPT_DEBUG 'true' --raw 
wp config set WP_DEBUG_LOG \'/var/www/log/php-error.log\' --raw

# Set WP_ENVIRONMENT_TYPE to development
wp config set WP_ENVIRONMENT_TYPE \'development\' --raw

# Set timezone
wp option update timezone_string 'America/New_York'

# Set language
wp language core install fr_CA

# Ask to set permalink structure to /%postname%/
read -p "Do you want to set the permalink structure to /%postname%/? (y/n): " set_permalink
if [[ "$set_permalink" == "y" || "$set_permalink" == "Y" ]]; then
    wp rewrite structure '/%postname%/'
fi

# Ask if we run wp rewrite flush --hard  to create the .htaccess file
read -p "Do you want to run wp rewrite flush --hard to create the .htaccess file? (y/n): " run_wp_htaccess
if [[ "$run_wp_htaccess" == "y" || "$run_wp_htaccess" == "Y" ]]; then
    wp rewrite flush --hard
fi

# Add Wordpress wp-content directories
mkdir -p /var/www/html/wp-content/plugins && chmod 755 /var/www/html/wp-content/plugins
mkdir -p /var/www/html/wp-content/mu-plugins && chmod 755 /var/www/html/wp-content/mu-plugins
mkdir -p /var/www/html/wp-content/languages && chmod 755 /var/www/html/wp-content/languages
mkdir -p /var/www/html/wp-content/themes && chmod 755 /var/www/html/wp-content/themes
mkdir -p /var/www/html/wp-content/uploads && chmod 755 /var/www/html/wp-content/uploads

# Success message
echo "WordPress installed successfully!"