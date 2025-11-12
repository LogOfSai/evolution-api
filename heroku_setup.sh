#!/bin/bash

# Script de configuração rápida para Heroku
# Uso: ./heroku_setup.sh nome-da-app

set -e

APP_NAME=$1

if [ -z "$APP_NAME" ]; then
    echo "❌ Erro: Nome da aplicação não fornecido"
    echo "Uso: ./heroku_setup.sh nome-da-app"
    exit 1
fi

echo "🚀 Configurando Evolution API no Heroku"
echo "📱 App: $APP_NAME"
echo ""

# Verificar se Heroku CLI está instalado
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI não encontrado. Instale: https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

# Verificar se está logado no Heroku
if ! heroku auth:whoami &> /dev/null; then
    echo "❌ Você não está logado no Heroku. Execute: heroku login"
    exit 1
fi

echo "✅ Heroku CLI detectado"
echo ""

# Criar aplicação (se não existir)
echo "📦 Criando aplicação no Heroku..."
heroku create $APP_NAME 2>/dev/null || echo "ℹ️  Aplicação $APP_NAME já existe, continuando..."
echo ""

# Adicionar PostgreSQL
echo "🗄️  Adicionando PostgreSQL..."
heroku addons:create heroku-postgresql:essential-0 -a $APP_NAME 2>/dev/null || echo "ℹ️  PostgreSQL já existe"
echo ""

# Adicionar Redis
echo "💾 Adicionando Redis..."
heroku addons:create heroku-redis:mini -a $APP_NAME 2>/dev/null || echo "ℹ️  Redis já existe"
echo ""

# Aguardar provisionamento
echo "⏳ Aguardando provisionamento dos addons..."
sleep 5

# Obter URLs dos addons
DATABASE_URL=$(heroku config:get DATABASE_URL -a $APP_NAME)
REDIS_URL=$(heroku config:get REDIS_URL -a $APP_NAME)

echo "✅ Database URL configurada"
echo "✅ Redis URL configurada"
echo ""

# Gerar chave API aleatória
API_KEY=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

echo "🔧 Configurando variáveis de ambiente..."

# Configurar variáveis essenciais
heroku config:set \
    DATABASE_PROVIDER=postgresql \
    DATABASE_CONNECTION_URI="$DATABASE_URL" \
    AUTHENTICATION_API_KEY="$API_KEY" \
    SERVER_URL="https://$APP_NAME.herokuapp.com" \
    SERVER_PORT=8080 \
    NODE_ENV=production \
    CACHE_REDIS_ENABLED=true \
    CACHE_REDIS_URI="$REDIS_URL" \
    LOG_LEVEL=ERROR \
    LOG_COLOR=false \
    WEBSOCKET_ENABLED=false \
    DATABASE_SAVE_DATA_INSTANCE=true \
    DATABASE_SAVE_DATA_NEW_MESSAGE=true \
    DATABASE_SAVE_MESSAGE_UPDATE=true \
    DATABASE_SAVE_DATA_CONTACTS=true \
    DATABASE_SAVE_DATA_CHATS=true \
    DEL_INSTANCE=false \
    -a $APP_NAME

echo ""
echo "✅ Variáveis de ambiente configuradas!"
echo ""

# Adicionar remote do Heroku (se não existir)
if ! git remote | grep -q heroku; then
    echo "🔗 Adicionando remote do Heroku..."
    heroku git:remote -a $APP_NAME
    echo "✅ Remote adicionado"
else
    echo "ℹ️  Remote do Heroku já existe"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ CONFIGURAÇÃO CONCLUÍDA!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Informações da aplicação:"
echo "   App: $APP_NAME"
echo "   URL: https://$APP_NAME.herokuapp.com"
echo "   API Key: $API_KEY"
echo ""
echo "⚠️  IMPORTANTE: Salve a API Key acima em local seguro!"
echo ""
echo "🚀 Próximos passos:"
echo "   1. Faça commit das suas alterações:"
echo "      git add ."
echo "      git commit -m 'feat: configure for Heroku deployment'"
echo ""
echo "   2. Faça o deploy:"
echo "      git push heroku main"
echo ""
echo "   3. Verifique os logs:"
echo "      heroku logs --tail -a $APP_NAME"
echo ""
echo "   4. Abra a aplicação:"
echo "      heroku open -a $APP_NAME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
