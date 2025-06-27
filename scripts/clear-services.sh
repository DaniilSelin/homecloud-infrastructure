#!/bin/bash
set -e

echo "Очистка папки services..."

# Проверяем, что мы в правильной директории
if [ ! -d "services" ]; then
    echo "Папка services не найдена. Убедитесь, что вы находитесь в корневой директории инфраструктуры."
    exit 1
fi

# Останавливаем все контейнеры
echo "Остановка всех контейнеров..."
docker-compose down -v 2>/dev/null || true

# Удаляем все контейнеры
echo "Удаление всех контейнеров..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Очищаем Docker ресурсы
echo "Очистка Docker ресурсов..."
docker network prune -f
docker volume prune -f
docker image prune -a -f

# Удаляем содержимое папки services
echo "Удаление содержимого папки services..."
rm -rf services/*

# Создаем .gitkeep для сохранения папки в git
echo "Создание .gitkeep файла..."
touch services/.gitkeep

echo "Очистка завершена успешно!"
echo "Папка services теперь пуста и готова для клонирования новых репозиториев." 