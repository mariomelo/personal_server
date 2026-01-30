#!/bin/bash
set -e

echo "⚠️  ATENÇÃO: Este script vai DELETAR todos os dados do Plausible!"
echo "Isso inclui:"
echo "  - Todos os eventos coletados (ClickHouse)"
echo "  - Logs do ClickHouse"
echo "  - Container do Plausible"
echo ""
echo "O banco de dados do Plausible no Postgres NÃO será deletado."
echo ""
read -p "Tem certeza que deseja continuar? (digite 'sim' para confirmar) " -r
echo

if [[ ! $REPLY == "sim" ]]; then
    echo "❌ Operação cancelada."
    exit 1
fi

cd "$(dirname "$0")/../../stacks/plausible"

echo "🛑 Parando containers do Plausible..."
docker compose down

echo "🗑️  Removendo volumes de eventos..."
docker volume rm plausible-event-data plausible-event-logs || echo "Volumes já estavam removidos"

echo ""
echo "✅ Plausible resetado com sucesso!"
echo ""
echo "Próximos passos:"
echo "  1. Configurar .env com as senhas e secrets"
echo "  2. Subir novamente: cd stacks/plausible && docker compose up -d"
echo "  3. Verificar logs: docker compose logs -f"
