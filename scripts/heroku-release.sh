#!/bin/bash

# Heroku Release Phase Script
# Ensures DATABASE_CONNECTION_URI is set before running migrations

echo "🔧 Preparing database for deployment..."

# Map Heroku's DATABASE_URL to Evolution API's DATABASE_CONNECTION_URI
if [ -n "$DATABASE_URL" ]; then
  echo "✅ Found DATABASE_URL, mapping to DATABASE_CONNECTION_URI"
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
else
  echo "⚠️  DATABASE_URL not found"
  if [ -z "$DATABASE_CONNECTION_URI" ]; then
    echo "❌ ERROR: Neither DATABASE_URL nor DATABASE_CONNECTION_URI is set"
    exit 1
  fi
  echo "✅ Using existing DATABASE_CONNECTION_URI"
fi

# Set default DATABASE_PROVIDER if not set
if [ -z "$DATABASE_PROVIDER" ]; then
  echo "✅ Setting default DATABASE_PROVIDER to postgresql"
  export DATABASE_PROVIDER="postgresql"
fi

echo "📊 Database Configuration:"
echo "   Provider: $DATABASE_PROVIDER"
echo "   Connection: ${DATABASE_CONNECTION_URI:0:20}... (truncated for security)"

# Run database migrations
echo "🚀 Running database migrations..."
npm run db:deploy

if [ $? -eq 0 ]; then
  echo "✅ Database migrations completed successfully"
else
  echo "❌ Database migrations failed"
  exit 1
fi
