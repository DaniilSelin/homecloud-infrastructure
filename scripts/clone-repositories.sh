#!/bin/bash
set -e

# Загружаем конфигурацию
source ./scripts/load-config.sh

echo "Cloning repositories..."

# Создаем директорию для сервисов
mkdir -p ./services

# Функция для клонирования репозитория
clone_repo() {
    local name=$1
    local url=$2
    local branch=$3
    local path=$4
    
    echo "Cloning $name from $url..."
    
    if [ -d "$path" ]; then
        echo "Repository $name already exists, pulling latest changes..."
        cd "$path"
        git fetch origin
        git checkout "$branch"
        git pull origin "$branch"
        cd - > /dev/null
    else
        echo "Cloning $name to $path..."
        git clone -b "$branch" "$url" "$path"
    fi
}

# Клонируем все репозитории
clone_repo "dbmanager" "$DBMANAGER_URL" "$DBMANAGER_BRANCH" "$DBMANAGER_PATH"
clone_repo "auth" "$AUTH_URL" "$AUTH_BRANCH" "$AUTH_PATH"
clone_repo "file_service" "$FILE_SERVICE_URL" "$FILE_SERVICE_BRANCH" "$FILE_SERVICE_PATH"
clone_repo "frontend" "$FRONTEND_URL" "$FRONTEND_BRANCH" "$FRONTEND_PATH"

echo "All repositories cloned successfully!" 