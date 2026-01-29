#!/bin/bash
set -e

echo "🗑️  Removendo todos os containers Docker..."

# Para e remove todos os containers
if [ "$(docker ps -aq)" ]; then
    echo "Parando containers..."
    docker stop $(docker ps -aq)
    echo "Removendo containers..."
    docker rm $(docker ps -aq)
else
    echo "Nenhum container encontrado."
fi

# Remove volumes não utilizados (cuidado!)
echo ""
read -p "Deseja remover volumes não utilizados? (s/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    docker volume prune -f
    echo "✅ Volumes removidos"
fi

# Remove redes não utilizadas
docker network prune -f

echo ""
echo "✅ Limpeza concluída!"
echo ""
echo "Containers restantes:"
docker ps -a
