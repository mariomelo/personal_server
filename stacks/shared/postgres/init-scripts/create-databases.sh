#!/bin/bash
set -e

# Script executado automaticamente pelo Postgres na primeira inicialização
# Usa variáveis de ambiente do docker-compose.yml

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar banco de dados para Plausible
    CREATE DATABASE plausible;

    -- Criar usuário específico para Plausible
    CREATE USER plausible_user WITH PASSWORD '${PLAUSIBLE_DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON DATABASE plausible TO plausible_user;

    -- Futuras databases podem ser adicionadas aqui
    -- CREATE DATABASE outra_app;
EOSQL

echo "✅ Databases criadas com sucesso!"
