@echo off
REM DevOps Infrastructure Deployment Manager
REM Automated deployment script for different environments

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   DevOps Infrastructure Deployment
echo ==========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ Docker is not running or not installed
    echo Please start Docker Desktop or install Docker
    pause
    exit /b 1
)

echo ✅ Docker is running

:menu
echo.
echo ==========================================
echo  Deployment Options
echo ==========================================
echo.
echo 1. 🏠 Local Development (with Nginx)
echo 2. 🔧 Local Development (Direct ports)
echo 3. ☁️  Production Deployment
echo 4. 📊 Resource Monitoring
echo 5. 🔐 Generate SSL Certificates
echo 6. 🧹 Cleanup Services
echo 7. 📋 View Service Status
echo 8. 📖 Open Hosting Guide
echo 9. ❌ Exit
echo.

set /p "choice=Enter your choice (1-9): "

if "%choice%"=="1" goto local_nginx
if "%choice%"=="2" goto local_direct
if "%choice%"=="3" goto production
if "%choice%"=="4" goto monitoring
if "%choice%"=="5" goto ssl_setup
if "%choice%"=="6" goto cleanup
if "%choice%"=="7" goto status
if "%choice%"=="8" goto guide
if "%choice%"=="9" goto exit

echo Invalid choice. Please try again.
goto menu

:local_nginx
echo.
echo 🏠 Starting Local Development Environment with Nginx Proxy...
echo.

REM Check if SSL certificates exist
if not exist "infrastructure\nginx\ssl\dev-cert.pem" (
    echo ⚠️  SSL certificates not found. Generating them first...
    echo.
    echo Checking for OpenSSL...
    where openssl >nul 2>&1
    if !errorlevel! neq 0 (
        echo ℹ️  OpenSSL not found, using Docker-based certificate generation...
        call infrastructure\nginx\generate-ssl-simple.bat
    ) else (
        echo ✅ OpenSSL found, using native certificate generation...
        call infrastructure\nginx\generate-ssl.bat
    )
)

echo 🚀 Starting services...
docker-compose -f docker-compose.infrastructure.dev.yml up -d --remove-orphans

if !errorlevel! equ 0 (
    echo.
    echo ✅ Services started successfully!
    echo.
    echo 🌐 Access URLs:
    echo ├─ Main Dashboard: http://localhost
    echo ├─ HTTPS Dashboard: https://localhost
    echo ├─ Management: http://localhost:8090
    echo ├─ Keycloak: http://auth.local ^(add to hosts file^)
    echo ├─ GitLab: http://git.local
    echo ├─ Jenkins: http://ci.local  
    echo ├─ Grafana: http://grafana.local
    echo └─ All services available via reverse proxy
    echo.
    echo 💡 Run this script again and choose option 7 to check status
) else (
    echo ❌ Failed to start services
)

pause
goto menu

:local_direct
echo.
echo 🔧 Starting Local Development Environment (Direct Ports)...
echo.

REM Use lightweight version without nginx
docker-compose -f docker-compose.infrastructure.lightweight.yml up -d --remove-orphans

if !errorlevel! equ 0 (
    echo.
    echo ✅ Services started successfully!
    echo.
    echo 🌐 Direct Access URLs:
    echo ├─ Keycloak: http://localhost:8080
    echo ├─ GitLab: http://localhost:8082
    echo ├─ Jenkins: http://localhost:8081
    echo ├─ Nexus: http://localhost:8083
    echo ├─ MinIO Console: http://localhost:9001
    echo ├─ RabbitMQ: http://localhost:15672
    echo ├─ Prometheus: http://localhost:9090
    echo └─ Grafana: http://localhost:3001
) else (
    echo ❌ Failed to start services
)

pause
goto menu

:production
echo.
echo ☁️  Production Deployment Setup...
echo.

if not exist "docker-compose.production.yml" (
    echo 📝 Creating production configuration...
    echo Please edit the production configuration file before deployment.
    echo.
    echo Key changes needed:
    echo 1. Update domain names in nginx configuration
    echo 2. Set production environment variables
    echo 3. Configure SSL certificates
    echo 4. Set resource limits
    echo.
    pause
    goto menu
)

echo ⚠️  WARNING: This will deploy to production environment
set /p "confirm=Are you sure you want to continue? (yes/no): "

if /i "!confirm!" neq "yes" (
    echo Deployment cancelled
    goto menu
)

docker-compose -f docker-compose.production.yml up -d --remove-orphans

if !errorlevel! equ 0 (
    echo ✅ Production deployment started!
    echo.
    echo 🔍 Monitor deployment with:
    echo docker-compose -f docker-compose.production.yml logs -f
) else (
    echo ❌ Production deployment failed
)

pause
goto menu

:monitoring
echo.
echo 📊 Opening Resource Monitor...
echo.

if exist "resource-monitor.bat" (
    start resource-monitor.bat
) else (
    echo ❌ Resource monitor not found
    echo Please ensure resource-monitor.bat is in the current directory
)

goto menu

:ssl_setup
echo.
echo 🔐 SSL Certificate Setup...
echo.

echo Checking for OpenSSL...
where openssl >nul 2>&1
if !errorlevel! neq 0 (
    echo ℹ️  OpenSSL not found, using Docker-based certificate generation...
    if exist "infrastructure\nginx\generate-ssl-simple.bat" (
        call infrastructure\nginx\generate-ssl-simple.bat
    ) else (
        echo ❌ Docker SSL generation script not found
        echo Please ensure infrastructure\nginx\generate-ssl-simple.bat exists
    )
) else (
    echo ✅ OpenSSL found, using native certificate generation...
    if exist "infrastructure\nginx\generate-ssl.bat" (
        call infrastructure\nginx\generate-ssl.bat
    ) else (
        echo ❌ SSL generation script not found
        echo Please ensure infrastructure\nginx\generate-ssl.bat exists
    )
)

pause
goto menu

:cleanup
echo.
echo 🧹 Cleanup Options...
echo.
echo 1. Stop all services (keep data)
echo 2. Remove all services and networks (keep data)
echo 3. Complete cleanup (REMOVES ALL DATA)
echo 4. Clean up unused Docker resources
echo 5. Back to main menu
echo.

set /p "cleanup_choice=Enter cleanup option (1-5): "

if "%cleanup_choice%"=="1" (
    echo Stopping all services...
    docker-compose -f docker-compose.infrastructure.dev.yml stop
    docker-compose -f docker-compose.infrastructure.lightweight.yml stop 2>nul
    docker-compose -f docker-compose.production.yml stop 2>nul
    echo ✅ All services stopped
)

if "%cleanup_choice%"=="2" (
    echo Removing services and networks...
    docker-compose -f docker-compose.infrastructure.dev.yml down --remove-orphans
    docker-compose -f docker-compose.infrastructure.lightweight.yml down --remove-orphans 2>nul
    docker-compose -f docker-compose.production.yml down --remove-orphans 2>nul
    echo ✅ Services and networks removed
)

if "%cleanup_choice%"=="3" (
    echo.
    echo ⚠️  WARNING: This will permanently delete ALL data!
    set /p "confirm_delete=Type 'DELETE' to confirm: "
    if /i "!confirm_delete!"=="DELETE" (
        echo Performing complete cleanup...
        docker-compose -f docker-compose.infrastructure.dev.yml down -v --remove-orphans
        docker-compose -f docker-compose.infrastructure.lightweight.yml down -v --remove-orphans 2>nul
        docker-compose -f docker-compose.production.yml down -v --remove-orphans 2>nul
        echo ✅ Complete cleanup performed
    ) else (
        echo Cleanup cancelled
    )
)

if "%cleanup_choice%"=="4" (
    echo Cleaning up unused Docker resources...
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    echo ✅ Unused resources cleaned
)

if "%cleanup_choice%"=="5" goto menu

pause
goto menu

:status
echo.
echo 📋 Service Status...
echo.

echo ==========================================
echo  Docker Services Status
echo ==========================================
docker-compose -f docker-compose.infrastructure.dev.yml ps 2>nul

echo.
echo ==========================================
echo  Resource Usage
echo ==========================================
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo.
echo ==========================================
echo  Network Information
echo ==========================================
docker network ls | findstr devops

echo.
echo ==========================================
echo  Volume Information  
echo ==========================================
docker volume ls | findstr devops

pause
goto menu

:guide
echo.
echo 📖 Opening Hosting Guide...
echo.

if exist "infrastructure\HOSTING_GUIDE.md" (
    start notepad "infrastructure\HOSTING_GUIDE.md"
) else (
    echo ❌ Hosting guide not found
    echo Please ensure infrastructure\HOSTING_GUIDE.md exists
)

goto menu

:exit
echo.
echo 👋 Thank you for using DevOps Infrastructure Deployment!
echo.
echo 💡 Quick Reference:
echo ├─ Local Development: http://localhost
echo ├─ Resource Monitor: resource-monitor.bat  
echo ├─ Grafana Testing: grafana-dev-tester.bat
echo └─ Hosting Guide: infrastructure\HOSTING_GUIDE.md
echo.
echo 🔗 Support: Check the documentation for troubleshooting
echo.
pause
exit /b 0
