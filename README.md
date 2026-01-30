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

### Aplicações (Fora do Docker)
- **Zeroslides** (Elixir/Phoenix)
  - Apresentações interativas
  - Domínio: `zeroslides.melomario.com`
  - Systemd service

- **Site Pessoal** (Jekyll)
  - Blog estático
  - Domínio: `mariomelo.com`
  - Servido diretamente pelo Caddy

### Docker Stacks
- **Postgres Compartilhado**
  - Banco de dados para múltiplos serviços
  - Limite RAM: 512MB

- **Plausible Analytics**
  - Web analytics open-source
  - Domínio: `analytics.mariomelo.com`
  - Plausible (512MB) + ClickHouse (512MB)

- **Homepage Dashboard**
  - Monitoramento e status dos serviços
  - Domínio: `dash.mariomelo.com`
  - Limite RAM: 256MB

## 🚀 Setup Inicial

### 1. No servidor

```bash
# Clonar repositório
git clone <seu-repo> ~/infra-servidor
cd ~/infra-servidor

# Setup inicial (Docker, Caddy, firewall)
chmod +x scripts/**/*.sh
./scripts/setup/setup-server.sh

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
./scripts/setup/setup-caddy.sh
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

- **Homepage**: https://dash.mariomelo.com
- **Plausible**: https://analytics.mariomelo.com (criar conta admin no primeiro acesso)
- **Site**: https://mariomelo.com
- **Zeroslides**: https://zeroslides.melomario.com

## 🔧 Scripts Úteis

```bash
# Deploy de um stack específico
./scripts/deploy/deploy-stack.sh plausible

# Resetar Postgres (⚠️ deleta dados!)
./scripts/reset/reset-postgres.sh

# Resetar Plausible (⚠️ deleta eventos!)
./scripts/reset/reset-plausible.sh

# Limpar todos containers Docker
./scripts/reset/cleanup-docker.sh

# Recarregar Caddy
sudo systemctl reload caddy

# Ver logs do Caddy
sudo journalctl -u caddy -f
```

Ver documentação completa dos scripts em: [`scripts/README.md`](scripts/README.md)

## 📊 Estrutura

```
~/infra-servidor/
├── scripts/
│   ├── setup/         # Configuração inicial
│   ├── deploy/        # Deploy de stacks
│   ├── reset/         # Limpeza/reset
│   └── README.md      # Documentação dos scripts
├── stacks/
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

## 📌 Próximos Passos

### Prioridade Alta
- [ ] Testar reinicialização completa do servidor
- [ ] Criar primeiro site no Plausible
- [ ] Verificar consumo de RAM após alguns dias

### Prioridade Média
- [ ] Script de backup automatizado
- [ ] Cron job para backups diários
- [ ] Documentar procedimento de restore completo

### Prioridade Baixa
- [ ] Monitoramento de uptime externo
- [ ] Alertas via webhook/Telegram

## 🎓 Lições Aprendidas

- ✅ Healthchecks são essenciais para ordem de inicialização
- ✅ Rede compartilhada facilita comunicação entre containers
- ✅ Scripts organizados em subpastas melhoram manutenibilidade
- ✅ Senhas em `.env`, nunca em arquivos versionados
- ✅ `version` obsoleto no docker-compose (Docker Compose v2)
