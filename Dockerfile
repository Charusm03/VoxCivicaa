# Multi-stage build for full stack deployment

# Stage 1: Build Backend
FROM python:3.11-slim AS backend-builder
WORKDIR /app/backend
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Build Frontend
FROM cirrusci/flutter:latest AS frontend-builder
WORKDIR /app/frontend
COPY voxcivica_app . 
RUN flutter pub get
RUN flutter build web --release

# Stage 3: Final deployment image
FROM python:3.11-slim
WORKDIR /app

# Install nginx for serving frontend and backend
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy backend dependencies
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy backend code
COPY backend /app/backend
WORKDIR /app/backend

# Copy frontend build
COPY --from=frontend-builder /app/frontend/build/web /var/www/html

# Configure nginx
RUN echo 'server { listen 80; root /var/www/html; index index.html; location / { try_files $uri /index.html; } location /api { proxy_pass http://localhost:8000; } }' > /etc/nginx/sites-available/default

# Expose ports
EXPOSE 80 8000

# Start both services
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 & nginx -g 'daemon off;'"]
