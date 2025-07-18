@echo off
echo.
echo ========================================
echo    🐰 RABBITMQ DEVELOPMENT TESTER
echo ========================================
echo.

:menu
echo Choose an action:
echo.
echo 1. 🚀 Start RabbitMQ Only
echo 2. 🔍 Check RabbitMQ Status
echo 3. 🌐 Open RabbitMQ Management UI
echo 4. 📊 Show RabbitMQ Logs
echo 5. 🧪 Test RabbitMQ Connection
echo 6. 🛑 Stop RabbitMQ
echo 0. Exit
echo.
set /p choice="Enter your choice (0-6): "

if "%choice%"=="1" goto start_rabbitmq
if "%choice%"=="2" goto check_status
if "%choice%"=="3" goto open_ui
if "%choice%"=="4" goto show_logs
if "%choice%"=="5" goto test_connection
if "%choice%"=="6" goto stop_rabbitmq
if "%choice%"=="0" goto exit
goto menu

:start_rabbitmq
echo.
echo 🚀 Starting RabbitMQ Development Server...
echo.
docker-compose -f docker-compose.infrastructure.dev.yml up -d rabbitmq
echo.
echo ⏱️  Waiting for RabbitMQ to be ready (30 seconds)...
timeout /t 30 /nobreak > nul
echo.
echo ✅ RabbitMQ should now be ready!
echo.
echo 🌐 Management UI: http://localhost:15672
echo 👤 Username: dev
echo 🔑 Password: dev123
echo 🏠 Virtual Host: dev
echo.
pause
goto menu

:check_status
echo.
echo 📊 RabbitMQ Status:
echo.
docker ps --filter "name=rabbitmq-dev" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo 🔍 Health Check:
docker exec rabbitmq-dev rabbitmq-diagnostics status 2>nul || echo ❌ RabbitMQ not running or not accessible
echo.
pause
goto menu

:open_ui
echo.
echo 🌐 Opening RabbitMQ Management UI...
start http://localhost:15672
echo.
echo 📝 Login Details:
echo    Username: dev
echo    Password: dev123
echo    Virtual Host: dev
echo.
pause
goto menu

:show_logs
echo.
echo 📜 RabbitMQ Logs (last 50 lines):
echo.
docker logs --tail=50 rabbitmq-dev 2>nul || echo ❌ RabbitMQ container not found
echo.
pause
goto menu

:test_connection
echo.
echo 🧪 Testing RabbitMQ Connection...
echo.
echo Testing AMQP port (5672)...
powershell -Command "try { $tcp = New-Object System.Net.Sockets.TcpClient; $tcp.Connect('localhost', 5672); $tcp.Close(); Write-Host '✅ AMQP port 5672 is accessible' -ForegroundColor Green } catch { Write-Host '❌ AMQP port 5672 is not accessible' -ForegroundColor Red }"

echo.
echo Testing Management port (15672)...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:15672' -TimeoutSec 5; Write-Host '✅ Management UI port 15672 is accessible' -ForegroundColor Green } catch { Write-Host '❌ Management UI port 15672 is not accessible' -ForegroundColor Red }"

echo.
echo Testing API with credentials...
powershell -Command "try { $cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('dev:dev123')); $headers = @{Authorization='Basic ' + $cred}; $response = Invoke-RestMethod -Uri 'http://localhost:15672/api/overview' -Headers $headers; Write-Host '✅ API authentication successful' -ForegroundColor Green; Write-Host 'RabbitMQ Version:' $response.rabbitmq_version } catch { Write-Host '❌ API authentication failed' -ForegroundColor Red }"

echo.
pause
goto menu

:stop_rabbitmq
echo.
echo 🛑 Stopping RabbitMQ...
docker-compose -f docker-compose.infrastructure.dev.yml stop rabbitmq
echo.
echo ✅ RabbitMQ stopped!
echo.
pause
goto menu

:exit
echo.
echo 👋 RabbitMQ testing complete!
echo.
exit /b 0
