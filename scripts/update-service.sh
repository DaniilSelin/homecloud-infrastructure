#!/bin/bash

set -e

# Функция для отображения справки
show_help() {
    echo "Использование: $0 <service_name> [action]"
    echo ""
    echo "Доступные сервисы:"
    echo "  dbmanager - Сервис управления базой данных"
    echo "  auth      - Сервис аутентификации"
    echo ""
    echo "Доступные действия:"
    echo "  clone     - Клонировать репозиторий (по умолчанию)"
    echo "  update    - Обновить существующий репозиторий"
    echo "  prepare   - Подготовить сервис к сборке"
    echo "  build     - Собрать Docker образ"
    echo "  run       - Запустить сервис"
    echo ""
    echo "Примеры:"
    echo "  $0 dbmanager clone"
    echo "  $0 auth prepare"
    echo "  $0 dbmanager build"
}

# Проверка аргументов
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

SERVICE_NAME=$1
ACTION=${2:-clone}

# Определение параметров сервиса
case $SERVICE_NAME in
    "dbmanager")
        REPO_URL="https://github.com/DaniilSelin/homecloud--dbmanager-service.git"
        BRANCH="main"
        SERVICE_PATH="./services/dbmanager"
        PREPARE_SCRIPT="scripts/prepare-dbmanager.sh"
        DOCKERFILE="build/Dockerfile.dbmanager"
        ;;
    "auth")
        REPO_URL="https://github.com/DaniilSelin/homecloud-auth-service.git"
        BRANCH="main"
        SERVICE_PATH="./services/auth"
        PREPARE_SCRIPT="scripts/prepare-auth.sh"
        DOCKERFILE="build/Dockerfile.auth"
        ;;
    *)
        echo "Неизвестный сервис: $SERVICE_NAME"
        show_help
        exit 1
        ;;
esac

# Выполнение действий
case $ACTION in
    "clone")
        echo "Клонирование $SERVICE_NAME..."
        if [ -d "$SERVICE_PATH" ]; then
            echo "Директория $SERVICE_PATH уже существует. Используйте 'update' для обновления."
            exit 1
        fi
        git clone -b $BRANCH $REPO_URL $SERVICE_PATH
        echo "$SERVICE_NAME успешно клонирован в $SERVICE_PATH"
        ;;
        
    "update")
        echo "Обновление $SERVICE_NAME..."
        if [ ! -d "$SERVICE_PATH" ]; then
            echo "Директория $SERVICE_PATH не найдена. Используйте 'clone' для клонирования."
            exit 1
        fi
        cd $SERVICE_PATH
        git fetch origin
        git checkout $BRANCH
        git pull origin $BRANCH
        cd ../..
        echo "$SERVICE_NAME успешно обновлен"
        ;;
        
    "prepare")
        echo "Подготовка $SERVICE_NAME..."
        if [ ! -d "$SERVICE_PATH" ]; then
            echo "Директория $SERVICE_PATH не найдена. Сначала клонируйте репозиторий."
            exit 1
        fi
        if [ -f "$PREPARE_SCRIPT" ]; then
            bash $PREPARE_SCRIPT
        else
            echo "Скрипт подготовки не найден: $PREPARE_SCRIPT"
            exit 1
        fi
        ;;
        
    "build")
        echo "Сборка Docker образа для $SERVICE_NAME..."
        if [ ! -d "$SERVICE_PATH" ]; then
            echo "Директория $SERVICE_PATH не найдена. Сначала клонируйте репозиторий."
            exit 1
        fi
        if [ ! -f "$DOCKERFILE" ]; then
            echo "Dockerfile не найден: $DOCKERFILE"
            exit 1
        fi
        docker build -f $DOCKERFILE -t homecloud-$SERVICE_NAME .
        echo "Docker образ homecloud-$SERVICE_NAME успешно собран"
        ;;
        
    "run")
        echo "Запуск $SERVICE_NAME через docker-compose..."
        docker-compose up -d $SERVICE_NAME
        echo "$SERVICE_NAME запущен"
        ;;
        
    *)
        echo "Неизвестное действие: $ACTION"
        show_help
        exit 1
        ;;
esac 