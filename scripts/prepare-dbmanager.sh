#!/bin/bash
set -e

# Загружаем конфигурацию
source ./scripts/load-config.sh

echo "Preparing DBManager service..."

DBMANAGER_DIR="$DBMANAGER_PATH"

if [ ! -d "$DBMANAGER_DIR" ]; then
    echo "Error: DBManager directory not found at $DBMANAGER_DIR"
    echo "Please run ./scripts/clone-repositories.sh first"
    exit 1
fi

cd "$DBMANAGER_DIR"

echo "Current directory: $(pwd)"

# 1. Проверяем наличие protoc и плагинов
echo "Checking protoc and plugins..."
if ! command -v protoc &> /dev/null; then
    echo "Installing protoc..."
    # Для Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y protobuf-compiler
    else
        echo "Please install protobuf-compiler manually"
        exit 1
    fi
fi

# Проверяем go plugins для protoc
if ! protoc --go_out=. --go_opt=paths=source_relative --go-grpc_out=. --go-grpc_opt=paths=source_relative --help &> /dev/null; then
    echo "Installing protoc Go plugins..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# 2. Генерируем gRPC код
echo "Generating gRPC code..."
if [ -f "db_service.proto" ]; then
    echo "Generating from db_service.proto..."
    protoc --go_out=. --go_opt=paths=source_relative \
           --go-grpc_out=. --go-grpc_opt=paths=source_relative \
           db_service.proto
fi

if [ -f "min.proto" ]; then
    echo "Generating from min.proto..."
    protoc --go_out=. --go_opt=paths=source_relative \
           --go-grpc_out=. --go-grpc_opt=paths=source_relative \
           min.proto
fi

# 3. Создаем config.local.yaml на основе example
echo "Creating config.local.yaml..."
if [ -f "config/config.example.yaml" ]; then
    cat > config/config.local.yaml << EOF
db:
  host: "${DB_HOST}"
  port: ${DB_PORT}
  user: "${DB_USER}"
  password: "${DB_PASSWORD}"
  dbname: "${DB_HOMECLOUD}"
  sslmode: "disable"
grpc:
  host: "0.0.0.0"
  port: ${DBMANAGER_GRPC_PORT}
EOF
    echo "config.local.yaml created successfully"
else
    echo "Warning: config.example.yaml not found"
fi

# 4. Проверяем и подготавливаем миграции
echo "Preparing migrations..."
if [ -d "internal/migration" ]; then
    echo "Found internal migrations directory"
    if [ -f "internal/migration/migrate.sh" ]; then
        chmod +x internal/migration/migrate.sh
        echo "Migration script made executable"
    fi
fi

if [ -d "migrations" ]; then
    echo "Found migrations directory"
    # Копируем миграции в общую директорию для docker-compose
    mkdir -p ../../migrations
    cp -r migrations/* ../../migrations/ 2>/dev/null || echo "No migration files to copy"
fi

# 5. Собираем приложение для проверки
echo "Building application..."
if [ -f "go.mod" ]; then
    go mod tidy
    go build -o server ./cmd/server
    echo "Application built successfully"
else
    echo "Warning: go.mod not found"
fi

echo "DBManager preparation completed!"
cd - > /dev/null 