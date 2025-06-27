-- Создание базы данных homecloud
CREATE DATABASE homecloud;

-- Создание базы данных gopher_equalizer
CREATE DATABASE gopher_equalizer;

-- Создание расширения dblink в postgres
CREATE EXTENSION IF NOT EXISTS dblink;

-- Подключение к homecloud и создание расширения dblink
\c homecloud;
CREATE EXTENSION IF NOT EXISTS dblink;

-- Подключение к gopher_equalizer и создание расширения dblink
\c gopher_equalizer;
CREATE EXTENSION IF NOT EXISTS dblink; 