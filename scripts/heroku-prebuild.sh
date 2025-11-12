#!/bin/bash

# Heroku Pre-build Script
# This script ensures DATABASE_CONNECTION_URI is set from DATABASE_URL

echo "🔧 Setting up environment for Heroku deployment..."

# Map Heroku's DATABASE_URL to Evolution API's DATABASE_CONNECTION_URI
if [ -n "$DATABASE_URL" ] && [ -z "$DATABASE_CONNECTION_URI" ]; then
  echo "✅ Mapping DATABASE_URL to DATABASE_CONNECTION_URI"
  export DATABASE_CONNECTION_URI="$DATABASE_URL"
fi

# Set default DATABASE_PROVIDER if not set
if [ -z "$DATABASE_PROVIDER" ]; then
  echo "✅ Setting default DATABASE_PROVIDER to postgresql"
  export DATABASE_PROVIDER="postgresql"
fi

echo "✅ Environment setup complete"
