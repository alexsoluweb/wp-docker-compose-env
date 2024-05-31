# WP Docker Compose Environment

This repository sets up a Docker-based environment for WordPress development. It includes configurations for PHP, MySQL, and other necessary services, aiming to streamline your development workflow.

## Getting Started

### Prerequisites

Ensure you have the following installed:
- Docker
- Docker Compose

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/alexsoluweb/wp-docker-compose-env.git
    cd wp-docker-compose-env
    ```

2. Edit the `.env` file to match your project settings. The file contains placeholders that need to be replaced with actual values.

3. Build and start the Docker containers:
    ```sh
    docker compose up -d --build
    ```

4. Install WordPress:
    ```sh
    docker compose exec -u www-data apache2 bash install-wp.sh
    ```

### Folder Structure

- `_backups`: Backup files
- `_config`: Configuration files
- `_logs`: Log files
- `_scripts`: Custom scripts
- `_tmp`: Temporary files
- `public`: Public web root (WordPress files go here)

### Environment Variables

Edit the `.env` file with your specific configuration:

- `COMPOSE_PROJECT_NAME`: Project name
- `LOCAL_DOMAIN`: Local development domain
- `REMOTE_DOMAIN`: Remote production domain
- `WP_ADMIN_USER`: WordPress admin username
- `WP_ADMIN_PASS`: WordPress admin password
- `WP_ADMIN_EMAIL`: WordPress admin email
- `WP_DB_NAME`: Database name
- `WP_DB_USER`: Database user
- `WP_DB_PASS`: Database password
- `WP_TABLE_PREFIX`: Table prefix
- `WORDFENCE_API_KEY`: Wordfence API key
- `DB_ROOT_PASS`: MySQL root password
- `DB_BACKUP_PATH`: Path for database backups
- `PHP_VERSION`: PHP version to use (7.4, 8.0, 8.1, 8.2)

### Docker Commands

```sh
# Bring Down the Containers
docker compose down

# Restart the Containers
docker compose restart

# Build and Start the Containers
docker compose down && docker compose up -d --build

# Attach to Apache Shell
docker compose exec -u root apache2 bash # As root
docker compose exec -u www-data apache2 bash # As www-data

# Attach to DB Shell
docker compose exec -u root db bash

# Attach to PMA Shell
docker compose exec -u root pma bash

# Install WordPress
docker compose exec -u www-data apache2 bash install-wp.sh

# Search and Replace in Database
docker compose exec -u www-data apache2 bash search-replace.sh

# Update Database
docker compose exec -u www-data apache2 bash update-database.sh

# Backup Database
docker compose exec -u www-data apache2 bash backup-database.sh

# Perform Security Scan
docker compose exec -u www-data apache2 bash security-scan.sh

# Start Cron Service
docker compose exec -u root apache2 service cron start

# Stop Cron Service
docker compose exec -u root apache2 service cron stop

# View container log
docker compose logs -f [container_name]
```

### Usage

Access your local WordPress site at `http://localhost`.

### Customization

Modify the `docker-compose.yml` and related configuration files to suit your specific needs.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
