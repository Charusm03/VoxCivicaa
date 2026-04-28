@echo off
REM Railway Deployment Script for Windows

echo.
echo 🚀 VoxCivica Full Stack Deployment
echo ==================================
echo.

REM Check if Railway CLI is installed
where railway >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Railway CLI not found. Install it first:
    echo    npm install -g @railway/cli
    pause
    exit /b 1
)

REM Login to Railway
echo 🔐 Logging in to Railway...
call railway login

REM Create project
echo 📦 Creating Railway project...
call railway init

REM Set environment variables
echo 🔧 Setting environment variables...
if defined GEMINI_API_KEY (
    call railway variables set GEMINI_API_KEY=%GEMINI_API_KEY%
)
if defined SUPABASE_URL (
    call railway variables set SUPABASE_URL=%SUPABASE_URL%
)
if defined SUPABASE_KEY (
    call railway variables set SUPABASE_KEY=%SUPABASE_KEY%
)

REM Deploy
echo 🚀 Deploying to Railway...
call railway up

echo.
echo ✅ Deployment complete!
echo 🌐 Your app is now live on Railway!
pause
