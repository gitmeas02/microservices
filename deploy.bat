@echo off
REM Production deployment script for NestJS application (Windows)

echo 🚀 Starting production deployment...

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker first.
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    exit /b 1
)

REM Check if .env.production exists
if not exist ".env.production" (
    echo [WARNING] .env.production file not found. Please create it with your production environment variables.
)

REM Pull latest images
echo [INFO] Pulling latest Docker images...
docker-compose pull

REM Build the application
echo [INFO] Building the application...
docker-compose build --no-cache

REM Stop existing containers
echo [INFO] Stopping existing containers...
docker-compose down

REM Start the application
echo [INFO] Starting the application...
docker-compose up -d

REM Wait for services to be healthy
echo [INFO] Waiting for services to be healthy...
timeout /t 30 /nobreak >nul

REM Check if services are running
docker-compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo [INFO] ✅ Application deployed successfully!
    echo [INFO] 🌐 Application is available at: http://localhost:3000
    echo [INFO] 🗄️  Database is available at: localhost:5432
    echo [INFO] 🔴 Redis is available at: localhost:6379
    
    echo [INFO] Container status:
    docker-compose ps
    
    echo [INFO] Recent logs:
    docker-compose logs --tail=20
) else (
    echo [ERROR] ❌ Deployment failed. Check the logs:
    docker-compose logs
    exit /b 1
)

echo [INFO] 🎉 Deployment completed successfully!
echo [INFO] 💡 To view logs: docker-compose logs -f
echo [INFO] 💡 To stop the application: docker-compose down

pause
