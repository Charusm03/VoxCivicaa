# Railway Deployment Configuration

This folder contains all the configuration needed for Railway deployment of the full VoxCivica stack.

## Files Structure

```
├── backend/                  # Python FastAPI backend
│   ├── main.py             # FastAPI application
│   ├── requirements.txt     # Python dependencies
│   ├── Procfile            # Heroku/Railway process definition
│   └── vercel.json         # Vercel deployment config
├── voxcivica_app/          # Flutter frontend
│   ├── lib/                # Dart source code
│   ├── pubspec.yaml        # Flutter dependencies
│   └── build/web/          # Web build output
├── railway.json            # Railway multi-service config
├── Dockerfile              # Multi-stage container build
├── Dockerfile.railway      # Single-service backend only
├── deploy-railway.sh       # Linux/Mac deployment script
├── deploy-railway.bat      # Windows deployment script
└── DEPLOYMENT.md           # This file
```

## Quick Deployment Steps

### 1. Install Railway CLI

```bash
npm install -g @railway/cli
```

### 2. Login to Railway

```bash
railway login
```

### 3. Set Environment Variables

Before deploying, set these in Railway dashboard or via CLI:

```bash
railway variables set GEMINI_API_KEY=your_key
railway variables set SUPABASE_URL=your_url
railway variables set SUPABASE_KEY=your_key
```

### 4. Deploy (One Command)

**Windows:**

```
deploy-railway.bat
```

**Linux/Mac:**

```bash
chmod +x deploy-railway.sh
./deploy-railway.sh
```

## Backend Service (Python/FastAPI)

- **Root Directory:** `backend/`
- **Language:** Python 3.11
- **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
- **Port:** Auto-assigned by Railway
- **Endpoints:**
  - `/docs` - API documentation
  - `/api/*` - API routes

### Required Environment Variables

- `GEMINI_API_KEY` - Google Gemini API key
- `SUPABASE_URL` - Supabase database URL
- `SUPABASE_KEY` - Supabase API key

## Frontend Service (Flutter Web)

- **Root Directory:** `voxcivica_app/`
- **Build Command:** `flutter build web --release`
- **Output:** Static files in `build/web/`
- **Served:** Via HTTP static file server

### Build Requirements

- Flutter 3.2+
- Dart SDK
- Node.js (for build tools)

## Alternative Deployment Methods

### Option 1: Backend Only (Recommended for Mobile/Web Clients)

Use `Dockerfile.railway` to deploy just the backend:

```bash
railway up -d Dockerfile.railway
```

### Option 2: Full Stack (Monolith)

Use `Dockerfile` for a single container with both:

```bash
railway up -d Dockerfile
```

### Option 3: Multi-Service

Use `railway.json` for separate services:

```bash
railway up
```

## Environment Setup

### Local Testing

```bash
# Backend
cd backend
pip install -r requirements.txt
export GEMINI_API_KEY=your_key
export SUPABASE_URL=your_url
export SUPABASE_KEY=your_key
uvicorn main:app --reload

# Frontend (in another terminal)
cd voxcivica_app
flutter pub get
flutter run -d chrome
```

### Production Variables

- Set via Railway Dashboard → Project Settings → Variables
- Or use CLI: `railway variables set KEY=VALUE`

## Monitoring & Debugging

### View Logs

```bash
railway logs
```

### Open Project

```bash
railway open
```

### Update Deployment

```bash
git push  # Changes auto-trigger rebuild on Railway
```

## Troubleshooting

### Flutter Build Issues

- Ensure pubspec.yaml is valid
- Run locally: `flutter build web --release`
- Check build output in Railway logs

### Backend Connection Issues

- Verify environment variables are set
- Check API key validity
- Review Railway logs: `railway logs`

### CORS Errors

- Frontend likely needs backend URL
- Configure in `lib/api_service.dart`
- Example: `http://your-railway-app.up.railway.app/api`

## Additional Resources

- [Railway Docs](https://docs.railway.app/)
- [Railway Python Guide](https://docs.railway.app/guides/py)
- [Railway Docker Guide](https://docs.railway.app/guides/docker)

---

**Deployment Status:** Ready for Railway ✅
