#!/bin/bash
set -e

echo "Stopping HomeCloud Infrastructure..."

# Останавливаем и удаляем контейнеры
docker-compose down

echo "All services stopped!"

# Опционально удаляем volumes (данные будут потеряны)
read -p "Do you want to remove volumes (this will delete all data)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing volumes..."
    docker-compose down -v
    echo "Volumes removed!"
fi

echo "HomeCloud Infrastructure stopped successfully!" 