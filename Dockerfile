###################
ARG PHP_VERSION
FROM php:${PHP_VERSION}-apache
ARG PHP_VERSION
###################
ENV APACHE2_UID 1000
ENV APACHE2_GID 1000
ENV WORDFENCE_VERSION 3.0.1
###################

# Install apt packages
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    # clamav clamav-daemon clamav-freshclam \
    default-mysql-client \
    libmagickwand-dev \
    libwebp-dev \
    libzip-dev \
    imagemagick \
    nano \
    less \
    wget \
    libpcre3-dev \
    cron

# Install and enable PHP mysqli extension
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Install and enbale PHP PDO_MySQL extensions
RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql

# Install and enable PHP GD extension
RUN docker-php-ext-configure gd --with-webp=/usr/include/ --with-jpeg=/usr/include/ && docker-php-ext-install gd && docker-php-ext-enable gd

# Install and enable PHP zip extension
RUN docker-php-ext-install zip && docker-php-ext-enable zip

# Install and enable PHP exif extension
RUN docker-php-ext-install exif && docker-php-ext-enable exif

# Install and enable PHP intl extension
RUN docker-php-ext-install intl && docker-php-ext-enable intl

# Based on the PHP_VERSION, install xdebug-3.0.4 for PHP 7.4 or the latest version for other PHP versions
RUN if [ ${PHP_VERSION} = "7.4" ]; then \
    pecl install xdebug-3.0.4 && docker-php-ext-enable xdebug; \
    else \
    pecl install xdebug && docker-php-ext-enable xdebug; \
    fi

# Install and enable PHP imagick extension 
RUN pecl install imagick && docker-php-ext-enable imagick

# Install and enable PHP opcache extension
RUN docker-php-ext-install opcache && docker-php-ext-enable opcache

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp 

# Install Wordfence CLI
# RUN wget "https://github.com/wordfence/wordfence-cli/releases/download/v${WORDFENCE_VERSION}/wordfence_amd64.tar.gz"
# RUN tar xvzf wordfence_amd64.tar.gz && mv wordfence /usr/local/bin/ && rm wordfence_amd64.tar.gz

# Enable Apache modules
RUN a2enmod rewrite expires headers ssl && a2ensite 000-default

# Change ownership of web root files
RUN set -ex && \
    chown -R www-data:www-data /var/www /tmp \
    && usermod --non-unique --uid ${APACHE2_UID} www-data \
    && groupmod --non-unique --gid ${APACHE2_GID} www-data

# Set user to www-data
USER www-data

# Create the wp-cli.yml file with the mod_rewrite module enabled (this is needed for the wp rewrite flush command)
RUN echo "apache_modules:\n  - mod_rewrite" > /var/www/wp-cli.yml

# Set user back to root
USER root

# Generate a self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/localhost.key \
    -out /etc/ssl/certs/localhost.crt \
    -subj "/CN=localhost"

# Update clamav database
# RUN freshclam

# Add docker scripts to $PATH
ENV PATH /usr/local/bin/scripts/docker:$PATH

# Add /var/www/log directory
RUN mkdir -p /var/www/log && chown -R www-data:www-data /var/www/log

# --------------------------------------------------------------------------------------------------->
WORKDIR /var/www/html
EXPOSE 80
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
