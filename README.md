# HomeCloud Infrastructure

Инфраструктурный сервис для управления микросервисами HomeCloud с использованием Docker и Docker Compose. Обеспечивает автоматическое клонирование, сборку, конфигурацию и запуск всех компонентов системы.

## Архитектура системы

HomeCloud состоит из следующих микросервисов:

- **PostgreSQL** - основная база данных
- **DBManager** - сервис управления базой данных (gRPC)
- **Auth Service** - сервис аутентификации (HTTP + gRPC)
- **File Service** - сервис управления файлами (HTTP + gRPC)
- **Frontend** - веб-интерфейс с Nginx проксированием

## Структура проекта

```
homecloud-infrastructure/
├── build/                    # Dockerfiles для всех сервисов
│   ├── Dockerfile.dbmanager
│   ├── Dockerfile.auth
│   ├── Dockerfile.file-service
│   └── Dockerfile.frontend
├── config/                   # Конфигурационные файлы
│   ├── dbmanager-config.yml
│   ├── auth-config.yml
│   ├── file-service-config.yml
│   ├── frontend-config.yml
│   └── nginx-frontend.conf
├── scripts/                  # Скрипты управления
│   ├── clone-repositories.sh # Клонирование всех репозиториев
│   ├── load-config.sh        # Загрузка конфигурации
│   ├── generate-configs.sh   # Генерация конфигураций
│   ├── prepare-*.sh          # Скрипты подготовки сервисов
│   ├── update-service.sh     # Универсальный скрипт управления
│   └── start-all.sh          # Запуск всех сервисов
├── services/                 # Клонированные репозитории сервисов
├── init-db/                  # Скрипты инициализации БД
├── docker-compose.yml        # Конфигурация Docker Compose
├── repositories.yaml         # Список репозиториев и настройки
└── README.md                 # Эта документация
```

## Быстрый старт

### 1. Подготовка окружения

```bash
# Клонирование всех репозиториев
./scripts/clone-repositories.sh

# Подготовка всех сервисов
./scripts/prepare-dbmanager.sh
./scripts/prepare-auth.sh
./scripts/prepare-file-service.sh
./scripts/prepare-frontend.sh
```

### 2. Запуск всей инфраструктуры

```bash
# Запуск всех сервисов
./scripts/start-all.sh

# Или напрямую через docker-compose
docker-compose up -d
```

### 3. Проверка работоспособности

```bash
# Статус всех сервисов
docker-compose ps

# Проверка frontend
curl http://localhost:3000

# Проверка auth service
curl http://localhost:8080/api/v1/auth/register
```

## Управление сервисами

### Универсальный скрипт управления

Используйте `scripts/update-service.sh` для работы с сервисами:

```bash
# Справка
./scripts/update-service.sh

# Клонирование репозитория
./scripts/update-service.sh <service_name> clone

# Обновление репозитория
./scripts/update-service.sh <service_name> update

# Подготовка к сборке
./scripts/update-service.sh <service_name> prepare

# Сборка Docker образа
./scripts/update-service.sh <service_name> build

# Запуск сервиса
./scripts/update-service.sh <service_name> run
```

### Доступные сервисы

- `dbmanager` - Сервис управления базой данных
- `auth` - Сервис аутентификации

### Индивидуальные скрипты подготовки

Каждый сервис имеет свой скрипт подготовки:

```bash
# Подготовка dbmanager
./scripts/prepare-dbmanager.sh

# Подготовка auth service
./scripts/prepare-auth.sh

# Подготовка file service
./scripts/prepare-file-service.sh

# Подготовка frontend
./scripts/prepare-frontend.sh
```

### Docker Compose команды

```bash
# Запуск всех сервисов
docker-compose up -d

# Остановка всех сервисов
docker-compose down

# Просмотр логов
docker-compose logs -f [service_name]

# Статус контейнеров
docker-compose ps

# Пересборка и запуск
docker-compose up -d --build

# Перезапуск конкретного сервиса
docker-compose restart [service_name]
```

## Порты и доступы

| Сервис | Порт | Протокол | Описание |
|--------|------|----------|----------|
| PostgreSQL | 5432 | TCP | База данных |
| DBManager | 50051 | gRPC | Управление БД |
| Auth Service | 8080 | HTTP | REST API |
| Auth Service | 50052 | gRPC | gRPC API |
| File Service | 8082 | HTTP | REST API |
| File Service | 50053 | gRPC | gRPC API |
| Frontend | 3000 | HTTP | Веб-интерфейс |

## Конфигурация

### Файлы конфигурации

Все конфигурационные файлы находятся в директории `config/`:

- `dbmanager-config.yml` - конфигурация DBManager
- `auth-config.yml` - конфигурация Auth Service
- `file-service-config.yml` - конфигурация File Service
- `frontend-config.yml` - конфигурация Frontend
- `nginx-frontend.conf` - конфигурация Nginx

### Настройки репозиториев

Файл `repositories.yaml` содержит:

- URLs репозиториев
- Ветки для клонирования
- Пути к сервисам
- Настройки портов
- JWT конфигурацию

### Переменные окружения

Основные переменные окружения:

```bash
# База данных
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=changeme
DB_NAME=homecloud

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
JWT_EXPIRATION=24h
```

## Разработка

### Добавление нового сервиса

1. Добавьте сервис в `repositories.yaml`
2. Создайте Dockerfile в `build/`
3. Создайте конфигурационный файл в `config/`
4. Добавьте сервис в `docker-compose.yml`
5. Создайте скрипт подготовки в `scripts/`
6. Обновите `scripts/update-service.sh`

### Обновление сервисов

```bash
# Обновление конкретного сервиса
./scripts/update-service.sh <service_name> update

# Пересборка после обновления
docker-compose build <service_name>

# Перезапуск
docker-compose restart <service_name>
```

### Локальная разработка

Для разработки отдельных сервисов:

```bash
# Клонирование только нужного сервиса
./scripts/update-service.sh <service_name> clone

# Подготовка сервиса
./scripts/prepare-<service_name>.sh

# Сборка образа
docker-compose build <service_name>

# Запуск с зависимостями
docker-compose up -d <service_name>
```

## Мониторинг и логи

### Просмотр логов

```bash
# Все сервисы
docker-compose logs -f

# Конкретный сервис
docker-compose logs -f dbmanager
docker-compose logs -f auth
docker-compose logs -f file-service
docker-compose logs -f frontend
docker-compose logs -f postgres
```

### Health checks

```bash
# Проверка frontend
curl http://localhost:3000/health

# Проверка auth service
curl http://localhost:8080/health

# Проверка file service
curl http://localhost:8082/health
```

### Статус контейнеров

```bash
# Общий статус
docker-compose ps

# Детальная информация
docker-compose ps -a
```

## Устранение неполадок

### Проблемы с портами

```bash
# Поиск процессов на порту
sudo lsof -i :<port>

# Остановка процесса
sudo kill -9 <PID>
```

### Проблемы с Docker

```bash
# Очистка Docker
docker system prune -a

# Пересборка образов
docker-compose build --no-cache

# Удаление всех контейнеров
docker-compose down -v
```

### Проблемы с базой данных

```bash
# Сброс базы данных
docker-compose down -v
docker-compose up -d postgres

# Проверка подключения к БД
docker exec homecloud-postgres psql -U postgres -d homecloud -c "SELECT 1;"
```

### Проблемы с миграциями

```bash
# Запуск миграций вручную
docker exec homecloud-dbmanager ./migrations/migrate.sh

# Проверка статуса миграций
docker exec homecloud-postgres psql -U postgres -d homecloud -c "SELECT * FROM homecloud.migrations;"
```

### Проблемы с сетью

```bash
# Проверка сети
docker network ls
docker network inspect homecloud-infrastructure_homecloud-network

# Проверка DNS
docker exec homecloud-auth nslookup file-service
```

## Тестирование

### Тестирование API

```bash
# Регистрация пользователя
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"testpass123"}'

# Логин пользователя
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
```

### Тестирование через frontend

```bash
# Проверка проксирования API
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"testpass123"}'
```

## Безопасность

### Рекомендации для продакшена

1. Измените все пароли по умолчанию
2. Настройте HTTPS для frontend
3. Ограничьте доступ к портам
4. Настройте firewall
5. Используйте секреты для JWT ключей
6. Настройте мониторинг и логирование

### Конфигурация безопасности

- Все сервисы работают в изолированной сети
- Используются непривилегированные пользователи
- Настроены health checks
- Конфигурация Nginx включает security headers

## Производительность

### Оптимизация

- Используется многоэтапная сборка Docker
- Настроено кэширование статических файлов
- Включено Gzip сжатие
- Оптимизированы образы Alpine Linux

### Масштабирование

Для масштабирования отдельных сервисов:

```bash
# Масштабирование auth service
docker-compose up -d --scale auth=3

# Масштабирование file service
docker-compose up -d --scale file-service=2
```

## Поддержка

### Полезные команды

```bash
# Полная перезагрузка инфраструктуры
./scripts/start-all.sh

# Очистка и пересборка
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

# Экспорт логов
docker-compose logs > logs.txt

# Проверка использования ресурсов
docker stats
```

### Контакты

Для вопросов и поддержки обращайтесь к документации отдельных сервисов в их репозиториях. 