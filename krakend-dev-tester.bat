@echo off
REM KrakenD API Gateway Development Tester
REM This script tests the KrakenD API Gateway in development environment

echo.
echo ==========================================
echo   KrakenD Development Environment Tester
echo ==========================================
echo.

echo 🚪 Testing KrakenD API Gateway in Development Mode...
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

echo 🔍 Testing Development Gateway Health...
echo.

REM Test 1: Gateway Health Check
echo 📋 Test 1: Development Gateway Health Check
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost:8000/__health
if errorlevel 1 (
    echo ❌ KrakenD Development Gateway is not responding on port 8000
    echo 💡 Make sure to run: docker-compose -f docker-compose.infrastructure.dev.yml up -d
    echo.
    goto :troubleshooting
) else (
    echo ✅ KrakenD Development Gateway is healthy
)
echo.

REM Test 2: Development Status Endpoint
echo 📋 Test 2: Development Status Endpoint
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost:8000/api/v1/dev/status
echo.

REM Test 3: Application Health through Gateway
echo 📋 Test 3: Application Health through Gateway
curl -s -o nul -w "HTTP Status: %%{http_code}\n" http://localhost:8000/api/v1/health
echo.

REM Test 4: Prometheus Metrics (Development)
echo 📋 Test 4: Prometheus Metrics Query (Development)
curl -s "http://localhost:8000/api/v1/monitoring/metrics/query?query=up" | head -5
echo.

REM Test 5: Gateway Configuration (Debug Mode)
echo 📋 Test 5: Gateway Configuration (Debug Mode)
curl -s "http://localhost:8000/__debug" | head -10
echo.

REM Test 6: Echo endpoint for testing
echo 📋 Test 6: Echo Endpoint Test
curl -s -X POST "http://localhost:8000/__echo" -H "Content-Type: application/json" -d "{\"test\":\"development\"}" | head -5
echo.

REM Test 7: Rate Limiting Test (Development - Higher Limits)
echo 📋 Test 7: Rate Limiting (10 quick requests - Development)
for /l %%i in (1,1,10) do (
    curl -s -o nul -w "Request %%i - HTTP: %%{http_code}\n" http://localhost:8000/health
)
echo.

echo ==========================================
echo   Development API Gateway Endpoints
echo ==========================================
echo.

echo 🌐 Available Development API Endpoints:
echo.
echo 🔍 Health ^& Debug:
echo ├─ Gateway Health: http://localhost:8000/__health
echo ├─ Development Status: http://localhost:8000/api/v1/dev/status
echo ├─ App Health: http://localhost:8000/api/v1/health
echo ├─ Gateway Debug: http://localhost:8000/__debug
echo ├─ Echo Test: http://localhost:8000/__echo
echo └─ Gateway Config: http://localhost:8000/api/v1/gateway/config
echo.
echo 🔐 Authentication (Keycloak Dev):
echo ├─ Get Token: POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token
echo ├─ User Info: GET http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/userinfo
echo └─ Dev Credentials: admin / dev123
echo.
echo 📊 Monitoring (Prometheus Dev):
echo ├─ Query Metrics: http://localhost:8000/api/v1/monitoring/metrics/query?query=up
echo ├─ Query Range: http://localhost:8000/api/v1/monitoring/metrics/query_range
echo └─ Gateway Metrics: http://localhost:8090/metrics
echo.
echo 🐰 Messaging (RabbitMQ Dev):
echo ├─ List Queues: http://localhost:8000/api/v1/messaging/queues
echo ├─ List Exchanges: http://localhost:8000/api/v1/messaging/exchanges
echo └─ Dev Auth: dev:dev123
echo.
echo 📦 Artifacts (Nexus Dev):
echo ├─ Repositories: http://localhost:8000/api/v1/artifacts/repositories
echo ├─ Components: http://localhost:8000/api/v1/artifacts/components
echo └─ Dev Auth: admin:admin123
echo.
echo 📈 Dashboards (Grafana Dev):
echo ├─ Search: http://localhost:8000/api/v1/dashboards/search
echo └─ Get Dashboard: http://localhost:8000/api/v1/dashboards/{uid}
echo.
echo 🔧 Git ^& CI (Development):
echo ├─ Git Projects: http://localhost:8000/api/v1/git/projects
echo ├─ Jenkins Jobs: http://localhost:8000/api/v1/ci/jobs
echo └─ Storage Health: http://localhost:8000/api/v1/storage/health
echo.

goto :demo_commands

:manual_tests
echo ==========================================
echo   Manual Development Testing Guide
echo ==========================================
echo.
echo 🌐 Open these URLs in your browser:
echo.
echo 1. Gateway Health: http://localhost:8000/__health
echo 2. Gateway Debug: http://localhost:8000/__debug
echo 3. Development Status: http://localhost:8000/api/v1/dev/status
echo 4. Echo Test: http://localhost:8000/__echo
echo 5. Prometheus Query: http://localhost:8000/api/v1/monitoring/metrics/query?query=up
echo.
echo 💡 Or use PowerShell:
echo.
echo # Test gateway health
echo Invoke-RestMethod -Uri "http://localhost:8000/__health"
echo.
echo # Test development status
echo Invoke-RestMethod -Uri "http://localhost:8000/api/v1/dev/status"
echo.
echo # Test echo endpoint
echo Invoke-RestMethod -Uri "http://localhost:8000/__echo" -Method Post -Body '{"test":"dev"}' -ContentType "application/json"
echo.
goto :demo_commands

:troubleshooting
echo ==========================================
echo   Development Troubleshooting
echo ==========================================
echo.
echo 🔧 Common Development Issues:
echo.
echo 1. **KrakenD Dev not running:**
echo    docker-compose -f docker-compose.infrastructure.dev.yml up -d krakend
echo.
echo 2. **Check development container status:**
echo    docker ps ^| findstr krakend-dev
echo.
echo 3. **View development logs:**
echo    docker logs krakend-dev
echo.
echo 4. **Check port binding:**
echo    netstat -an ^| findstr :8000
echo.
echo 5. **Restart development gateway:**
echo    docker-compose -f docker-compose.infrastructure.dev.yml restart krakend
echo.
echo 6. **Check development configuration:**
echo    docker exec krakend-dev cat /etc/krakend/krakend.json
echo.
echo 7. **View all development services:**
echo    docker-compose -f docker-compose.infrastructure.dev.yml ps
echo.

:demo_commands
echo ==========================================
echo   Development Demo Commands
echo ==========================================
echo.
echo 🚀 Try these commands to test the Development API Gateway:
echo.
echo **Windows Command Prompt:**
echo.
echo # Gateway health
echo curl http://localhost:8000/__health
echo.
echo # Development status
echo curl http://localhost:8000/api/v1/dev/status
echo.
echo # App health through gateway
echo curl http://localhost:8000/api/v1/health
echo.
echo # Echo test with JSON
echo curl -X POST http://localhost:8000/__echo -H "Content-Type: application/json" -d "{\"env\":\"development\",\"test\":true}"
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
echo # Development status
echo Invoke-RestMethod -Uri "http://localhost:8000/api/v1/dev/status"
echo.
echo # Echo test
echo $body = @{env="development"; test=$true} ^| ConvertTo-Json
echo Invoke-RestMethod -Uri "http://localhost:8000/__echo" -Method Post -Body $body -ContentType "application/json"
echo.
echo # Metrics query
echo $response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/monitoring/metrics/query?query=up"
echo $response
echo.
echo **Get Development Authentication Token:**
echo.
echo curl -X POST http://localhost:8000/api/v1/auth/realms/master/protocol/openid_connect/token \
echo   -H "Content-Type: application/x-www-form-urlencoded" \
echo   -d "grant_type=password&username=admin&password=dev123&client_id=admin-cli"
echo.

echo ==========================================
echo   Development Features Active
echo ==========================================
echo.
echo ✅ **KrakenD Development Features:**
echo ├─ ⚡ High-Performance Gateway
echo ├─ 🛡️ Rate Limiting (1000 req/sec global, 100 req/sec per IP)
echo ├─ 🔐 JWT Authentication Integration
echo ├─ 📊 Built-in Metrics (Prometheus format)
echo ├─ 🌍 CORS Support (Permissive for Development)
echo ├─ 📝 Debug Logging (Level: DEBUG)
echo ├─ 🔄 Health Checks
echo ├─ 📋 Debug Endpoints
echo ├─ 🎯 Service Aggregation
echo ├─ 🚦 Error Handling
echo ├─ 🔍 Echo Endpoint for Testing
echo ├─ 📊 Development Status Endpoint
echo └─ 🛠️ Enhanced Development Debugging
echo.

echo 🌐 **Domain Access (add to hosts file):**
echo 127.0.0.1 api.local api-dev.local
echo.

echo 📊 **Development Rate Limits:**
echo ├─ Health Endpoints: 1000 req/sec
echo ├─ Auth Endpoints: 500 req/sec
echo ├─ Monitoring: 1000 req/sec
echo ├─ Messaging: 200 req/sec
echo ├─ Artifacts: 200 req/sec
echo └─ Dashboards: 200 req/sec
echo.

set /p "OPEN_GATEWAY=Do you want to open the Development API Gateway in browser? (y/N): "
if /i "!OPEN_GATEWAY!" equ "y" (
    start http://localhost:8000/__debug
    echo.
    echo 🌐 Development API Gateway debug interface opened
    echo 💡 Try the development endpoints listed above
)

set /p "START_DEV=Do you want to start the development infrastructure? (y/N): "
if /i "!START_DEV!" equ "y" (
    echo.
    echo 🚀 Starting development infrastructure...
    docker-compose -f docker-compose.infrastructure.dev.yml up -d
    echo.
    echo ✅ Development infrastructure started!
    echo 💡 Wait a few moments for all services to be ready
)

echo.
echo ✅ KrakenD Development Gateway testing completed!
echo 📚 Check infrastructure/krakend/README.md for detailed documentation
echo 🔧 Use docker-compose.infrastructure.dev.yml for development environment
pause
