# Infraestrutura Servidor Melomario - Context File

**Última atualização**: 2026-01-30
**Servidor**: 51.15.177.139 (Scaleway)
**Hostname**: melomario
**OS**: Ubuntu 20.04 LTS
**RAM**: 4GB

---

## 🎯 Objetivo do Projeto

Infraestrutura self-hosted gerenciada via Git, com scripts de replicação rápida e deployment automatizado.

### Princípios

1. **Git como fonte de verdade**: Toda configuração versionada
2. **Scripts de replicação**: Servidor recriável em minutos
3. **Simplicidade**: KISS principle
4. **Segurança em camadas**: Firewall → HTTPS → Headers
5. **Backup-first**: Estratégia clara para cada serviço

---

## 📊 Estado Atual

### Aplicações Fora do Docker
- ✅ **Zeroslides** (Elixir/Phoenix): Rodando via systemd em `~/apps/zeroslides/`
  - Domínio: `zeroslides.melomario.com`
  - Porta interna: 4000
- ✅ **Site Estático** (Jekyll): Servido diretamente pelo Caddy
  - Domínio principal: `mariomelo.com`
  - Aliases: `www.mariomelo.com`, `blog.mariomelo.com`, etc.
  - Diretório: `/home/deploy/site`

### Docker Stacks
- ✅ **Postgres Compartilhado**: `stacks/shared/postgres/`
  - Container: `shared-postgres`
  - Rede: `shared-network`
  - Porta: 5432 (apenas localhost)
  - Limite RAM: 512MB
- ✅ **Plausible Analytics**: `stacks/plausible/`
  - Container: `plausible`
  - ClickHouse: `plausible_events_db`
  - Domínio: `analytics.mariomelo.com`
  - Porta: 8000 (apenas localhost)
  - Limites RAM: 512MB (Plausible) + 512MB (ClickHouse)
- ✅ **Homepage Dashboard**: `stacks/homepage/`
  - Container: `homepage`
  - Domínio: `dash.mariomelo.com`
  - Porta: 3000 (apenas localhost)
  - Limite RAM: 256MB

### Infraestrutura
- ✅ Caddy instalado no host (não em container)
- ✅ Docker + Docker Compose
- ✅ UFW + Fail2ban configurados

---

## 🏗️ Arquitetura

### Decisões Arquiteturais

**Por que Caddy no host?**
- Um único ponto de configuração (Caddyfile)
- SSL automático para todos os domínios
- Reload sem downtime
- Menor overhead que containers separados

**Por que Postgres compartilhado?**
- Reduz uso de memória (4GB é limitado)
- Um ponto de backup
- Fácil adicionar novos bancos (via SQL script)
- Plausible + futuras apps Elixir usam o mesmo

**Por que Homepage?**
- Dashboard leve (256MB RAM)
- Mostra status dos containers
- Mostra métricas do servidor (CPU/RAM/disco)
- Integração com Docker nativa

**Rede Compartilhada (shared-network)**
- Permite comunicação entre Postgres e outros stacks
- Evita exposição de portas desnecessárias
- Facilita adicionar novos serviços

---

## 📁 Estrutura de Diretórios

```
~/infra-servidor/
├── .gitignore
├── README.md              # Documentação principal
├── CLAUDE.md              # Este arquivo (contexto)
│
├── scripts/
│   ├── setup/             # Configuração inicial
│   │   ├── setup-server.sh
│   │   └── setup-caddy.sh
│   ├── deploy/            # Deploy de stacks
│   │   └── deploy-stack.sh
│   ├── reset/             # Limpeza/reset (PERIGOSO!)
│   │   ├── reset-postgres.sh
│   │   ├── reset-plausible.sh
│   │   ├── reset-all.sh
│   │   └── cleanup-docker.sh
│   ├── backup/            # (futuro)
│   └── README.md          # Documentação dos scripts
│
├── caddy/
│   └── Caddyfile          # Symlinked para /etc/caddy/Caddyfile
│
└── stacks/
    ├── shared/
    │   └── postgres/
    │       ├── docker-compose.yml
    │       ├── .env               # NÃO versionado
    │       ├── .env.example       # Versionado
    │       └── init-scripts/
    │           ├── create-databases.sh      # Script com variáveis
    │           └── create-databases.sql.example  # Exemplo
    │
    ├── plausible/
    │   ├── docker-compose.yml
    │   ├── .env               # NÃO versionado
    │   ├── .env.example       # Versionado
    │   └── clickhouse/
    │       ├── clickhouse-config.xml
    │       └── clickhouse-user-config.xml
    │
    └── homepage/
        ├── docker-compose.yml
        └── config/
            ├── services.yaml
            ├── widgets.yaml
            ├── settings.yaml
            └── bookmarks.yaml
```

---

## 🔧 Informações Técnicas

### Portas Utilizadas

| Serviço | Porta | Bind | Acesso |
|---------|-------|------|--------|
| SSH | 22 | 0.0.0.0 | Externo |
| HTTP | 80 | 0.0.0.0 | Caddy (redirect) |
| HTTPS | 443 | 0.0.0.0 | Caddy |
| Postgres | 5432 | 127.0.0.1 | Interno |
| Plausible | 8000 | 127.0.0.1 | Caddy proxy |
| Homepage | 3000 | 127.0.0.1 | Caddy proxy |
| Zeroslides | 4000 | 127.0.0.1 | Caddy proxy |

### Domínios Configurados

| Domínio | Serviço | Tipo |
|---------|---------|------|
| `mariomelo.com` | Site estático (Jekyll) | Arquivos |
| `www.mariomelo.com` | Redirect → mariomelo.com | Redirect |
| `blog.mariomelo.com` | Redirect → mariomelo.com | Redirect |
| `zeroslides.melomario.com` | Zeroslides (Elixir) | Reverse proxy |
| `analytics.mariomelo.com` | Plausible | Reverse proxy |
| `dash.mariomelo.com` | Homepage | Reverse proxy |

### Consumo de RAM (real)

| Serviço | Limite | Uso Real |
|---------|--------|----------|
| Sistema | - | ~800MB |
| Caddy | - | ~50MB |
| Postgres | 512M | ~200MB |
| Plausible | 512M | ~300MB |
| ClickHouse | 512M | ~300MB |
| Homepage | 256M | ~100MB |
| Zeroslides | - | ~300MB |
| **Total** | - | ~2GB |
| **Buffer** | - | ~2GB |

---

## 🚀 Workflow de Deploy

### 1. Desenvolvimento Local

```bash
# Editar arquivos localmente
vim stacks/plausible/docker-compose.yml

# Commitar
git add .
git commit -m "feat: adicionar novo stack"
git push origin main
```

### 2. Deploy no Servidor

```bash
# No servidor
cd ~/infra-servidor
git pull origin main

# Se mudou Caddyfile
./scripts/setup/setup-caddy.sh

# Se mudou algum stack
./scripts/deploy/deploy-stack.sh plausible
```

---

## 🎓 Contexto Pessoal

### Tecnologias Familiares
- Elixir/Phoenix
- Docker básico
- Linux/Ubuntu
- Git

### Tecnologias Implementadas
- Caddy (reverse proxy)
- Infrastructure as Code
- Plausible Analytics
- Homepage Dashboard
- PostgreSQL compartilhado

### Preferências de Comunicação
- ⚠️ Não usar elogios excessivos
- ✅ Direto ao ponto
- ✅ Explicar *por que*, não só *como*
- ✅ Trade-offs explícitos

### Casos de Uso
- **Zeroslides**: Trabalho (apresentações)
- **Site**: Blog pessoal (Jekyll)
- **Plausible**: Analytics dos sites
- **Homepage**: Monitoramento e dashboard

---

## 🚨 Alertas e Cuidados

### Dados Críticos
- ❌ NUNCA commitar `.env` files
- ❌ NUNCA commitar `secrets/`
- ❌ NUNCA commitar `init-scripts/*.sql` (apenas .sql.example)
- ✅ SEMPRE usar `.env.example` com placeholders
- ✅ SEMPRE verificar `.gitignore` antes de commit

### Volumes Docker Críticos
- `shared-postgres-data` → Todos os bancos de dados
- `plausible-event-data` → Eventos do analytics
- `plausible-event-logs` → Logs do ClickHouse
- `stacks/homepage/config/` → Configuração do dashboard

### Antes de Mudanças Grandes
1. Fazer snapshot Scaleway
2. Backup dos volumes Docker
3. Testar em dry-run quando possível
4. Verificar portas disponíveis

---

## 🛠️ Troubleshooting

### Postgres não conecta

```bash
# Verificar se está rodando
docker ps | grep postgres

# Ver logs
docker logs shared-postgres

# Testar conexão
docker exec shared-postgres pg_isready -U postgres

# Resetar (CUIDADO: deleta dados!)
./scripts/reset/reset-postgres.sh
```

### Plausible não inicia / Ordem de inicialização

**Problema**: Plausible tenta conectar no ClickHouse antes dele estar pronto.

**Solução implementada**:
- Healthcheck no ClickHouse: verifica endpoint `/ping`
- `depends_on` com `condition: service_healthy`
- `start_period: 30s` para dar tempo de inicialização

```bash
# Ver logs do ClickHouse
cd stacks/plausible
docker compose logs plausible_events_db

# Ver logs do Plausible
docker compose logs plausible

# Reiniciar na ordem correta
docker compose down
docker compose up -d plausible_events_db  # Esperar ficar healthy
docker compose up -d plausible
```

### Homepage: Host validation failed

**Erro**: `Host validation failed for: dash.mariomelo.com`

**Solução**: Adicionar variável de ambiente `HOMEPAGE_ALLOWED_HOSTS` no docker-compose.yml:

```yaml
environment:
  HOMEPAGE_ALLOWED_HOSTS: "dash.mariomelo.com,localhost,127.0.0.1"
```

### Caddy não recarrega

```bash
# Verificar sintaxe
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs
sudo journalctl -u caddy -f

# Reiniciar (último recurso)
sudo systemctl restart caddy
```

### Site não carrega (502)

```bash
# Verificar se serviço backend está rodando
curl http://localhost:8000  # Plausible
curl http://localhost:3000  # Homepage
curl http://localhost:4000  # Zeroslides

# Verificar Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs do Caddy
sudo journalctl -u caddy -n 50
```

### Porta já em uso

```bash
# Descobrir o que está usando
sudo lsof -i :3000

# Se for serviço systemd
sudo systemctl stop <nome-do-servico>
sudo systemctl disable <nome-do-servico>

# Se for processo avulso
sudo kill <PID>
```

---

## 🔐 Segurança

### Senhas e Secrets

**Onde ficam** (NÃO versionados):
- `stacks/shared/postgres/.env` → Senhas do Postgres
- `stacks/plausible/.env` → Secrets do Plausible + senha do banco
- `stacks/homepage/.env` → (se necessário no futuro)

**Como gerar**:
```bash
# SECRET_KEY_BASE (64 chars)
openssl rand -base64 64 | tr -d '\n'

# TOTP_VAULT_KEY (32 chars)
openssl rand -base64 32 | tr -d '\n'

# Senhas de banco
openssl rand -base64 24
```

**IMPORTANTE**: A senha `PLAUSIBLE_DB_PASSWORD` deve ser:
1. Definida em `stacks/shared/postgres/.env`
2. Usada em `stacks/shared/postgres/init-scripts/create-databases.sh`
3. A MESMA em `stacks/plausible/.env` como `DB_PASSWORD`

### Firewall (UFW)

Portas permitidas:
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

Tudo mais: BLOQUEADO

### Headers de Segurança

Configurados no Caddyfile para cada domínio:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options`
- `X-Frame-Options`
- `Referrer-Policy`

---

## 📚 Referências

### Documentação Oficial
- [Plausible Community Edition](https://github.com/plausible/community-edition)
- [Homepage](https://gethomepage.dev)
- [Caddy](https://caddyserver.com/docs/)
- [PostgreSQL](https://www.postgresql.org/docs/)
- [ClickHouse](https://clickhouse.com/docs)

### Repositório
- Branch principal: `main`
- Commits: Conventional Commits (feat:, fix:, docs:, chore:, etc.)

---

## 🤝 Como Claude Code Pode Ajudar

### Você pode:
1. **Criar/editar arquivos**: docker-compose.yml, scripts, configs
2. **Revisar segurança**: Verificar se secrets estão protegidos
3. **Sugerir melhorias**: Performance, organização
4. **Gerar documentação**: READMEs, troubleshooting
5. **Debugging**: Ajudar a interpretar logs
6. **Scripts**: Criar scripts de automação, backup, deploy

### Não precisa:
- Elogiar o trabalho (só se realmente notável)
- Repetir informações já no contexto
- Over-engineer (KISS)

---

## 📋 Lições Aprendidas

### Docker Compose - Boas Práticas
- **SEMPRE verificar a versão mais recente** no GitHub oficial do projeto antes de implementar
- **NUNCA alterar o docker-compose.yml oficial** - usar `docker-compose.override.yml` para customizações
- Remover `version: '3.8'` (obsoleto e causa warnings)
- Usar sintaxe moderna sem declarar versão

### Healthchecks e Dependências
- `depends_on` básico NÃO espera serviço estar pronto
- Usar `condition: service_healthy` + healthcheck
- `start_period` importante para serviços lentos (ClickHouse precisa 120s)
- Verificar requisitos mínimos de RAM no README oficial (ex: ClickHouse precisa 2GB)

### Redes Docker
- Quando um serviço precisa falar com containers em diferentes docker-compose:
  - DEVE estar explicitamente em múltiplas redes: `[default, shared-network]`
  - Exemplo: Plausible precisa falar com ClickHouse (default) E Postgres externo (shared-network)
- Sempre nomear a rede `default` explicitamente para evitar nomes auto-gerados
- Verificar issues no GitHub se houver problemas de conectividade (ex: issue #247)

### Organização de Scripts
- Subpastas por categoria: setup/, deploy/, reset/
- Scripts destrutivos pedem confirmação explícita
- Documentação em `scripts/README.md`

### Segurança de Secrets
- Init scripts com variáveis de ambiente, não SQL hardcoded
- `.gitignore` para `.env` e `*.sql`
- `.env.example` versionado como referência

### Homepage
- Requer `HOMEPAGE_ALLOWED_HOSTS` para domínios externos
- Background: preferir imagens escuras para tema dark
- PUID/PGID pode precisar ajuste (verificar com `id`)

### Debugging de Stacks Complexos
1. Sempre testar primeiro com setup padrão (sem customizações)
2. Se funcionar, adicionar customizações incrementalmente
3. Consultar issues do GitHub quando encontrar problemas
4. Verificar logs de TODOS os containers, não só do principal
5. Conferir requisitos de hardware (RAM, CPU) no README oficial

---

## 🎯 Próximos Passos

### Prioridade Alta
- [ ] Testar reinicialização completa do servidor
- [ ] Criar primeiro site no Plausible
- [ ] Verificar consumo de RAM após alguns dias

### Prioridade Média
- [ ] Script de backup automatizado (cron)
- [ ] Documentar procedimento de restore
- [ ] Adicionar mais widgets no Homepage (uptime?)
- [ ] Considerar adicionar Grafana (só se 8GB RAM)

### Prioridade Baixa
- [ ] Monitoramento de uptime externo (UptimeRobot?)
- [ ] Alertas via webhook/Telegram
- [ ] Script de update automático dos containers

---

## 📝 Notas de Implementação

### Ordem de Inicialização Correta

1. **Postgres** (primeiro)
   ```bash
   cd stacks/shared/postgres
   docker compose up -d
   ```

2. **Plausible** (depende de Postgres + ClickHouse)
   ```bash
   cd stacks/plausible
   docker compose up -d
   # Aguarda ClickHouse ficar healthy automaticamente
   ```

3. **Homepage** (independente)
   ```bash
   cd stacks/homepage
   docker compose up -d
   ```

### Após Reinicialização do Servidor

Todos os containers sobem automaticamente (`restart: unless-stopped`), mas na ordem correta devido aos healthchecks configurados.

---

**Status Atual**: Infraestrutura funcional com 3 stacks Docker + 2 apps fora do Docker
**Última validação**: 2026-01-30
**Consumo RAM**: ~2GB de 4GB (~50% utilizado)
