@echo off
echo.
echo ========================================
echo   🚀 PRODUCTION SETUP: Infrastructure + App
echo ========================================
echo.

:menu
echo Choose your setup:
echo.
echo 1. 🏗️  Start Infrastructure ONLY (Lite)
echo 2. 🚀 Start Application ONLY (Production)
echo 3. 🔥 Start BOTH (Infrastructure + Application)
echo 4. 🛑 Stop All Services
echo 5. 📊 View Service Status
echo 6. 📜 View Logs
echo 0. Exit
echo.
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto start_infrastructure
if "%choice%"=="2" goto start_app
if "%choice%"=="3" goto start_both
if "%choice%"=="4" goto stop_all
if "%choice%"=="5" goto show_status
if "%choice%"=="6" goto show_logs
if "%choice%"=="0" goto exit
goto menu

:start_infrastructure
echo.
echo 🏗️ Starting Infrastructure Services (Lite)...
echo.
docker-compose -f docker-compose.infrastructure.lite.yml up -d
echo.
echo ✅ Infrastructure started!
echo.
echo 📊 Available Services:
echo    - Keycloak: http://localhost:8080 (admin/dev123)
echo    - RabbitMQ: http://localhost:15672 (dev/dev123)
echo    - MinIO: http://localhost:9001 (devadmin/dev123456)
echo    - Nexus: http://localhost:8083 (admin/admin123)
echo    - Grafana: http://localhost:3001 (admin/admin123)
echo    - Prometheus: http://localhost:9090
echo    - Keycloak DB: localhost:5433
echo.
pause
goto menu

:start_app
echo.
echo 🚀 Starting Application Services (Production)...
echo.
docker-compose -f docker-compose.prod.yml up -d
echo.
echo ✅ Application started!
echo.
echo 🌐 Available Services:
echo    - NestJS App: http://localhost:3000
echo    - PostgreSQL: localhost:5434
echo    - Redis: localhost:6380
echo    - Nginx: http://localhost:80
echo.
pause
goto menu

:start_both
echo.
echo 🔥 Starting BOTH Infrastructure + Application...
echo.
echo Step 1/2: Starting Infrastructure (Lite)...
docker-compose -f docker-compose.infrastructure.lite.yml up -d

echo.
echo ⏱️  Waiting for infrastructure to be ready (30 seconds)...
timeout /t 30 /nobreak > nul

echo.
echo Step 2/2: Starting Application (Production)...
docker-compose -f docker-compose.prod.yml up -d

echo.
echo ✅ Both Infrastructure and Application are running!
echo.
echo 📊 INFRASTRUCTURE SERVICES:
echo    - Keycloak: http://localhost:8080 (admin/dev123)
echo    - RabbitMQ: http://localhost:15672 (dev/dev123)
echo    - MinIO: http://localhost:9001 (devadmin/dev123456)
echo    - Nexus: http://localhost:8083 (admin/admin123)
echo    - Grafana: http://localhost:3001 (admin/admin123)
echo    - Prometheus: http://localhost:9090
echo.
echo 🚀 APPLICATION SERVICES:
echo    - NestJS App: http://localhost:3000
echo    - PostgreSQL: localhost:5434
echo    - Redis: localhost:6380
echo    - Nginx: http://localhost:80
echo.
echo 🎯 DATABASES:
echo    - Keycloak DB: localhost:5433
echo    - App DB: localhost:5434
echo.
pause
goto menu

:stop_all
echo.
echo 🛑 Stopping all services...
echo.
echo Stopping Application...
docker-compose -f docker-compose.prod.yml down
echo.
echo Stopping Infrastructure...
docker-compose -f docker-compose.infrastructure.lite.yml down
echo.
echo ✅ All services stopped!
echo.
pause
goto menu

:show_status
echo.
echo 📊 Service Status:
echo.
echo === INFRASTRUCTURE SERVICES ===
docker-compose -f docker-compose.infrastructure.lite.yml ps
echo.
echo === APPLICATION SERVICES ===
docker-compose -f docker-compose.prod.yml ps
echo.
pause
goto menu

:show_logs
echo.
echo 📜 Choose logs to view:
echo 1. Infrastructure logs
echo 2. Application logs
echo 3. Specific service logs
echo.
set /p log_choice="Enter choice (1-3): "

if "%log_choice%"=="1" (
    echo.
    echo === INFRASTRUCTURE LOGS ===
    docker-compose -f docker-compose.infrastructure.lite.yml logs --tail=20
)
if "%log_choice%"=="2" (
    echo.
    echo === APPLICATION LOGS ===
    docker-compose -f docker-compose.prod.yml logs --tail=20
)
if "%log_choice%"=="3" (
    echo.
    echo Enter service name (e.g., keycloak-dev, nestjs-lesson1-app-prod, postgres):
    set /p service_name="Service name: "
    docker logs --tail=50 %service_name%
)
echo.
pause
goto menu

:exit
echo.
echo 👋 Production setup complete!
echo.
echo 📝 PORT SUMMARY:
echo    Infrastructure: 8080, 15672, 9001, 8083, 3001, 9090, 5433
echo    Application: 3000, 80, 5434, 6380
echo.
echo 📖 Check the documentation for more details.
echo.
exit /b 0
