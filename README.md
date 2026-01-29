# Infraestrutura Servidor Melomario

Repositório de configuração do servidor self-hosted com abordagem Infrastructure as Code.

**Servidor**: 51.15.177.139 (Scaleway)
**OS**: Ubuntu 20.04 LTS
**RAM**: 4GB

## 🎯 Filosofia

- **Git como fonte da verdade**: Toda configuração versionada
- **Scripts de replicação**: Servidor pode ser recriado rapidamente
- **Simplicidade**: Sem over-engineering
- **Backup-first**: Estratégia clara para cada serviço

## 📦 Serviços

### Rodando
- **Zeroslides** (Elixir): Aplicação de apresentações via systemd
- **Site Estático**: Servido diretamente pelo Caddy

### Docker Stacks
- **Postgres Compartilhado**: Banco de dados para múltiplos serviços
- **Plausible Analytics**: Web analytics open-source
- **Homepage**: Dashboard com status e métricas do servidor

## 🚀 Setup Inicial

### 1. No servidor

```bash
# Clonar repositório
git clone <seu-repo> ~/infra-servidor
cd ~/infra-servidor

# Setup inicial (Docker, Caddy, firewall)
chmod +x scripts/*.sh
./scripts/setup-server.sh

# Se instalou Docker agora, fazer logout/login para aplicar grupo
```

### 2. Configurar variáveis

```bash
# Postgres compartilhado
cp stacks/shared/postgres/.env.example stacks/shared/postgres/.env
# Editar: vim stacks/shared/postgres/.env

# Plausible
cp stacks/plausible/.env.example stacks/plausible/.env
# Gerar secrets:
openssl rand -base64 64 | tr -d '\n'  # SECRET_KEY_BASE
openssl rand -base64 32 | tr -d '\n'  # TOTP_VAULT_KEY
# Editar: vim stacks/plausible/.env
```

### 3. Configurar Caddy

```bash
# Editar caddy/Caddyfile com seus domínios reais
vim caddy/Caddyfile

# Aplicar configuração
./scripts/setup-caddy.sh
```

### 4. Subir serviços

```bash
# Postgres primeiro (outros dependem dele)
cd stacks/shared/postgres
docker compose up -d
docker compose logs -f  # Verificar se está healthy

# Plausible
cd ../../plausible
docker compose up -d
docker compose logs -f

# Homepage
cd ../homepage
docker compose up -d
```

### 5. Primeiro acesso

- **Plausible**: https://analytics.seudominio.com - Criar conta admin
- **Homepage**: https://dash.seudominio.com - Já funcionando

## 🔧 Scripts Úteis

```bash
# Limpar todos containers Docker
./scripts/cleanup-docker.sh

# Deploy de um stack específico
./scripts/deploy-stack.sh plausible

# Recarregar Caddy
sudo systemctl reload caddy

# Ver logs do Caddy
sudo journalctl -u caddy -f
```

## 📊 Estrutura

```
~/infra-servidor/
├── scripts/           # Scripts de setup e deploy
├── stacks/            # Docker Compose de cada serviço
│   ├── shared/        # Serviços compartilhados (Postgres)
│   ├── plausible/     # Analytics
│   └── homepage/      # Dashboard
├── caddy/             # Configuração do Caddy (symlinked)
└── CLAUDE.md          # Contexto detalhado para Claude Code
```

## 🔐 Segurança

- UFW configurado (SSH, HTTP, HTTPS)
- Containers só acessíveis via localhost (127.0.0.1)
- Caddy gerencia SSL automaticamente
- Fail2ban protege SSH

## 📝 Backup

### Postgres
```bash
# Backup manual
docker exec shared-postgres pg_dumpall -U postgres > backup.sql

# Restaurar
cat backup.sql | docker exec -i shared-postgres psql -U postgres
```

### Plausible (ClickHouse)
```bash
# Eventos estão em volume Docker
docker volume inspect plausible-event-data
```

## 🎓 Recursos

- [Plausible Docs](https://plausible.io/docs)
- [Homepage Docs](https://gethomepage.dev)
- [Caddy Docs](https://caddyserver.com/docs/)

## 📌 TODO

- [ ] Script de backup automatizado
- [ ] Cron job para backups diários
- [ ] Monitoramento de uptime
- [ ] Alertas via webhook
