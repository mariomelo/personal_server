#!/bin/bash
set -e

# Adiciona databases ao Postgres compartilhado já em execução.
# Idempotente: não falha se banco/usuário já existir.
#
# Uso: ./scripts/setup/add-postgres-databases.sh
# Pré-requisito: container shared-postgres rodando + .env configurado

POSTGRES_DIR="$(cd "$(dirname "$0")/../../stacks/shared/postgres" && pwd)"
ENV_FILE="$POSTGRES_DIR/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Arquivo .env não encontrado em $POSTGRES_DIR"
    echo "   Copie .env.example e preencha as senhas."
    exit 1
fi

# Carregar variáveis do .env
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if ! docker ps --format '{{.Names}}' | grep -q '^shared-postgres$'; then
    echo "❌ Container shared-postgres não está rodando."
    exit 1
fi

echo "🔧 Adicionando databases ao shared-postgres..."

docker exec -i shared-postgres psql -U "$POSTGRES_USER" <<-EOSQL

-- ── Syncal ──────────────────────────────────────────────────────────────────
SELECT 'CREATE DATABASE syncal'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'syncal')\gexec

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'syncal_user') THEN
    CREATE USER syncal_user WITH PASSWORD '${SYNCAL_DB_PASSWORD}';
  END IF;
END
\$\$;

ALTER DATABASE syncal OWNER TO syncal_user;

EOSQL

docker exec -i shared-postgres psql -U "$POSTGRES_USER" -d syncal <<-EOSQL
GRANT ALL PRIVILEGES ON SCHEMA public TO syncal_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO syncal_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO syncal_user;
EOSQL

echo "   ✅ syncal"

docker exec -i shared-postgres psql -U "$POSTGRES_USER" <<-EOSQL

-- ── Zeroslides ───────────────────────────────────────────────────────────────
SELECT 'CREATE DATABASE zeroslides'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zeroslides')\gexec

DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'zeroslides_user') THEN
    CREATE USER zeroslides_user WITH PASSWORD '${ZEROSLIDES_DB_PASSWORD}';
  END IF;
END
\$\$;

ALTER DATABASE zeroslides OWNER TO zeroslides_user;

EOSQL

docker exec -i shared-postgres psql -U "$POSTGRES_USER" -d zeroslides <<-EOSQL
GRANT ALL PRIVILEGES ON SCHEMA public TO zeroslides_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO zeroslides_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO zeroslides_user;
EOSQL

echo "   ✅ zeroslides"
echo ""
echo "✅ Concluído! Databases disponíveis:"
docker exec shared-postgres psql -U "$POSTGRES_USER" -c "\l" | grep -E "syncal|zeroslides|plausible"
