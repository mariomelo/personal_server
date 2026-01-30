# Scripts do Servidor

Scripts organizados por categoria para gerenciar a infraestrutura.

## 📁 Estrutura

```
scripts/
├── setup/          # Configuração inicial do servidor
├── deploy/         # Deploy de stacks
├── reset/          # Resetar/limpar stacks
└── backup/         # Backup (futuro)
```

## 🚀 Setup (Configuração Inicial)

### `setup/setup-server.sh`
Instalação inicial completa do servidor:
- Docker + Docker Compose
- Caddy
- UFW (firewall)
- Fail2ban

```bash
./scripts/setup/setup-server.sh
```

### `setup/setup-caddy.sh`
Configuração do Caddy:
- Backup do Caddyfile atual
- Symlink para arquivo do projeto
- Validação da configuração
- Reload do serviço

```bash
./scripts/setup/setup-caddy.sh
```

## 📦 Deploy

### `deploy/deploy-stack.sh`
Deploy de um stack específico.

```bash
# Uso
./scripts/deploy/deploy-stack.sh <nome-do-stack>

# Exemplos
./scripts/deploy/deploy-stack.sh plausible
./scripts/deploy/deploy-stack.sh homepage
```

## 🗑️ Reset (Limpeza)

### `reset/reset-postgres.sh`
⚠️ **PERIGOSO**: Deleta todos os dados do Postgres.
- Para o container
- Remove volume `shared-postgres-data`
- Requer confirmação digitando "sim"

```bash
./scripts/reset/reset-postgres.sh
```

### `reset/reset-plausible.sh`
⚠️ **PERIGOSO**: Deleta dados do Plausible.
- Para containers (Plausible + ClickHouse)
- Remove volumes de eventos
- NÃO deleta banco no Postgres
- Requer confirmação digitando "sim"

```bash
./scripts/reset/reset-plausible.sh
```

### `reset/reset-all.sh`
⚠️⚠️⚠️ **EXTREMAMENTE PERIGOSO**: Reset completo.
- Para TODOS os containers Docker
- Remove TODOS os volumes
- Limpa redes não utilizadas
- Requer confirmação digitando "DELETAR TUDO"

```bash
./scripts/reset/reset-all.sh
```

### `reset/cleanup-docker.sh`
Limpeza geral do Docker:
- Para e remove todos containers
- Opcionalmente remove volumes não utilizados
- Remove redes não utilizadas

```bash
./scripts/reset/cleanup-docker.sh
```

## 📝 Notas

- Todos os scripts de reset pedem confirmação antes de executar
- Scripts estão configurados com `set -e` (param na primeira falha)
- Sempre verifique os logs após executar: `docker compose logs -f`
