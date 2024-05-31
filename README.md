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
    docker-compose up --build
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

### Usage

Access your local WordPress site at `http://localhost`.

### Customization

Modify the `docker-compose.yml` and related configuration files to suit your specific needs.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.