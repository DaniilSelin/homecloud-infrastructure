#!/bin/bash
set -e

echo "Starting database migrations..."

# Ждем, пока PostgreSQL будет готов
echo "Waiting for PostgreSQL to be ready..."
until docker-compose exec -T postgres pg_isready -U postgres; do
  echo "PostgreSQL is not ready yet. Waiting..."
  sleep 2
done

echo "PostgreSQL is ready!"

# Запускаем миграции для dbmanager
echo "Running DBManager migrations..."
docker-compose exec -T dbmanager /app/run-migrations.sh

echo "All migrations completed successfully!" 