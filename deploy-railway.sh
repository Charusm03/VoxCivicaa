#!/bin/bash
# Railway Deployment Script

echo "🚀 VoxCivica Full Stack Deployment"
echo "=================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Install it first:"
    echo "   npm install -g @railway/cli"
    exit 1
fi

# Login to Railway
echo "🔐 Logging in to Railway..."
railway login

# Create project
echo "📦 Creating Railway project..."
railway init

# Set environment variables for backend
echo "🔧 Setting environment variables..."
railway variables set GEMINI_API_KEY=$GEMINI_API_KEY
railway variables set SUPABASE_URL=$SUPABASE_URL
railway variables set SUPABASE_KEY=$SUPABASE_KEY

# Deploy
echo "🚀 Deploying to Railway..."
railway up

echo "✅ Deployment complete!"
echo "🌐 Your app is now live on Railway!"
