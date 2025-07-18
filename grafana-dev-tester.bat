@echo off
echo.
echo ========================================
echo    📊 GRAFANA DEVELOPMENT TESTER
echo ========================================
echo.

:menu
echo Choose an action:
echo.
echo 1. 🚀 Start Grafana Only
echo 2. 🔍 Check Grafana Status
echo 3. 🌐 Open Grafana Dashboard
echo 4. 📊 Show Grafana Logs
echo 5. 🧪 Test Grafana Connection
echo 6. 📈 Test Prometheus Integration
echo 7. 🔧 Reset Grafana Data
echo 8. 🛑 Stop Grafana
echo 0. Exit
echo.
set /p choice="Enter your choice (0-8): "

if "%choice%"=="1" goto start_grafana
if "%choice%"=="2" goto check_status
if "%choice%"=="3" goto open_ui
if "%choice%"=="4" goto show_logs
if "%choice%"=="5" goto test_connection
if "%choice%"=="6" goto test_prometheus
if "%choice%"=="7" goto reset_data
if "%choice%"=="8" goto stop_grafana
if "%choice%"=="0" goto exit
goto menu

:start_grafana
echo.
echo 🚀 Starting Grafana Development Server...
echo.
echo Starting dependencies first...
docker-compose -f docker-compose.infrastructure.dev.yml up -d prometheus --remove-orphans
echo.
echo ⏱️  Waiting for Prometheus to be ready (30 seconds)...
timeout /t 30 /nobreak > nul
echo.
echo Starting Grafana...
docker-compose -f docker-compose.infrastructure.dev.yml up -d grafana --remove-orphans
echo.
echo ⏱️  Waiting for Grafana to be ready (60 seconds)...
timeout /t 60 /nobreak > nul
echo.
echo ✅ Grafana should now be ready!
echo.
echo 🌐 Dashboard: http://localhost:3001
echo 👤 Username: admin
echo 🔑 Password: admin123
echo 📈 Prometheus: http://localhost:9090
echo.
pause
goto menu

:check_status
echo.
echo 📊 Grafana Status:
echo.
echo Container Status:
docker ps --filter "name=grafana-dev" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo Health Check:
docker exec grafana-dev curl -s http://localhost:3000/api/health 2>nul || echo ❌ Grafana not running or not accessible
echo.
echo Prometheus Connection:
docker exec grafana-dev curl -s http://prometheus:9090/api/v1/query?query=up 2>nul || echo ❌ Cannot reach Prometheus
echo.
pause
goto menu

:open_ui
echo.
echo 🌐 Opening Grafana Dashboard...
start http://localhost:3001
echo.
echo 📝 Login Details:
echo    Username: admin
echo    Password: admin123
echo.
echo 🎯 Available Features:
echo    - Pre-configured Prometheus datasource
echo    - NestJS application dashboard
echo    - Anonymous access enabled for development
echo    - Debug logging enabled
echo.
pause
goto menu

:show_logs
echo.
echo 📜 Grafana Logs (last 50 lines):
echo.
docker logs --tail=50 grafana-dev 2>nul || echo ❌ Grafana container not found
echo.
pause
goto menu

:test_connection
echo.
echo 🧪 Testing Grafana Connection...
echo.
echo Testing HTTP port (3001)...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3001' -TimeoutSec 5; Write-Host '✅ Grafana port 3001 is accessible' -ForegroundColor Green } catch { Write-Host '❌ Grafana port 3001 is not accessible' -ForegroundColor Red }"

echo.
echo Testing API health endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3001/api/health' -TimeoutSec 5; Write-Host '✅ Grafana API is healthy' -ForegroundColor Green; Write-Host 'Response:' $response.Content } catch { Write-Host '❌ Grafana API is not responding' -ForegroundColor Red }"

echo.
echo Testing login endpoint...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:3001/login' -TimeoutSec 5; Write-Host '✅ Grafana login page is accessible' -ForegroundColor Green } catch { Write-Host '❌ Grafana login page is not accessible' -ForegroundColor Red }"

echo.
pause
goto menu

:test_prometheus
echo.
echo 📈 Testing Prometheus Integration...
echo.
echo Testing Prometheus connection from Grafana...
powershell -Command "try { $cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('admin:admin123')); $headers = @{Authorization='Basic ' + $cred}; $response = Invoke-RestMethod -Uri 'http://localhost:3001/api/datasources' -Headers $headers; $prometheus = $response | Where-Object {$_.type -eq 'prometheus'}; if($prometheus) { Write-Host '✅ Prometheus datasource configured' -ForegroundColor Green; Write-Host 'Datasource Name:' $prometheus.name; Write-Host 'Datasource URL:' $prometheus.url } else { Write-Host '❌ Prometheus datasource not found' -ForegroundColor Red } } catch { Write-Host '❌ Failed to check datasources' -ForegroundColor Red }"

echo.
echo Testing Prometheus API directly...
powershell -Command "try { $response = Invoke-RestMethod -Uri 'http://localhost:9090/api/v1/query?query=up'; Write-Host '✅ Prometheus API is accessible' -ForegroundColor Green; Write-Host 'Active targets:' ($response.data.result | Measure-Object).Count } catch { Write-Host '❌ Prometheus API is not accessible' -ForegroundColor Red }"

echo.
pause
goto menu

:reset_data
echo.
echo 🔧 Reset Grafana Data
echo.
echo ⚠️  WARNING: This will reset all Grafana data including:
echo    - Custom dashboards
echo    - User accounts
echo    - Settings and preferences
echo    - Alert rules
echo.
set /p confirm="Are you sure? Type 'RESET' to confirm: "
if not "%confirm%"=="RESET" (
    echo ❌ Reset cancelled.
    pause
    goto menu
)

echo.
echo Stopping Grafana...
docker-compose -f docker-compose.infrastructure.dev.yml stop grafana
echo.
echo Removing Grafana data volume...
docker volume ls | findstr grafana_dev_data > nul && docker volume rm lesson1_nest_js_grafana_dev_data 2>nul || echo Volume not found
echo.
echo Starting Grafana with fresh data...
docker-compose -f docker-compose.infrastructure.dev.yml up -d grafana
echo.
echo ✅ Grafana data has been reset!
echo ⏱️  Waiting for startup (60 seconds)...
timeout /t 60 /nobreak > nul
echo.
echo 🌐 Grafana: http://localhost:3001 (admin/admin123)
echo.
pause
goto menu

:stop_grafana
echo.
echo 🛑 Stopping Grafana...
docker-compose -f docker-compose.infrastructure.dev.yml stop grafana
echo.
echo ✅ Grafana stopped!
echo.
pause
goto menu

:exit
echo.
echo 👋 Grafana testing complete!
echo.
exit /b 0
