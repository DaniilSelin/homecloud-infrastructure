#!/bin/bash
set -e

# Загружаем конфигурацию
source ./scripts/load-config.sh

SERVICE_NAME=$1

if [ -z "$SERVICE_NAME" ]; then
    echo "Usage: $0 <service_name>"
    echo "Available services: dbmanager, auth, file_service, frontend"
    exit 1
fi

echo "Updating $SERVICE_NAME..."

# Определяем переменные для сервиса
case $SERVICE_NAME in
    "dbmanager")
        SERVICE_URL="$DBMANAGER_URL"
        SERVICE_BRANCH="$DBMANAGER_BRANCH"
        SERVICE_PATH="$DBMANAGER_PATH"
        ;;
    "auth")
        SERVICE_URL="$AUTH_URL"
        SERVICE_BRANCH="$AUTH_BRANCH"
        SERVICE_PATH="$AUTH_PATH"
        ;;
    "file_service")
        SERVICE_URL="$FILE_SERVICE_URL"
        SERVICE_BRANCH="$FILE_SERVICE_BRANCH"
        SERVICE_PATH="$FILE_SERVICE_PATH"
        ;;
    "frontend")
        SERVICE_URL="$FRONTEND_URL"
        SERVICE_BRANCH="$FRONTEND_BRANCH"
        SERVICE_PATH="$FRONTEND_PATH"
        ;;
    *)
        echo "Unknown service: $SERVICE_NAME"
        exit 1
        ;;
esac

# Удаляем старую директорию
if [ -d "$SERVICE_PATH" ]; then
    echo "Removing old $SERVICE_NAME directory..."
    rm -rf "$SERVICE_PATH"
fi

# Клонируем заново
echo "Cloning $SERVICE_NAME from $SERVICE_URL..."
git clone -b "$SERVICE_BRANCH" "$SERVICE_URL" "$SERVICE_PATH"

echo "$SERVICE_NAME updated successfully!" 