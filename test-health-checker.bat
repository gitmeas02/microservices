@echo off
REM Docker Service Status Tester
REM This script helps test the health checking functionality

echo.
echo ==========================================
echo   Docker Service Status Tester
echo ==========================================
echo.

echo 🔍 Testing real-time health checking functionality...
echo.

echo 📋 Current Docker container status:
echo.

REM Check if Docker is running
docker version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running or not installed
    echo.
    echo 💡 To test the health checker:
    echo 1. Start Docker Desktop
    echo 2. Run: docker-compose up -d
    echo 3. Open the dashboard: http://localhost
    echo 4. Watch status indicators change in real-time
    echo.
    pause
    exit /b 1
)

echo ✅ Docker is running
echo.

REM List running containers
echo 🐳 Running containers:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | findstr -v "CONTAINER"

echo.
echo 📊 Port status check:
echo.

REM Check key ports
set "PORTS=8080 8081 8082 8083 9001 15672 9090 3001"

for %%p in (%PORTS%) do (
    netstat -an | findstr ":%%p " >nul 2>&1
    if errorlevel 1 (
        echo ❌ Port %%p - Not listening
    ) else (
        echo ✅ Port %%p - Active
    )
)

echo.
echo ==========================================
echo   Testing Instructions
echo ==========================================
echo.

echo 🧪 To test the real-time health checker:
echo.
echo 1. **Start services:**
echo    docker-compose up -d
echo.
echo 2. **Open dashboard:**
echo    http://localhost
echo    ^(Status indicators should be GREEN^)
echo.
echo 3. **Stop a service to test:**
echo    docker-compose stop keycloak
echo    ^(Keycloak indicator should turn RED in ~10 seconds^)
echo.
echo 4. **Restart the service:**
echo    docker-compose start keycloak
echo    ^(Keycloak indicator should turn GREEN again^)
echo.
echo 5. **Stop all services:**
echo    docker-compose down
echo    ^(All indicators should turn RED^)
echo.

echo 💡 **Key Features:**
echo ├─ Real-time status checking every 10 seconds
echo ├─ Manual refresh button in top-right corner
echo ├─ Hover over indicators to see detailed status
echo ├─ Yellow = Checking, Green = Running, Red = Down
echo └─ Console logs show checking activity
echo.

set /p "OPEN_DASHBOARD=Do you want to open the dashboard now? (y/N): "
if /i "!OPEN_DASHBOARD!" equ "y" (
    start http://localhost
    echo.
    echo 🌐 Dashboard opened in browser
    echo 👀 Watch the status indicators change as you start/stop services
)

echo.
echo 🔧 **Troubleshooting:**
echo.
echo If indicators don't change:
echo 1. Check browser console for errors ^(F12^)
echo 2. Ensure Docker containers are actually running
echo 3. Try the manual refresh button
echo 4. Check if ports are accessible: netstat -an ^| findstr ":8080"
echo.

pause
