#!/bin/bash

set -e

echo "Запуск всех сервисов HomeCloud..."

# Проверяем, что docker-compose.yml существует
if [ ! -f "docker-compose.yml" ]; then
    echo "docker-compose.yml не найден. Убедитесь, что вы находитесь в корневой директории инфраструктуры."
    exit 1
fi

# Останавливаем существующие контейнеры
echo "Остановка существующих контейнеров..."
docker-compose down

# Запускаем все сервисы
echo "Запуск сервисов..."
docker-compose up -d

# Ждем немного для инициализации
echo "Ожидание инициализации сервисов..."
sleep 10

# Показываем статус
echo "Статус контейнеров:"
docker-compose ps

echo ""
echo "Сервисы запущены:"
echo "- PostgreSQL: localhost:5432"
echo "- DBManager: localhost:50051"
echo "- Auth Service: localhost:8080 (HTTP), localhost:50052 (gRPC)"
echo ""
echo "Для просмотра логов используйте:"
echo "  docker-compose logs -f [service_name]"
echo ""
echo "Для остановки всех сервисов:"
echo "  docker-compose down" 