#!/bin/bash

set -e

echo "Подготовка file-service..."

# Создаем папку storage в корне с правами для всех
echo "Создание папки storage..."
mkdir -p storage
chmod 777 storage

# Переходим в директорию file-service
cd services/file-service

# Проверяем, что директория существует
if [ ! -d "." ]; then
    echo "Директория file-service не найдена. Сначала клонируйте репозиторий."
    exit 1
fi

echo "Установка зависимостей..."
go mod tidy

echo "Генерация gRPC кода..."
cd internal/transport/grpc
make gen-all
cd ../../..

echo "file-service готов к сборке!" 