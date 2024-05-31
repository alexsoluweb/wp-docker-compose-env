# Attach shell to apache2 container (root or www-data)
docker compose exec -u root apache2 bash
docker compose exec -u www-data apache2 bash

# Attach shell to db container
docker compose exec -u root db bash

# Attach shell to pma container
docker compose exec -u root pma bash

# Build / rebuild containers
docker compose down && docker compose up -d --build

# Custom scripts
docker compose exec -u www-data apache2 bash install-wp.sh
docker compose exec -u www-data apache2 bash update-database.sh
docker compose exec -u www-data apache2 bash backup-database.sh
docker compose exec -u www-data apache2 bash security-check.sh

# List all containers
docker ps -a

# List all images
docker images

# List all volumes
docker volume ls

# Clean all containers and images (WARNING)
docker compose down --rmi all
docker image prune -f

# Clean all volumes (BIG WARNING)
docker volume rm $(docker volume ls -q)

# Restart services
docker compose restart

# Docker logs
docker compose logs db
docker compose logs apache2