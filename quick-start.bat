@echo off
echo =============================================================================
echo                    QUICK START - ESSENTIAL SERVICES
echo =============================================================================
echo.

echo Starting essential infrastructure services...
echo This includes: Keycloak + RabbitMQ + MinIO + Nexus (Lightweight)
echo.

echo Pulling images...
docker-compose -f docker-compose.infrastructure.lite.yml pull

echo.
echo Starting services...
docker-compose -f docker-compose.infrastructure.lite.yml up -d

if %errorlevel% neq 0 (
    echo ❌ Error starting services!
    echo Try running: docker system prune -f
    pause
    exit /b 1
)

echo.
echo ✅ Services started successfully!
echo.
echo Available services:
echo - Keycloak (Auth):    http://localhost:8080  (admin/dev123)
echo - RabbitMQ (Queue):   http://localhost:15672 (dev/dev123)  
echo - MinIO (Storage):    http://localhost:9001  (devadmin/dev123456)
echo - Nexus (Registry):   http://localhost:8083  (admin/admin123)
echo.
echo Services are starting in the background...
echo Keycloak may take 2-3 minutes to be fully ready
echo Nexus may take 3-5 minutes to be fully ready
echo.
echo To stop all services, run: quick-stop.bat
echo.
pause
