# Infraestrutura Servidor Melomario - Context File

**Servidor**: 51.15.177.139 (Scaleway)  
**Hostname**: melomario  
**OS**: Ubuntu 20.04 LTS  
**RAM Atual**: 4GB  
**RAM Planejada**: 8GB (upgrade futuro)

---

## 🎯 Objetivo do Projeto

Criar uma infraestrutura self-hosted completa, organizada via Git, com deployment automatizado via GitHub Actions. Transição de gerenciamento via Portainer para abordagem Infrastructure as Code.

### Princípios de Design

1. **Git como fonte de verdade**: Toda configuração versionada
2. **Simplicidade**: Sem over-engineering
3. **Segurança em camadas**: Firewall → HTTPS → 2FA (futuro) → Yubikey
4. **Backup-first**: Toda aplicação tem estratégia de backup definida
5. **Documentação viva**: READMEs sempre atualizados

---

## 📊 Estado Atual

### Aplicações Rodando
- ✅ **Zeroslides** (Elixir/Phoenix): Deploy via GitHub Actions
  - Localização: `~/apps/zeroslides/`
  - Systemd: `zero-slides.service`
  - Deploy: SSH + tar.gz extraction
- ✅ **Portainer**: Gerenciamento Docker (será removido)

### Infraestrutura
- ✅ Docker + Docker Compose instalados
- ✅ GitHub Actions configurado para Zeroslides
- ⚠️ Caddy NÃO instalado ainda
- ⚠️ Estrutura Git NÃO criada ainda

---

## 🚀 Tarefa Imediata: Instalar OpenCloud

### Contexto
OpenCloud é um fork recente (2025) do ownCloud Infinite Scale (OCIS), escrito em Go. É extremamente leve (~200MB RAM) e não precisa de banco de dados, usando "File Native Backup" (backup via simples snapshot de arquivos).

### Decisões Arquiteturais

**Por que OpenCloud?**
- ✅ Mais leve que Nextcloud/Seafile
- ✅ Sem overhead de banco de dados
- ✅ Backup trivial (tar.gz do diretório)
- ✅ Escrito em Go (mais eficiente que PHP)
- ✅ Suporta WebDAV, OPDS, sincronização

**Por que Caddy no host (não container)?**
- ✅ Um único ponto de configuração (Caddyfile)
- ✅ SSL automático para todos os domínios
- ✅ Reload sem downtime
- ✅ Menor overhead que containers separados
- ✅ Logs centralizados

**Estrutura de Diretórios**
```
~/infra-servidor/               # Repositório Git
├── .gitignore
├── README.md
├── stacks/
│   ├── opencloud/
│   │   ├── docker-compose.yml
│   │   ├── .env              # Não versionado
│   │   ├── .env.example      # Versionado
│   │   └── data/             # Volume, não versionado
│   ├── immich/               # Futuro
│   ├── booklore/             # Futuro
│   └── authelia/             # Futuro (8GB)
├── scripts/
│   ├── backup-opencloud.sh   # Futuro
│   └── update-all.sh         # Futuro
└── docs/
    ├── SETUP.md
    ├── AUTHELIA_FUTURE.md    # Referência para depois
    └── BACKUP_STRATEGY.md    # Futuro
```

### Passos para Instalação

**Ordem de Execução**:

1. **Criar estrutura Git**
   ```bash
   cd ~
   mkdir infra-servidor && cd infra-servidor
   git init
   mkdir -p stacks/opencloud scripts docs
   ```

2. **Criar .gitignore**
   ```gitignore
   # Secrets
   .env
   *.env.local
   secrets/
   
   # Dados
   */data/
   */books/
   */uploads/
   
   # Logs
   *.log
   
   # Backups
   backups/
   ```

3. **Instalar Caddy no host**
   ```bash
   sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
   sudo apt update
   sudo apt install caddy
   ```

4. **Criar docker-compose.yml do OpenCloud**
   - Localização: `stacks/opencloud/docker-compose.yml`
   - Porta: 127.0.0.1:9200 (apenas localhost)
   - Limite de RAM: 300M
   - Healthcheck configurado

5. **Criar .env e .env.example**
   - `.env.example`: versionado, valores placeholder
   - `.env`: não versionado, valores reais

6. **Configurar Caddy**
   - Backup do Caddyfile original
   - Criar novo Caddyfile em `/etc/caddy/Caddyfile`
   - Configurar reverse proxy para OpenCloud
   - Headers de segurança
   - Logs em `/var/log/caddy/`

7. **Subir OpenCloud**
   ```bash
   cd ~/infra-servidor/stacks/opencloud
   docker compose up -d
   docker compose logs -f
   ```

8. **Verificar funcionamento**
   - `curl -I http://localhost:9200`
   - Acessar via browser (substituir domínio)
   - Criar conta admin

9. **Commit inicial**
   ```bash
   git add .gitignore stacks/opencloud/*.{yml,example} README.md docs/
   git commit -m "feat: setup inicial com OpenCloud"
   ```

### Variáveis de Ambiente Necessárias

```env
# stacks/opencloud/.env
OCIS_DOMAIN=cloud.seudominio.com  # SUBSTITUIR
OCIS_ADMIN_PASSWORD=              # GERAR SENHA FORTE
TZ=Europe/Rome
```

### Verificações Pós-Instalação

- [ ] Container OpenCloud está healthy: `docker compose ps`
- [ ] Porta 9200 respondendo: `curl http://localhost:9200`
- [ ] Caddy está rodando: `sudo systemctl status caddy`
- [ ] HTTPS funcionando: `curl -I https://cloud.seudominio.com`
- [ ] Logs sem erros: `docker compose logs opencloud`
- [ ] Consegue criar conta admin via web

---

## 📋 Backlog Estruturado

### FASE 1: Fundação (Atual - 4GB RAM)

#### 1.1 OpenCloud Básico [EM ANDAMENTO]
- [ ] Criar estrutura Git
- [ ] Instalar Caddy no host
- [ ] Configurar OpenCloud
- [ ] Primeiro commit
- [ ] Documentar no README.md
- [ ] Testar upload/download de arquivos

#### 1.2 Documentação Inicial
- [ ] README.md principal com overview
- [ ] docs/SETUP.md com instruções detalhadas
- [ ] docs/TROUBLESHOOTING.md com problemas comuns
- [ ] Documentar comandos úteis

#### 1.3 Backup OpenCloud (Simples)
- [ ] Script `scripts/backup-opencloud.sh`
- [ ] Cron job para backup diário
- [ ] Testar restauração (CRÍTICO)
- [ ] Upload para Hetzner Storage Box via rclone
- [ ] Documentar em docs/BACKUP_STRATEGY.md

#### 1.4 Segurança Básica
- [ ] Configurar UFW (firewall)
- [ ] Instalar e configurar Fail2ban
- [ ] SSH: desabilitar password auth
- [ ] SSH: apenas chave pública
- [ ] Verificar permissões em .env files (600)

---

### FASE 2: Expansão (4GB RAM)

#### 2.1 Preparar para Reset
- [ ] Backup completo do Zeroslides
- [ ] Backup do Portainer (exportar configs)
- [ ] Listar todas as portas em uso
- [ ] Documentar todos os serviços atuais
- [ ] Criar checklist de reinstalação

#### 2.2 Reset e Clean Install
- [ ] Fazer snapshot Scaleway (ANTES DE TUDO)
- [ ] Reset do servidor
- [ ] Instalar Ubuntu 20.04 fresh
- [ ] Configurar SSH keys
- [ ] Instalar Docker + Docker Compose
- [ ] Instalar Caddy
- [ ] Clonar repositório infra-servidor

#### 2.3 Migrar Zeroslides para Estrutura Git
- [ ] Criar `stacks/zeroslides/`
- [ ] Adaptar GitHub Actions para nova estrutura
- [ ] Mover de `~/apps/` para `~/infra-servidor/stacks/`
- [ ] Testar deploy via Actions
- [ ] Atualizar documentação

#### 2.4 Adicionar Jekyll (Blog Estático)
- [ ] Configurar build do Jekyll
- [ ] Servir via Caddy (arquivos estáticos)
- [ ] Configurar em `blog.seudominio.com`
- [ ] Script de deploy/rebuild
- [ ] Backup (simples rsync do _site/)

#### 2.5 Adicionar Immich (Fotos)
- [ ] Criar `stacks/immich/docker-compose.yml`
- [ ] Configurar PostgreSQL
- [ ] Configurar Redis
- [ ] Configurar machine learning (opcional)
- [ ] Limitar RAM (600MB total)
- [ ] Configurar backup (PostgreSQL dump + uploads/)
- [ ] Integrar com Caddy
- [ ] Testar upload de fotos

#### 2.6 Adicionar Booklore (Ebooks)
- [ ] Criar `stacks/booklore/docker-compose.yml`
- [ ] Configurar MariaDB
- [ ] Limitar RAM (400MB total)
- [ ] Configurar backup (DB + books/)
- [ ] Integrar com Caddy
- [ ] Testar import de ebooks
- [ ] Configurar OPDS para leitores

---

### FASE 3: Upgrade e Segurança Avançada (8GB RAM)

#### 3.1 Upgrade do Servidor
- [ ] Fazer backup completo
- [ ] Fazer snapshot Scaleway
- [ ] Upgrade RAM: 4GB → 8GB (via console Scaleway)
- [ ] Reiniciar e verificar RAM: `free -h`
- [ ] Monitorar consumo por 24h

#### 3.2 Implementar Authelia + Yubikey
- [ ] Criar `stacks/authelia/docker-compose.yml`
- [ ] Configurar Redis
- [ ] Criar `configuration.yml`
- [ ] Criar `users_database.yml` (você + Ewok)
- [ ] Gerar secrets (jwt, session, encryption)
- [ ] Integrar com Caddy (forward_auth)
- [ ] Testar login com senha
- [ ] Registrar Yubikey principal
- [ ] Registrar Yubikey backup
- [ ] Configurar TOTP como fallback
- [ ] Testar SSO entre serviços
- [ ] Documentar em docs/AUTHELIA_SETUP.md

#### 3.3 Proteger Todos os Serviços
- [ ] OpenCloud: forward_auth Authelia
- [ ] Immich: forward_auth Authelia
- [ ] Booklore: forward_auth Authelia
- [ ] Zeroslides: forward_auth Authelia (opcional)
- [ ] Portainer: remover (não precisa mais)
- [ ] Testar Yubikey em cada serviço

#### 3.4 Monitoramento
- [ ] Instalar Uptime Kuma (opcional)
- [ ] Healthchecks para cada serviço
- [ ] Alertas via Telegram/Email
- [ ] Dashboard de recursos (Grafana? ou só htop)

---

### FASE 4: Refinamento (Contínuo)

#### 4.1 Automação de Backups
- [ ] Script unificado `scripts/backup-all.sh`
- [ ] Backup diário: Hetzner Storage Box
- [ ] Backup semanal: Scaleway Snapshots
- [ ] Backup mensal: Blu-ray BD-R (50GB)
- [ ] Testar restauração de cada serviço
- [ ] Documentar procedimento de disaster recovery

#### 4.2 CI/CD Avançado
- [ ] GitHub Actions: deploy de toda a stack
- [ ] GitHub Actions: rodar testes de saúde
- [ ] GitHub Actions: backup antes de deploy
- [ ] Deploy com rollback automático em caso de falha

#### 4.3 Melhorias de Performance
- [ ] PostgreSQL compartilhado para apps Elixir
- [ ] Tuning do Caddy (cache, gzip)
- [ ] Configurar swap se necessário
- [ ] Monitorar e otimizar consumo de RAM

#### 4.4 Documentação Final
- [ ] Runbook completo de operação
- [ ] Troubleshooting guide expandido
- [ ] Diagrama de arquitetura (mermaid?)
- [ ] Vídeo walkthrough (opcional)

---

## 🔧 Informações Técnicas

### Portas Utilizadas
- 22: SSH
- 80: HTTP (Caddy → redireciona 443)
- 443: HTTPS (Caddy)
- 9200: OpenCloud (localhost only)
- 9091: Authelia (futuro, localhost only)
- 2283: Immich (futuro, localhost only)
- 41935: Booklore (futuro, localhost only)
- 4000: Zeroslides (localhost only)

### Domínios Necessários
Criar registros DNS tipo A:
- `cloud.seudominio.com → 51.15.177.139`
- `auth.seudominio.com → 51.15.177.139` (futuro)
- `photos.seudominio.com → 51.15.177.139` (futuro)
- `books.seudominio.com → 51.15.177.139` (futuro)
- `blog.seudominio.com → 51.15.177.139` (futuro)
- `slides.seudominio.com → 51.15.177.139`

### Usuários
- **Usuário principal**: Usuário atual do sistema (para tudo)
- **Usuário Docker**: Mesmo usuário (no grupo docker)
- **Usuário dedicado**: NÃO criar (decisão: usar usuário atual)

### Hardware Limits
**Configuração Atual (4GB)**:
- Sistema: 800MB
- OpenCloud: 200-300MB
- Zeroslides: 300-400MB
- Buffer: ~3GB

**Configuração Futura (8GB)**:
- Sistema: 800MB
- Caddy: 50MB
- Authelia: 80MB
- OpenCloud: 200MB
- Immich: 800MB
- Booklore: 400MB
- Zeroslides: 300MB
- Outras apps Elixir: 200-400MB cada
- Buffer: ~5GB

---

## 🎓 Contexto Pessoal

### Tecnologias Familiares
- Elixir/Phoenix (linguagem principal)
- GitHub Actions (já usa para Zeroslides)
- Docker básico (via Portainer)
- Linux/Ubuntu

### Tecnologias Novas
- Caddy (novo)
- Infrastructure as Code via Git (novo approach)
- Authelia/WebAuthn (futuro)

### Preferências
- ⚠️ Não usar elogios excessivos ("great job!", "excellent!")
- ✅ Direto ao ponto
- ✅ Explicar *por que*, não só *como*
- ✅ Trade-offs explícitos quando há escolhas

### Casos de Uso
- **OpenCloud**: Sync de arquivos pessoais (você + Ewok)
- **Immich**: Backup de fotos do celular
- **Booklore**: Biblioteca de ebooks (vegano, filosofia, Scrum)
- **Zeroslides**: Aplicação de apresentações (trabalho)
- **Jekyll**: Blog pessoal

---

## 🚨 Alertas e Cuidados

### Antes de Executar Comandos
- ⚠️ Sempre fazer backup antes de mudanças grandes
- ⚠️ Testar em dry-run quando possível
- ⚠️ Verificar se há serviços rodando na porta antes de subir novos

### Dados Sensíveis
- ❌ NUNCA commitar arquivos .env
- ❌ NUNCA commitar secrets/
- ✅ SEMPRE usar .env.example com placeholders
- ✅ SEMPRE verificar .gitignore antes de commit

### Backup Critical
- 📁 OpenCloud: `/home/usuario/infra-servidor/stacks/opencloud/data/`
- 📁 Immich: `/home/usuario/infra-servidor/stacks/immich/{uploads,database}/`
- 📁 Booklore: `/home/usuario/infra-servidor/stacks/booklore/{books,data,mariadb}/`

---

## 📚 Referências

### Documentação Oficial
- OpenCloud: https://opencloud.eu/
- Authelia: https://www.authelia.com/
- Caddy: https://caddyserver.com/docs/
- Immich: https://immich.app/docs/
- Booklore: https://github.com/booklore-app/booklore

### Repositório
- GitHub: (a ser criado)
- Branch principal: `main`

---

## 🤝 Como Ajudar

### Claude Code, você pode:

1. **Criar arquivos**: docker-compose.yml, scripts, configs
2. **Revisar segurança**: Verificar se secrets estão protegidos
3. **Sugerir melhorias**: Performance, organização, melhores práticas
4. **Gerar documentação**: READMEs, troubleshooting guides
5. **Criar checklists**: Para cada fase do backlog
6. **Debugging**: Ajudar a interpretar logs de erro

### O que você NÃO precisa fazer:

- Elogiar o trabalho (só se realmente notável)
- Repetir informações já no contexto
- Sugerir soluções que não cabem no hardware (4GB agora, 8GB depois)
- Over-engineer (KISS principle)

---

## 🎯 Próximos Passos Imediatos

1. Revisar este documento
2. Criar estrutura Git inicial
3. Instalar e configurar Caddy
4. Criar docker-compose.yml do OpenCloud
5. Subir OpenCloud
6. Testar funcionamento
7. Primeiro commit no Git
8. Criar README.md

**Foco**: Fazer OpenCloud funcionar PRIMEIRO. Depois pensamos no resto.

---

**Última atualização**: 2026-01-09  
**Status**: Fase 1.1 em andamento (OpenCloud)
