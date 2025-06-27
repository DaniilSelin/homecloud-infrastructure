#!/bin/bash

set -e

echo "Подготовка auth-service..."

# Переходим в директорию auth-service
cd services/auth

# Проверяем, что директория существует
if [ ! -d "." ]; then
    echo "Директория auth-service не найдена. Сначала клонируйте репозиторий."
    exit 1
fi

echo "Установка зависимостей..."
go mod tidy

echo "Генерация gRPC кода..."
cd internal/transport/grpc
make gen-all
cd ../../..

echo "auth-service готов к сборке!" 