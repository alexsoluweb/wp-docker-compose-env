# Docker Commands

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