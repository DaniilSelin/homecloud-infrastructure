#!/bin/bash
set -e

echo "Preparing frontend service..."

# Проверяем, что репозиторий существует
if [ ! -d "./services/frontend" ]; then
    echo "Error: Frontend repository not found. Please run clone-repositories.sh first."
    exit 1
fi

# Создаем папку config если её нет
mkdir -p ./services/frontend/config

# Копируем конфигурацию
echo "Copying configuration..."
cp ./config/frontend-config.yml ./services/frontend/config.local.yml

# Копируем nginx конфигурацию
echo "Copying nginx configuration..."
cp ./config/nginx-frontend.conf ./services/frontend/config/nginx.conf

echo "Frontend service prepared successfully!" 