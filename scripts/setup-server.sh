#!/bin/bash
set -e

echo "🚀 Configurando servidor..."
echo ""

# Verificar se está rodando como root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Não execute este script como root!"
    exit 1
fi

# 1. Atualizar sistema
echo "📦 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências básicas
echo "📦 Instalando dependências..."
sudo apt install -y curl git vim htop ufw fail2ban

# 3. Instalar Docker (se não estiver instalado)
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker instalado. IMPORTANTE: Faça logout/login para aplicar grupo docker"
else
    echo "✅ Docker já instalado"
fi

# 4. Instalar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Instalando Docker Compose..."
    sudo apt install -y docker-compose-plugin
else
    echo "✅ Docker Compose já instalado"
fi

# 5. Instalar Caddy (se não estiver instalado)
if ! command -v caddy &> /dev/null; then
    echo "🌐 Instalando Caddy..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy
else
    echo "✅ Caddy já instalado"
fi

# 6. Configurar UFW (firewall)
echo "🔥 Configurando firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
echo "✅ Firewall configurado"

echo ""
echo "✅ Servidor configurado!"
echo ""
echo "Próximos passos:"
echo "  1. Se instalou Docker agora: faça logout/login"
echo "  2. Clone este repositório no servidor"
echo "  3. Configure os arquivos .env em cada stack"
echo "  4. Execute: ./scripts/setup-caddy.sh"
echo "  5. Suba os containers: cd stacks/shared/postgres && docker compose up -d"
