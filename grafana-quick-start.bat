@echo off
echo.
echo ========================================
echo    🚀 GRAFANA QUICK START GUIDE
echo ========================================
echo.

:menu
echo What would you like to do?
echo.
echo 1. Start Infrastructure + Grafana (First Time)
echo 2. Open Grafana Dashboard
echo 3. Test API Endpoints (Generate Traffic)
echo 4. View Raw Metrics
echo 5. Stop All Services
echo 6. View Logs
echo 0. Exit
echo.
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto start_services
if "%choice%"=="2" goto open_grafana
if "%choice%"=="3" goto test_endpoints
if "%choice%"=="4" goto view_metrics
if "%choice%"=="5" goto stop_services
if "%choice%"=="6" goto view_logs
if "%choice%"=="0" goto exit
goto menu

:start_services
echo.
echo 🔄 Starting Infrastructure Services...
echo.
docker-compose -f docker-compose.infrastructure.lite.yml up -d
echo.
echo ⏱️  Waiting for services to be ready (60 seconds)...
timeout /t 60 /nobreak > nul
echo.
echo 🎯 Services should now be ready!
echo.
echo 📊 Grafana: http://localhost:3001 (admin/admin123)
echo 📈 Prometheus: http://localhost:9090
echo 🔧 MinIO: http://localhost:9001 (minioadmin/minioadmin)
echo 🛡️  Keycloak: http://localhost:8080
echo 🐰 RabbitMQ: http://localhost:15672 (guest/guest)
echo 📦 Nexus: http://localhost:8081 (admin/admin123)
echo.
echo ✅ All services are running!
echo.
pause
goto menu

:open_grafana
echo.
echo 🌐 Opening Grafana Dashboard...
start http://localhost:3001
echo.
echo 📝 Login Details:
echo    Username: admin
echo    Password: admin123
echo.
pause
goto menu

:test_endpoints
echo.
echo 🔥 Testing API Endpoints to Generate Traffic...
echo.
echo Make sure your NestJS app is running first!
echo Press any key to continue or Ctrl+C to cancel...
pause > nul
echo.

curl -s http://localhost:3000/ && echo ✅ Home endpoint OK || echo ❌ Home endpoint failed
curl -s http://localhost:3000/health && echo ✅ Health endpoint OK || echo ❌ Health endpoint failed

echo.
echo Generating some load...
for /l %%i in (1,1,10) do (
    curl -s http://localhost:3000/ > nul
    curl -s http://localhost:3000/health > nul
    echo Request %%i sent...
)
echo.
echo ✅ Traffic generated! Check Grafana dashboard for metrics.
echo.
pause
goto menu

:view_metrics
echo.
echo 📊 Raw Metrics from your NestJS App:
echo.
echo Make sure your NestJS app is running first!
echo.
curl -s http://localhost:3000/metrics || echo ❌ Could not fetch metrics. Is your NestJS app running?
echo.
echo.
pause
goto menu

:stop_services
echo.
echo 🛑 Stopping All Infrastructure Services...
echo.
docker-compose -f docker-compose.infrastructure.lite.yml down
echo.
echo ✅ All services stopped!
echo.
pause
goto menu

:view_logs
echo.
echo 📜 Recent Logs:
echo.
echo Choose service to view logs:
echo 1. Grafana
echo 2. Prometheus  
echo 3. All Services
echo.
set /p log_choice="Enter choice (1-3): "

if "%log_choice%"=="1" docker logs --tail=50 grafana-lite
if "%log_choice%"=="2" docker logs --tail=50 prometheus-lite
if "%log_choice%"=="3" docker-compose -f docker-compose.infrastructure.lite.yml logs --tail=20

echo.
pause
goto menu

:exit
echo.
echo 👋 Thanks for using Grafana Setup! 
echo 📖 Check GRAFANA-SETUP-GUIDE.md for detailed instructions.
echo.
exit /b 0
