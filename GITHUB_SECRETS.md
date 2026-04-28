# GitHub Secrets Required for Railway Deployment

To enable automatic Railway deployment, add these secrets to your GitHub repository:

## Setup Instructions

1. Go to: https://github.com/Charusm03/VoxCivica/settings/secrets/actions
2. Click "New repository secret"
3. Add the following secrets:

### Required Secrets

#### RAILWAY_TOKEN

- Get from: https://railway.app/account/tokens
- Click "Create Token"
- Copy the full token value
- Name: `RAILWAY_TOKEN`

#### Backend Environment Variables

- `GEMINI_API_KEY` - Your Google Gemini API key
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase API key

## How to Add Secrets

```bash
# Using GitHub CLI
gh secret set RAILWAY_TOKEN --body "your_token_here"
gh secret set GEMINI_API_KEY --body "your_key_here"
gh secret set SUPABASE_URL --body "your_url_here"
gh secret set SUPABASE_KEY --body "your_key_here"
```

Or manually in GitHub:

1. Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret

## Automatic Deployment

Once configured, every push to `main` or `master` branch will automatically:

1. Build the application
2. Deploy to Railway
3. Show deployment status

## Manual Deployment

To manually deploy without pushing:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```
