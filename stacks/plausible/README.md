# Plausible Analytics - Setup

## 📦 Dois Modos de Operação

### 1. Setup Padrão (Postgres Próprio)

Usa `docker-compose.yml` sem modificações.

```bash
# Configurar .env
cp .env.example .env
vim .env  # Descomentar POSTGRES_PASSWORD

# Subir
docker compose up -d
```

### 2. Setup com Postgres Compartilhado

Usa `docker-compose.override.yml` para compartilhar Postgres com outros serviços.

**Pré-requisitos**:
- Postgres compartilhado rodando em `stacks/shared/postgres`
- Banco `plausible` e usuário `plausible_user` criados

```bash
# Configurar .env
cp .env.example .env
vim .env  # Descomentar SHARED_DB_*

# Subir (Docker Compose detecta o override automaticamente)
docker compose up -d
```

## 🔄 Migrar de Postgres Próprio para Compartilhado

```bash
# 1. Fazer backup do banco próprio
docker exec plausible_db pg_dump -U postgres plausible_db > backup.sql

# 2. Parar tudo
docker compose down

# 3. Ajustar .env (comentar POSTGRES_PASSWORD, descomentar SHARED_DB_*)
vim .env

# 4. Importar backup no Postgres compartilhado
cat backup.sql | docker exec -i shared-postgres psql -U plausible_user -d plausible

# 5. Subir com override
docker compose up -d
```

## 🧹 Remover Postgres Próprio (opcional)

Se não for mais usar:

```bash
docker volume rm plausible-db-data
```

## 🔍 Verificar Qual Modo Está Ativo

```bash
# Ver se override está sendo usado
docker compose config | grep -A 5 "plausible_db:"

# Se mostrar "replicas: 0", está usando Postgres compartilhado
# Se mostrar a config normal, está usando Postgres próprio
```

## ⚠️ Importante

- **NUNCA** modifique `docker-compose.yml` diretamente
- Use sempre `docker-compose.override.yml` para customizações
- O Docker Compose mescla automaticamente os dois arquivos
