# Deploy da Evolution API no Heroku

## Pré-requisitos

1. Conta no Heroku
2. Heroku CLI instalado
3. Git instalado

## Passos para Deploy

### 1. Criar aplicação no Heroku

```bash
heroku create nome-da-sua-app
```

### 2. Adicionar PostgreSQL (Recomendado)

```bash
heroku addons:create heroku-postgresql:essential-0
```

Ou para ambiente de desenvolvimento/testes:

```bash
heroku addons:create heroku-postgresql:mini
```

### 3. Configurar variáveis de ambiente obrigatórias

**IMPORTANTE**: A Evolution API agora mapeia automaticamente `DATABASE_URL` para `DATABASE_CONNECTION_URI`, então você NÃO precisa configurar manualmente a URL do banco.

```bash
# Database Provider (CRÍTICO - deve ser configurado antes do deploy)
heroku config:set DATABASE_PROVIDER=postgresql

# Authentication (OBRIGATÓRIO)
heroku config:set AUTHENTICATION_API_KEY=sua_chave_api_segura

# Server Configuration
heroku config:set SERVER_URL=https://nome-da-sua-app.herokuapp.com
heroku config:set SERVER_PORT=8080

# Node Environment
heroku config:set NODE_ENV=production
```

**Nota**: O Heroku cria automaticamente a variável `DATABASE_URL` quando você adiciona o PostgreSQL. A aplicação agora detecta e mapeia isso automaticamente para `DATABASE_CONNECTION_URI`.

### 4. Configurar Redis (Opcional mas recomendado)

```bash
# Adicionar Redis
heroku addons:create heroku-redis:mini

# A URL do Redis será configurada automaticamente como REDIS_URI
# Configure o cache para usar Redis
heroku config:set CACHE_REDIS_ENABLED=true
heroku config:set CACHE_REDIS_URI=$(heroku config:get REDIS_URL)
```

### 5. Configurações adicionais importantes

```bash
# WebSocket Configuration
heroku config:set WEBSOCKET_ENABLED=false
heroku config:set WEBSOCKET_GLOBAL_EVENTS=false

# Instance Settings
heroku config:set DEL_INSTANCE=false
heroku config:set DEL_TEMP_INSTANCES=true

# Database save options
heroku config:set DATABASE_SAVE_DATA_INSTANCE=true
heroku config:set DATABASE_SAVE_DATA_NEW_MESSAGE=true
heroku config:set DATABASE_SAVE_MESSAGE_UPDATE=true
heroku config:set DATABASE_SAVE_DATA_CONTACTS=true
heroku config:set DATABASE_SAVE_DATA_CHATS=true

# Logs
heroku config:set LOG_LEVEL=ERROR
heroku config:set LOG_COLOR=false
```

### 6. Deploy da aplicação

```bash
git push heroku main
```

Ou se estiver em outra branch:

```bash
git push heroku sua-branch:main
```

### 7. Executar migrations do banco de dados

As migrations são executadas automaticamente através do `Procfile` na fase de `release`. 
Caso precise executar manualmente:

```bash
heroku run npm run db:deploy
```

### 8. Verificar logs

```bash
heroku logs --tail
```

### 9. Escalar dynos (se necessário)

```bash
heroku ps:scale web=1
```

## Variáveis de Ambiente Essenciais

### Obrigatórias

- `DATABASE_PROVIDER` - Tipo de banco (postgresql ou mysql)
- `DATABASE_CONNECTION_URI` - URL de conexão do banco (gerada automaticamente pelo Heroku Postgres)
- `AUTHENTICATION_API_KEY` - Chave de autenticação da API
- `SERVER_URL` - URL pública da sua aplicação

### Recomendadas

- `CACHE_REDIS_ENABLED` - Habilitar cache Redis (true/false)
- `CACHE_REDIS_URI` - URL do Redis (gerada automaticamente se usar heroku-redis)
- `LOG_LEVEL` - Nível de log (ERROR, WARN, INFO, DEBUG)
- `WEBSOCKET_ENABLED` - Habilitar WebSocket (true/false)

## Verificação de Configuração

```bash
# Ver todas as variáveis configuradas
heroku config

# Ver informações da aplicação
heroku info

# Ver status dos addons
heroku addons
```

## Troubleshooting

### Build falha com erros de Prisma

Certifique-se de que:
1. `DATABASE_PROVIDER` está configurado antes do deploy
2. A variável `DATABASE_CONNECTION_URI` existe

```bash
heroku config:set DATABASE_PROVIDER=postgresql
```

### Aplicação não inicia

```bash
# Verificar logs
heroku logs --tail

# Reiniciar aplicação
heroku restart

# Verificar dynos
heroku ps
```

### Migrations não executam

```bash
# Executar manualmente
heroku run npm run db:deploy

# Verificar status do banco
heroku pg:info
```

### Erro de conexão com banco de dados

O Heroku configura automaticamente a variável `DATABASE_URL`. Você precisa mapeá-la:

```bash
# Se DATABASE_URL não estiver mapeada para DATABASE_CONNECTION_URI
heroku config:set DATABASE_CONNECTION_URI=$(heroku config:get DATABASE_URL)
```

## Limitações do Heroku

1. **Armazenamento efêmero**: Arquivos salvos localmente são perdidos quando o dyno reinicia
   - Configure S3 ou MinIO para armazenamento de mídia
   
2. **Timeout de 30 segundos**: Requisições HTTP devem responder em até 30 segundos
   
3. **Dyno sleep**: No plano gratuito/hobby, dynos dormem após 30 minutos de inatividade

## Armazenamento de Mídia (S3/MinIO)

Para produção, configure armazenamento externo:

```bash
# AWS S3
heroku config:set S3_ENABLED=true
heroku config:set S3_ACCESS_KEY=sua_access_key
heroku config:set S3_SECRET_KEY=sua_secret_key
heroku config:set S3_BUCKET=seu_bucket
heroku config:set S3_REGION=us-east-1
```

## Monitoramento

```bash
# Metrics básicos
heroku logs --tail | grep "Error"

# Adicionar logging externo (opcional)
heroku addons:create papertrail
```

## Comandos Úteis

```bash
# Abrir aplicação no browser
heroku open

# Acessar console
heroku run bash

# Ver processos ativos
heroku ps

# Escalar aplicação
heroku ps:scale web=2

# Desativar manutenção
heroku maintenance:off
```

## Segurança

1. **NUNCA** commite o arquivo `.env` com credenciais
2. Use `heroku config:set` para todas as variáveis sensíveis
3. Configure `AUTHENTICATION_API_KEY` forte
4. Limite `CORS_ORIGIN` em produção
5. Configure SSL/TLS no Heroku (automático em custom domains)

## Suporte

Para mais informações sobre a Evolution API:
- GitHub: https://github.com/EvolutionAPI/evolution-api
- Documentação: https://doc.evolution-api.com

Para suporte do Heroku:
- Dev Center: https://devcenter.heroku.com/
- Status: https://status.heroku.com/
