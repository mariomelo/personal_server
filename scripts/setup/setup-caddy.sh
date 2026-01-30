#!/bin/bash
set -e

CADDY_CONFIG="/etc/caddy/Caddyfile"
PROJECT_CONFIG="$(pwd)/caddy/Caddyfile"

echo "🔧 Configurando Caddy..."
echo ""

# 1. Fazer backup do Caddyfile atual
if [ -f "$CADDY_CONFIG" ]; then
    BACKUP_FILE="${CADDY_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backup do Caddyfile atual: $BACKUP_FILE"
    sudo cp "$CADDY_CONFIG" "$BACKUP_FILE"
else
    echo "⚠️  Nenhum Caddyfile encontrado em $CADDY_CONFIG"
fi

# 2. Verificar se o arquivo do projeto existe
if [ ! -f "$PROJECT_CONFIG" ]; then
    echo "❌ Erro: Caddyfile não encontrado em $PROJECT_CONFIG"
    echo "Por favor, crie o arquivo primeiro."
    exit 1
fi

# 3. Criar symlink
echo "🔗 Criando symlink..."
sudo rm -f "$CADDY_CONFIG"
sudo ln -s "$PROJECT_CONFIG" "$CADDY_CONFIG"

# 4. Validar configuração
echo "✅ Validando configuração..."
sudo caddy validate --config "$CADDY_CONFIG"

# 5. Recarregar Caddy
echo "🔄 Recarregando Caddy..."
sudo systemctl reload caddy

echo ""
echo "✅ Caddy configurado com sucesso!"
echo ""
echo "Comandos úteis:"
echo "  - Ver logs: sudo journalctl -u caddy -f"
echo "  - Recarregar: sudo systemctl reload caddy"
echo "  - Validar config: sudo caddy validate --config $CADDY_CONFIG"
