# VoxCivica Full Stack Deployment Guide

Welcome! This folder is fully configured for Railway deployment. Follow these steps to deploy your entire application.

## 📋 What's Included

✅ **Backend** - Python FastAPI with AI integration  
✅ **Frontend** - Flutter web application  
✅ **Database** - Supabase integration  
✅ **CI/CD** - Automated GitHub Actions workflow  
✅ **Docker** - Container configuration for Railway  
✅ **Environment** - Pre-configured templates

## 🚀 Quick Start (3 Steps)

### Step 1: Install Railway CLI

```bash
npm install -g @railway/cli
```

### Step 2: Login & Create Project

```bash
railway login
railway init
```

### Step 3: Deploy Everything

```bash
# Windows
deploy-railway.bat

# Linux/Mac
chmod +x deploy-railway.sh
./deploy-railway.sh
```

## 📁 New Deployment Files Added

```
voxcivica/
├── railway.json                      # Railway service config
├── Dockerfile                        # Full-stack container
├── Dockerfile.railway                # Backend-only container
├── docker-compose.yml                # Local testing
├── deploy-railway.sh                 # Linux/Mac deployment
├── deploy-railway.bat                # Windows deployment
├── DEPLOYMENT.md                     # Full deployment guide
├── GITHUB_SECRETS.md                 # GitHub Actions setup
├── .env.railway                      # Environment template
├── .github/workflows/
│   └── railway-deploy.yml           # Auto-deploy on push
└── [original folders unchanged]
    ├── backend/                      # Python API
    └── voxcivica_app/               # Flutter frontend
```

## 🔧 Configuration

### 1. Set Environment Variables

Railway Dashboard → Project Settings → Variables

Required variables:

- `GEMINI_API_KEY` - Get from Google AI Studio
- `SUPABASE_URL` - Your Supabase project
- `SUPABASE_KEY` - Your Supabase API key

### 2. Setup GitHub Actions (Optional)

For automatic deployment on every push:

1. Go to: https://github.com/Charusm03/VoxCivica/settings/secrets/actions
2. Add `RAILWAY_TOKEN` (from https://railway.app/account/tokens)
3. Push to `main` branch → Auto-deploy! 🎯

## 🧪 Local Testing

### Using Docker Compose

```bash
# Start everything locally
docker-compose up

# Backend: http://localhost:8000
# Frontend: http://localhost:3000
# API Docs: http://localhost:8000/docs
```

### Manual Backend Testing

```bash
cd backend
pip install -r requirements.txt
export GEMINI_API_KEY=your_key
export SUPABASE_URL=your_url
export SUPABASE_KEY=your_key
uvicorn main:app --reload
```

### Manual Frontend Testing

```bash
cd voxcivica_app
flutter pub get
flutter run -d chrome
```

## 📊 Deployment Options

### Option A: Backend Only (Recommended for API-first)

```bash
railway up -d Dockerfile.railway
```

### Option B: Full Stack Monolith

```bash
railway up -d Dockerfile
```

### Option C: Multi-Service (Most Flexible)

```bash
railway up  # Uses railway.json
```

## 🔗 After Deployment

### Access Your App

- **Backend API:** `https://your-app.up.railway.app`
- **API Docs:** `https://your-app.up.railway.app/docs`
- **Frontend:** `https://your-app.up.railway.app/frontend`

### Monitor & Debug

```bash
# View real-time logs
railway logs

# Open Railway dashboard
railway open

# View environment variables
railway variables

# Redeploy if needed
railway up
```

## 🆘 Troubleshooting

| Issue                    | Solution                                       |
| ------------------------ | ---------------------------------------------- |
| "Railway CLI not found"  | Run `npm install -g @railway/cli`              |
| API calls fail           | Check GEMINI_API_KEY and Supabase secrets      |
| 500 errors in logs       | Review logs with `railway logs -t 100`         |
| Frontend can't reach API | Ensure frontend uses correct Railway URL       |
| Deployment stuck         | Check Railway dashboard → view deployment logs |

## 📚 Learn More

- [Railway Documentation](https://docs.railway.app/)
- [Railway Python Guide](https://docs.railway.app/guides/py)
- [Railway Docker Guide](https://docs.railway.app/guides/docker)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Flutter Web Docs](https://flutter.dev/multi-platform/web)

## ✅ Deployment Checklist

- [ ] Railway CLI installed
- [ ] GitHub repository pushed
- [ ] Environment variables set in Railway
- [ ] GitHub secrets configured (for CI/CD)
- [ ] Ran `railway login` and `railway init`
- [ ] Executed `deploy-railway.sh` or `.bat`
- [ ] Checked logs with `railway logs`
- [ ] Verified API is responding

## 🎉 You're Ready!

Everything is configured. Just run the deployment script and your app will be live!

**Next Step:** Review [DEPLOYMENT.md](DEPLOYMENT.md) for detailed information.

---

Need help? Check the [GITHUB_SECRETS.md](GITHUB_SECRETS.md) for CI/CD setup.
