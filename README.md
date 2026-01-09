# Infraestrutura Servidor Melomario

Repositório centralizado para gerenciamento de toda a infraestrutura self-hosted via Infrastructure as Code.

## Servidor

- **IP**: 51.15.177.139 (Scaleway)
- **Hostname**: melomario
- **OS**: Ubuntu 20.04 LTS
- **RAM**: 4GB (upgrade para 8GB planejado)

## Princípios

1. **Git como fonte de verdade**: Toda configuração versionada
2. **Simplicidade**: Sem over-engineering
3. **Segurança em camadas**: Firewall → HTTPS → 2FA (futuro) → Yubikey
4. **Backup-first**: Toda aplicação tem estratégia de backup definida
5. **Documentação viva**: READMEs sempre atualizados

## Estrutura

```
.
├── stacks/              # Docker Compose stacks
│   ├── opencloud/      # OpenCloud (file sync)
│   ├── immich/         # Immich (fotos) - futuro
│   ├── booklore/       # Booklore (ebooks) - futuro
│   └── authelia/       # Authelia (SSO + 2FA) - futuro
├── scripts/            # Scripts de automação
│   └── backup-opencloud.sh - futuro
└── docs/               # Documentação adicional
    └── SETUP.md
```

## Aplicações

### OpenCloud (Atual)

File sync self-hosted baseado em ownCloud Infinite Scale (OCIS).

- **Stack**: `stacks/opencloud/`
- **Porta**: 9200 (localhost only)
- **RAM**: ~200-300MB
- **Backup**: Snapshot do diretório `data/`

**Primeira instalação**:

```bash
cd ~/infra-servidor/stacks/opencloud

# 1. Configurar variáveis
cp .env.example .env
nano .env  # Editar OCIS_DOMAIN e OCIS_ADMIN_PASSWORD

# 2. Subir container
docker compose up -d

# 3. Verificar logs
docker compose logs -f

# 4. Verificar saúde
docker compose ps
curl -I http://localhost:9200
```

**Caddy reverse proxy** (configurar em `/etc/caddy/Caddyfile`):

```caddy
cloud.melomario.com {
    reverse_proxy localhost:9200

    # Headers de segurança
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
    }

    # Logs
    log {
        output file /var/log/caddy/opencloud.log
        format json
    }
}
```

Depois de editar: `sudo systemctl reload caddy`

### Zeroslides (Existente)

Aplicação Elixir/Phoenix para apresentações.

- **Localização**: `~/apps/zeroslides/` (será migrado para `stacks/`)
- **Deploy**: GitHub Actions via SSH
- **Porta**: 4000 (localhost only)

## Comandos Úteis

### OpenCloud

```bash
# Ver logs
cd ~/infra-servidor/stacks/opencloud && docker compose logs -f

# Restart
docker compose restart

# Parar
docker compose down

# Update
docker compose pull && docker compose up -d
```

### Caddy

```bash
# Status
sudo systemctl status caddy

# Reload configuração
sudo systemctl reload caddy

# Validar Caddyfile
sudo caddy validate --config /etc/caddy/Caddyfile

# Ver logs
sudo journalctl -u caddy -f
```

### Docker

```bash
# Ver containers rodando
docker ps

# Ver uso de recursos
docker stats

# Limpar recursos não usados
docker system prune -a
```

## Roadmap

- [x] Estrutura Git inicial
- [x] OpenCloud configurado
- [ ] Documentação em `docs/SETUP.md`
- [ ] Script de backup do OpenCloud
- [ ] Migrar Zeroslides para estrutura Git
- [ ] Adicionar Immich (fotos)
- [ ] Adicionar Booklore (ebooks)
- [ ] Upgrade RAM para 8GB
- [ ] Implementar Authelia + Yubikey

## Segurança

### Dados Sensíveis

- **NUNCA** commitar arquivos `.env`
- **SEMPRE** usar `.env.example` com placeholders
- Verificar `.gitignore` antes de cada commit
- Permissões dos `.env`: `chmod 600 stacks/*/.env`

### Backups Críticos

- OpenCloud: `~/infra-servidor/stacks/opencloud/data/`
- Immich (futuro): `~/infra-servidor/stacks/immich/{uploads,database}/`
- Booklore (futuro): `~/infra-servidor/stacks/booklore/{books,data,mariadb}/`

## Suporte

Ver documentação completa em `CLAUDE.md` e `docs/`.
