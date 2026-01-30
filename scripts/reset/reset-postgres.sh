#!/bin/bash
set -e

echo "⚠️  ATENÇÃO: Este script vai DELETAR todos os dados do Postgres!"
echo "Isso inclui:"
echo "  - Todos os bancos de dados"
echo "  - Todos os usuários"
echo "  - Configurações"
echo ""
read -p "Tem certeza que deseja continuar? (digite 'sim' para confirmar) " -r
echo

if [[ ! $REPLY == "sim" ]]; then
    echo "❌ Operação cancelada."
    exit 1
fi

cd "$(dirname "$0")/../../stacks/shared/postgres"

echo "🛑 Parando container do Postgres..."
docker compose down

echo "🗑️  Removendo volume de dados..."
docker volume rm shared-postgres-data || echo "Volume já estava removido"

echo ""
echo "✅ Postgres resetado com sucesso!"
echo ""
echo "Próximos passos:"
echo "  1. Configurar .env com as senhas"
echo "  2. Subir novamente: cd stacks/shared/postgres && docker compose up -d"
echo "  3. Verificar logs: docker compose logs -f"
