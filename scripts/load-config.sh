#!/bin/bash

# Функция для парсинга YAML (простая реализация)
parse_yaml() {
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'", vn, $2, $3);
        }
    }'
}

# Загружаем конфигурацию
eval $(parse_yaml ./repositories.yaml "CONFIG_")

# Экспортируем переменные для использования в других скриптах
export DBMANAGER_URL="$CONFIG_repositories_dbmanager_url"
export DBMANAGER_BRANCH="$CONFIG_repositories_dbmanager_branch"
export DBMANAGER_PATH="$CONFIG_repositories_dbmanager_path"

export AUTH_URL="$CONFIG_repositories_auth_url"
export AUTH_BRANCH="$CONFIG_repositories_auth_branch"
export AUTH_PATH="$CONFIG_repositories_auth_path"

export FILE_SERVICE_URL="$CONFIG_repositories_file_service_url"
export FILE_SERVICE_BRANCH="$CONFIG_repositories_file_service_branch"
export FILE_SERVICE_PATH="$CONFIG_repositories_file_service_path"

export FRONTEND_URL="$CONFIG_repositories_frontend_url"
export FRONTEND_BRANCH="$CONFIG_repositories_frontend_branch"
export FRONTEND_PATH="$CONFIG_repositories_frontend_path"

# Настройки базы данных
export DB_HOST="$CONFIG_database_host"
export DB_PORT="$CONFIG_database_port"
export DB_USER="$CONFIG_database_user"
export DB_PASSWORD="$CONFIG_database_password"
export DB_HOMECLOUD="$CONFIG_database_homecloud_db"

# Настройки сервисов
export DBMANAGER_GRPC_PORT="$CONFIG_services_dbmanager_grpc_port"
export DBMANAGER_HTTP_PORT="$CONFIG_services_dbmanager_http_port"
export AUTH_HTTP_PORT="$CONFIG_services_auth_http_port"
export AUTH_GRPC_PORT="$CONFIG_services_auth_grpc_port"
export FILE_SERVICE_HTTP_PORT="$CONFIG_services_file_service_http_port"
export FILE_SERVICE_GRPC_PORT="$CONFIG_services_file_service_grpc_port"
export FRONTEND_HTTP_PORT="$CONFIG_services_frontend_http_port"

# JWT настройки
export JWT_SECRET_KEY="$CONFIG_jwt_secret_key"
export JWT_EXPIRATION="$CONFIG_jwt_expiration"
export JWT_VERIFICATION_SECRET_KEY="$CONFIG_jwt_verification_secret_key"
export JWT_VERIFICATION_EXPIRATION="$CONFIG_jwt_verification_expiration" 