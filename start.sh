#!/bin/bash
set -e

echo "Starting HomeCloud Infrastructure..."

# Проверяем, что Docker и Docker Compose установлены
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Проверяем, что git установлен
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git first."
    exit 1
fi

# Клонируем репозитории
echo "Cloning repositories..."
./scripts/clone-repositories.sh

# Подготавливаем dbmanager (генерация gRPC, конфигурация, миграции)
echo "Preparing DBManager service..."
./scripts/prepare-dbmanager.sh

# Генерируем конфигурационные файлы для остальных сервисов
echo "Generating configuration files for other services..."
./scripts/generate-configs.sh

# Останавливаем и удаляем существующие контейнеры
echo "Stopping existing containers..."
docker-compose down

# Удаляем старые образы (опционально)
read -p "Do you want to rebuild all images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebuilding images..."
    docker-compose build --no-cache
else
    echo "Building images..."
    docker-compose build
fi

# Запускаем сервисы
echo "Starting services..."
docker-compose up -d

# Ждем, пока PostgreSQL будет готов
echo "Waiting for PostgreSQL to be ready..."
until docker-compose exec -T postgres pg_isready -U postgres; do
    echo "PostgreSQL is not ready yet. Waiting..."
    sleep 5
done

echo "PostgreSQL is ready!"

# Запускаем миграции
echo "Running database migrations..."
./run-migrations.sh

echo "All services are running!"
echo ""
echo "Service Status:"
docker-compose ps
echo ""
echo "Access URLs:"
echo "   Frontend: http://localhost:3000"
echo "   Auth Service: http://localhost:8080"
echo "   File Service: http://localhost:8081"
echo "   PostgreSQL: localhost:5432"
echo ""
echo "Logs:"
echo "   docker-compose logs -f [service_name]"
echo ""
echo "To stop all services:"
echo "   docker-compose down" 