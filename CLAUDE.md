# Infraestrutura Servidor Melomario - Context File

**Última atualização**: 2026-01-29
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
- ✅ **Site Estático**: Servido diretamente pelo Caddy

### Docker Stacks
- ✅ **Postgres Compartilhado**: `stacks/shared/postgres/`
- ✅ **Plausible Analytics**: `stacks/plausible/`
- ✅ **Homepage Dashboard**: `stacks/homepage/`

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

---

## 📁 Estrutura de Diretórios

```
~/infra-servidor/
├── .gitignore
├── README.md              # Documentação principal
├── CLAUDE.md              # Este arquivo (contexto)
│
├── scripts/
│   ├── setup-server.sh    # Setup inicial completo
│   ├── setup-caddy.sh     # Configurar Caddy (backup + symlink)
│   ├── cleanup-docker.sh  # Remover containers/volumes
│   └── deploy-stack.sh    # Deploy de stack específico
│
├── caddy/
│   └── Caddyfile          # Symlinked para /etc/caddy/Caddyfile
│
└── stacks/
    ├── shared/
    │   └── postgres/
    │       ├── docker-compose.yml
    │       ├── .env.example
    │       └── init-scripts/
    │           └── create-databases.sql
    │
    ├── plausible/
    │   ├── docker-compose.yml
    │   ├── .env.example
    │   └── clickhouse/         # Configs do ClickHouse
    │
    └── homepage/
        ├── docker-compose.yml
        └── config/              # YAMLs de configuração
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

### Domínios

Criar registros DNS tipo A apontando para `51.15.177.139`:
- `slides.seudominio.com` → Zeroslides
- `seudominio.com` → Site estático
- `analytics.seudominio.com` → Plausible
- `dash.seudominio.com` → Homepage

### Consumo de RAM (estimado)

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
./scripts/setup-caddy.sh

# Se mudou algum stack
./scripts/deploy-stack.sh plausible
```

---

## 🎓 Contexto Pessoal

### Tecnologias Familiares
- Elixir/Phoenix
- Docker básico
- Linux/Ubuntu
- Git

### Tecnologias Novas
- Caddy (aprendendo)
- Infrastructure as Code (novo approach)
- Plausible

### Preferências de Comunicação
- ⚠️ Não usar elogios excessivos
- ✅ Direto ao ponto
- ✅ Explicar *por que*, não só *como*
- ✅ Trade-offs explícitos

### Casos de Uso
- **Zeroslides**: Trabalho (apresentações)
- **Site**: Blog pessoal
- **Plausible**: Analytics dos sites
- **Homepage**: Monitoramento

---

## 🚨 Alertas e Cuidados

### Dados Críticos
- ❌ NUNCA commitar `.env` files
- ❌ NUNCA commitar `secrets/`
- ✅ SEMPRE usar `.env.example` com placeholders
- ✅ SEMPRE verificar `.gitignore` antes de commit

### Volumes Docker Críticos
- `shared-postgres-data` → Todos os bancos
- `plausible-event-data` → Eventos do analytics
- `stacks/homepage/config/` → Configuração do dashboard

### Antes de Mudanças Grandes
1. Fazer snapshot Scaleway
2. Testar em dry-run quando possível
3. Verificar portas disponíveis

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
```

### Plausible não inicia
```bash
# Ver logs
cd stacks/plausible
docker compose logs -f

# Verificar se Postgres está healthy
docker ps
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

# Verificar Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile
```

---

## 📚 Referências

### Documentação Oficial
- [Plausible Community Edition](https://github.com/plausible/community-edition)
- [Homepage](https://gethomepage.dev)
- [Caddy](https://caddyserver.com/docs/)
- [PostgreSQL](https://www.postgresql.org/docs/)

### Repositório
- Branch principal: `main`
- Commits: Conventional Commits (feat:, fix:, docs:, etc.)

---

## 🤝 Como Claude Code Pode Ajudar

### Você pode:
1. **Criar/editar arquivos**: docker-compose.yml, scripts, configs
2. **Revisar segurança**: Verificar se secrets estão protegidos
3. **Sugerir melhorias**: Performance, organização
4. **Gerar documentação**: READMEs, troubleshooting
5. **Debugging**: Ajudar a interpretar logs

### Não precisa:
- Elogiar o trabalho (só se realmente notável)
- Repetir informações já no contexto
- Over-engineer (KISS)

---

## 📋 Backlog

### Prioridade Alta
- [ ] Testar deploy completo no servidor
- [ ] Criar primeiro site no Plausible
- [ ] Ajustar configs do Homepage (domínios reais)

### Prioridade Média
- [ ] Script de backup automatizado (cron)
- [ ] Documentar procedimento de restore
- [ ] Adicionar mais serviços ao Homepage

### Prioridade Baixa
- [ ] Monitoramento de uptime externo
- [ ] Alertas via webhook/Telegram
- [ ] Dashboard Grafana (só se necessário)

---

## 🎯 Próximos Passos

1. ✅ Criar estrutura de scripts
2. ✅ Configurar Postgres compartilhado
3. ✅ Configurar Plausible
4. ✅ Configurar Homepage
5. ⏳ Testar no servidor
6. ⏳ Ajustar domínios reais
7. ⏳ Primeiro backup manual

**Status**: Estrutura criada, aguardando deploy no servidor
