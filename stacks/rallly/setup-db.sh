#!/bin/bash
# Adiciona o banco de dados do Rallly ao Postgres compartilhado
# Execute UMA VEZ antes de subir o stack pela primeira vez
#
# Pré-requisito: container shared-postgres rodando
#                variável RALLLY_DB_PASSWORD definida no .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ Arquivo .env não encontrado. Copie .env.example para .env e preencha os valores."
    exit 1
fi

source "$SCRIPT_DIR/.env"

if [ -z "$RALLLY_DB_PASSWORD" ]; then
    echo "❌ RALLLY_DB_PASSWORD não definida no .env"
    exit 1
fi

echo "⚙️  Criando banco de dados e usuário para Rallly..."

docker exec -i shared-postgres psql -U postgres <<-EOSQL
    CREATE DATABASE rallly;
    CREATE USER rallly_user WITH PASSWORD '${RALLLY_DB_PASSWORD}';
    ALTER DATABASE rallly OWNER TO rallly_user;
    \c rallly
    GRANT ALL PRIVILEGES ON SCHEMA public TO rallly_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rallly_user;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rallly_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO rallly_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO rallly_user;
EOSQL

echo "✅ Banco de dados rallly criado com sucesso!"
echo ""
echo "Próximo passo: docker compose up -d"
