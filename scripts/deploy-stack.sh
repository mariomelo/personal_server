#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Uso: ./deploy-stack.sh <nome-do-stack>"
    echo ""
    echo "Stacks disponíveis:"
    ls -1 stacks/ | grep -v shared
    exit 1
fi

STACK_NAME=$1
STACK_PATH="stacks/$STACK_NAME"

if [ ! -d "$STACK_PATH" ]; then
    echo "❌ Stack '$STACK_NAME' não encontrado em $STACK_PATH"
    exit 1
fi

echo "🚀 Deploy do stack: $STACK_NAME"
echo ""

# Verificar se existe .env
if [ ! -f "$STACK_PATH/.env" ]; then
    echo "⚠️  Arquivo .env não encontrado!"
    echo "Copie o .env.example e preencha os valores:"
    echo "  cp $STACK_PATH/.env.example $STACK_PATH/.env"
    exit 1
fi

# Entrar no diretório e subir
cd "$STACK_PATH"

echo "📦 Baixando imagens..."
docker compose pull

echo "🔧 Subindo containers..."
docker compose up -d

echo ""
echo "✅ Stack '$STACK_NAME' deployado!"
echo ""
echo "Ver logs:"
echo "  cd $STACK_PATH && docker compose logs -f"
