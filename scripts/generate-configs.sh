#!/bin/bash
set -e

# Загружаем конфигурацию
source ./scripts/load-config.sh

echo "Generating configuration files..."

# Создаем директорию для конфигов
mkdir -p ./configs

# Генерируем конфиг для dbmanager
echo "Generating dbmanager config..."
cat > ./configs/dbmanager-config.yml << EOF
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

# Генерируем конфиг для auth service
echo "Generating auth service config..."
cat > ./configs/auth-config.yml << EOF
database:
  host: ${DB_HOST}
  port: ${DB_PORT}
  
server:
  host: "0.0.0.0"
  port: ${AUTH_HTTP_PORT}

grpcAuthServer:
  host: 0.0.0.0
  port: ${AUTH_GRPC_PORT}

jwt:
  secret_key: "${JWT_SECRET_KEY}"
  expiration: "${JWT_EXPIRATION}"

verification:
  secret_key: "${JWT_VERIFICATION_SECRET_KEY}"
  expiration: "${JWT_VERIFICATION_EXPIRATION}"

grpc:
  host: "0.0.0.0"
  port: ${AUTH_GRPC_PORT}

dbmanager:
  host: "dbmanager"
  port: ${DBMANAGER_GRPC_PORT}

file_service:
  host: "file-service"
  port: ${FILE_SERVICE_GRPC_PORT}

logger:
  level: "info"
  development: true
  encoding: "console"
  outputPaths: ["stdout"]
  errorOutputPaths: ["stderr"]
  encoderConfig:
    messageKey: "message"
    levelKey: "level"
    timeKey: "timestamp"
    nameKey: "logger"
    callerKey: "caller"
    functionKey: "func"
    stacktraceKey: "stacktrace"
    lineEnding: "\n"
    levelEncoder: "lowercase"
    timeEncoder: "iso8601"
    durationEncoder: "string"
    callerEncoder: "short"
EOF

# Генерируем конфиг для file service
echo "Generating file service config..."
cat > ./configs/file-service-config.yml << EOF
server:
  host: "0.0.0.0"
  port: ${FILE_SERVICE_HTTP_PORT}

database:
  host: "${DB_HOST}"
  port: ${DB_PORT}
  user: "${DB_USER}"
  password: "${DB_PASSWORD}"
  dbname: "${DB_HOMECLOUD}"
  sslmode: "disable"

storage:
  base_path: "/app/storage"
  max_size: 1073741824
  chunk_size: 1048576
  temp_path: "/app/temp"
  user_dir_name: "users"

grpc:
  host: "0.0.0.0"
  port: ${FILE_SERVICE_GRPC_PORT}

dbmanager:
  host: "dbmanager"
  port: ${DBMANAGER_GRPC_PORT}

auth:
  host: "auth"
  port: ${AUTH_GRPC_PORT}

logger:
  level: "info"
  development: true
  encoding: "console"
  outputPaths: ["stdout"]
  errorOutputPaths: ["stderr"]
  encoderConfig:
    messageKey: "message"
    levelKey: "level"
    timeKey: "timestamp"
    nameKey: "logger"
    callerKey: "caller"
    functionKey: "func"
    stacktraceKey: "stacktrace"
    lineEnding: "\n"
    levelEncoder: "lowercase"
    timeEncoder: "iso8601"
    durationEncoder: "string"
    callerEncoder: "short"
EOF

echo "All configuration files generated successfully!" 