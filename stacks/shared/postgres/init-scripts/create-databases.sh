#!/bin/bash
set -e

# Script executado automaticamente pelo Postgres na primeira inicialização
# Usa variáveis de ambiente do docker-compose.yml

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Plausible
    CREATE DATABASE plausible;
    CREATE USER plausible_user WITH PASSWORD '${PLAUSIBLE_DB_PASSWORD}';
    ALTER DATABASE plausible OWNER TO plausible_user;
    \c plausible
    GRANT ALL PRIVILEGES ON SCHEMA public TO plausible_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO plausible_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO plausible_user;

    -- Syncal
    \c postgres
    CREATE DATABASE syncal;
    CREATE USER syncal_user WITH PASSWORD '${SYNCAL_DB_PASSWORD}';
    ALTER DATABASE syncal OWNER TO syncal_user;
    \c syncal
    GRANT ALL PRIVILEGES ON SCHEMA public TO syncal_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO syncal_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO syncal_user;

    -- Zeroslides
    \c postgres
    CREATE DATABASE zeroslides;
    CREATE USER zeroslides_user WITH PASSWORD '${ZEROSLIDES_DB_PASSWORD}';
    ALTER DATABASE zeroslides OWNER TO zeroslides_user;
    \c zeroslides
    GRANT ALL PRIVILEGES ON SCHEMA public TO zeroslides_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO zeroslides_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO zeroslides_user;
EOSQL

echo "✅ Databases criadas com sucesso!"
