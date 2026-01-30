#!/bin/bash
set -e

echo "⚠️⚠️⚠️  PERIGO: RESET COMPLETO  ⚠️⚠️⚠️"
echo ""
echo "Este script vai DELETAR TUDO:"
echo "  - Todos os containers Docker"
echo "  - Todos os volumes (Postgres, Plausible, Homepage)"
echo "  - Todas as redes Docker"
echo ""
echo "Serviços que NÃO serão afetados:"
echo "  - Zeroslides (systemd)"
echo "  - Site estático"
echo "  - Caddy"
echo ""
read -p "Tem ABSOLUTA certeza? (digite 'DELETAR TUDO' para confirmar) " -r
echo

if [[ ! $REPLY == "DELETAR TUDO" ]]; then
    echo "❌ Operação cancelada."
    exit 1
fi

echo "🛑 Parando todos os containers..."
cd "$(dirname "$0")/../../stacks"

# Parar cada stack
for stack in */; do
    if [ -f "$stack/docker-compose.yml" ]; then
        echo "Parando $stack..."
        cd "$stack"
        docker compose down
        cd ..
    fi
done

echo "🗑️  Removendo volumes..."
docker volume rm shared-postgres-data plausible-event-data plausible-event-logs || true

echo "🗑️  Limpando redes não utilizadas..."
docker network prune -f

echo ""
echo "✅ Reset completo executado!"
echo ""
echo "Próximos passos:"
echo "  1. Configurar todos os .env"
echo "  2. Subir Postgres: cd stacks/shared/postgres && docker compose up -d"
echo "  3. Subir Plausible: cd stacks/plausible && docker compose up -d"
echo "  4. Subir Homepage: cd stacks/homepage && docker compose up -d"
