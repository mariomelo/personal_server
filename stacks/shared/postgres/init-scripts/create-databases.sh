#!/bin/bash
set -e

# Script executado automaticamente pelo Postgres na primeira inicialização
# Usa variáveis de ambiente do docker-compose.yml

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Criar banco de dados para Plausible
    CREATE DATABASE plausible;

    -- Criar usuário específico para Plausible
    CREATE USER plausible_user WITH PASSWORD '${PLAUSIBLE_DB_PASSWORD}';

    -- Dar ownership do banco ao usuário
    ALTER DATABASE plausible OWNER TO plausible_user;

    -- Conectar ao banco plausible e dar permissões no schema public
    \c plausible
    GRANT ALL PRIVILEGES ON SCHEMA public TO plausible_user;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO plausible_user;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO plausible_user;

    -- Garantir que futuras tabelas também tenham permissão
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO plausible_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO plausible_user;

    -- Futuras databases podem ser adicionadas aqui
    -- CREATE DATABASE outra_app;
EOSQL

echo "✅ Databases criadas com sucesso!"
