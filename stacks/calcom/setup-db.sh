#!/bin/bash
# Adiciona o banco de dados do Cal.com ao Postgres compartilhado
# Execute UMA VEZ antes de subir o stack pela primeira vez
#
# Uso: ./setup-db.sh
# Pré-requisito: container shared-postgres rodando
#                variável CALCOM_DB_PASSWORD definida no .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carregar senha do .env
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ Arquivo .env não encontrado. Copie .env.example para .env e preencha os valores."
    exit 1
fi

source "$SCRIPT_DIR/.env"

if [ -z "$CALCOM_DB_PASSWORD" ]; then
    echo "❌ CALCOM_DB_PASSWORD não definida no .env"
    exit 1
fi

echo "⚙️  Criando banco de dados e usuário para Cal.com..."

docker exec -i shared-postgres psql -U postgres <<-EOSQL
    -- Criar banco de dados
    CREATE DATABASE calcom;

    -- Criar usuário
    CREATE USER calcom_user WITH PASSWORD '${CALCOM_DB_PASSWORD}';

    -- Ownership
    ALTER DATABASE calcom OWNER TO calcom_user;

    -- Permissões no schema public
    \c calcom
    GRANT ALL PRIVILEGES ON SCHEMA public TO calcom_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO calcom_user;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO calcom_user;

    -- Permissões para tabelas criadas pelo Prisma no futuro
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO calcom_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO calcom_user;
EOSQL

echo "✅ Banco de dados calcom criado com sucesso!"
echo ""
echo "Próximo passo: docker compose up -d"
