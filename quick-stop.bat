@echo off
echo =============================================================================
echo                          STOPPING ALL SERVICES
echo =============================================================================
echo.

echo Stopping all infrastructure services...

docker-compose -f docker-compose.dev.yml down 2>nul
docker-compose -f docker-compose.infrastructure.dev.yml down 2>nul
docker-compose -f docker-compose.infrastructure.lite.yml down 2>nul
docker-compose -f docker-compose.infrastructure.prod.yml down 2>nul
docker-compose -f docker-compose.infrastructure.yml down 2>nul

echo.
echo ✅ All services stopped!
echo.
pause
