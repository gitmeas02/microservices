@echo off
REM KrakenD API Gateway Tester
REM This script tests the KrakenD API Gateway functionality

echo.
echo ==========================================
echo   KrakenD API Gateway Tester
echo ==========================================
echo.

echo 🚪 KrakenD API Gateway Testing Suite
echo.

echo 🌍 Available Environments:
echo ├─ Production/Full: docker-compose.infrastructure.yml
echo └─ Development: docker-compose.infrastructure.dev.yml
echo.

set /p "ENVIRONMENT=Choose environment (p)roduction/(d)evelopment: "

if /i "!ENVIRONMENT!" equ "d" (
    echo.
    echo 🔧 Switching to Development Environment Testing...
    call krakend-dev-tester.bat
    goto :eof
)

echo.
echo 📊 Testing Production/Full Environment...
echo.

echo 🚪 Testing KrakenD API Gateway functionality...
echo.

REM Check if curl is available
curl --version >nul 2>&1
if errorlevel 1 (
    echo ❌ curl is not available. Please install curl to test the API Gateway.
    echo.
    echo 💡 Alternative: Use PowerShell or a web browser to test the endpoints
    echo.
    goto :manual_tests
)

echo ✅ curl is available
echo.

echo 🔍 Testing Gateway Health...
echo.

REM Test 1: Gateway Health Check
echo 📋 Test 1: Gateway Health Check
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost:8000/__health
if errorlevel 1 (
    echo ❌ KrakenD is not responding on port 8000
    echo 💡 Make sure to run: docker-compose -f docker-compose.infrastructure.yml up -d
    echo.
    goto :troubleshooting
) else (
    echo ✅ KrakenD Gateway is healthy
)
echo.

REM Test 2: Application Health through Gateway
echo 📋 Test 2: Application Health through Gateway
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost:8000/api/v1/health
echo.

REM Test 3: Prometheus Metrics
echo 📋 Test 3: Prometheus Metrics Query
curl -s "http://localhost:8000/api/v1/monitoring/metrics/query?query=up" | head -5
echo.

REM Test 4: Gateway Configuration
echo 📋 Test 4: Gateway Configuration (Debug)
curl -s "http://localhost:8000/__debug" | head -10
echo.

REM Test 5: Rate Limiting Test
echo 📋 Test 5: Rate Limiting (5 quick requests)
for /l %%i in (1,1,5) do (
    curl -s -o nul -w "Request %%i - HTTP: %%{http_code}\n" http://localhost:8000/health
)
echo.

echo ==========================================
echo   API Gateway Endpoints
echo ==========================================
echo.

echo 🌐 Available API Endpoints:
echo.
echo 🔍 Health Checks:
echo ├─ Gateway Health: http://localhost:8000/__health
echo ├─ App Health: http://localhost:8000/api/v1/health
echo └─ Gateway Debug: http://localhost:8000/__debug
echo.
echo 🔐 Authentication (Keycloak):
echo ├─ Get Token: POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token
echo └─ User Info: GET http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/userinfo
echo.
echo 📊 Monitoring (Prometheus):
echo ├─ Query Metrics: http://localhost:8000/api/v1/monitoring/metrics/query?query=up
echo └─ Gateway Metrics: http://localhost:8090/metrics
echo.
echo 🐰 Messaging (RabbitMQ):
echo ├─ List Queues: http://localhost:8000/api/v1/messaging/queues
echo └─ Basic Auth: admin:admin123
echo.
echo 📦 Artifacts (Nexus):
echo ├─ Repositories: http://localhost:8000/api/v1/artifacts/repositories
echo └─ Basic Auth: admin:admin123
echo.
echo 📈 Dashboards (Grafana):
echo └─ Search: http://localhost:8000/api/v1/dashboards/search
echo.

goto :demo_commands

:manual_tests
echo ==========================================
echo   Manual Testing Guide
echo ==========================================
echo.
echo 🌐 Open these URLs in your browser:
echo.
echo 1. Gateway Health: http://localhost:8000/__health
echo 2. Gateway Debug: http://localhost:8000/__debug
echo 3. Prometheus Query: http://localhost:8000/api/v1/monitoring/metrics/query?query=up
echo.
echo 💡 Or use PowerShell:
echo.
echo # Test gateway health
echo Invoke-RestMethod -Uri "http://localhost:8000/__health"
echo.
echo # Test metrics query
echo Invoke-RestMethod -Uri "http://localhost:8000/api/v1/monitoring/metrics/query?query=up"
echo.
goto :demo_commands

:troubleshooting
echo ==========================================
echo   Troubleshooting
echo ==========================================
echo.
echo 🔧 Common Issues:
echo.
echo 1. **KrakenD not running:**
echo    docker-compose -f docker-compose.infrastructure.yml up -d krakend
echo.
echo 2. **Check container status:**
echo    docker ps ^| findstr krakend
echo.
echo 3. **View logs:**
echo    docker logs krakend-gateway
echo.
echo 4. **Check port binding:**
echo    netstat -an ^| findstr :8000
echo.
echo 5. **Restart gateway:**
echo    docker-compose -f docker-compose.infrastructure.yml restart krakend
echo.

:demo_commands
echo ==========================================
echo   Demo Commands
echo ==========================================
echo.
echo 🚀 Try these commands to test the API Gateway:
echo.
echo **Windows Command Prompt:**
echo.
echo # Gateway health
echo curl http://localhost:8000/__health
echo.
echo # App health through gateway
echo curl http://localhost:8000/api/v1/health
echo.
echo # Prometheus metrics
echo curl "http://localhost:8000/api/v1/monitoring/metrics/query?query=up"
echo.
echo # Gateway configuration
echo curl http://localhost:8000/__debug
echo.
echo **PowerShell:**
echo.
echo # Gateway health
echo Invoke-RestMethod -Uri "http://localhost:8000/__health"
echo.
echo # Metrics query
echo $response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/monitoring/metrics/query?query=up"
echo $response
echo.
echo **Get Authentication Token:**
echo.
echo curl -X POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token \
echo   -H "Content-Type: application/x-www-form-urlencoded" \
echo   -d "grant_type=password&username=admin&password=admin123&client_id=admin-cli"
echo.

echo ==========================================
echo   Features Included
echo ==========================================
echo.
echo ✅ **KrakenD Features Active:**
echo ├─ ⚡ High-Performance Gateway
echo ├─ 🛡️ Rate Limiting (100 req/sec global, 10 req/sec per IP)
echo ├─ 🔐 JWT Authentication Integration
echo ├─ 📊 Built-in Metrics (Prometheus format)
echo ├─ 🌍 CORS Support
echo ├─ 📝 Request/Response Logging
echo ├─ 🔄 Health Checks
echo ├─ 📋 Debug Endpoints
echo ├─ 🎯 Service Aggregation
echo └─ 🚦 Error Handling
echo.

set /p "OPEN_GATEWAY=Do you want to open the API Gateway in browser? (y/N): "
if /i "!OPEN_GATEWAY!" equ "y" (
    start http://localhost:8000/__debug
    echo.
    echo 🌐 API Gateway debug interface opened
    echo 💡 Try the endpoints listed above to test functionality
)

echo.
echo ✅ KrakenD API Gateway testing completed!
echo 📚 Check infrastructure/krakend/README.md for detailed documentation
pause
