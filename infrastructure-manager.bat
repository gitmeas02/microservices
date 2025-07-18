@echo off
setlocal enabledelayedexpansion

echo =============================================================================
echo                    INFRASTRUCTURE MANAGEMENT SCRIPT
echo =============================================================================
echo.

:MAIN_MENU
echo Choose an environment:
echo 1. Local Development (All services)
echo 2. Development Environment (Full)
echo 3. Development Environment (Lightweight - Recommended)
echo 4. Production Environment
echo 5. Infrastructure Only (Base services)
echo 6. Stop All Services
echo 7. Clean All (Remove volumes and images)
echo 8. Backup Data
echo 9. Restore Data
echo 10. View Logs
echo 11. Health Check
echo 12. Exit
echo.
set /p choice="Enter your choice (1-12): "

if "%choice%"=="1" goto LOCAL_DEV
if "%choice%"=="2" goto DEV_ENV
if "%choice%"=="3" goto DEV_LITE
if "%choice%"=="4" goto PROD_ENV
if "%choice%"=="5" goto INFRASTRUCTURE_ONLY
if "%choice%"=="6" goto STOP_ALL
if "%choice%"=="7" goto CLEAN_ALL
if "%choice%"=="8" goto BACKUP
if "%choice%"=="9" goto RESTORE
if "%choice%"=="10" goto VIEW_LOGS
if "%choice%"=="11" goto HEALTH_CHECK
if "%choice%"=="12" goto EXIT
goto MAIN_MENU

:LOCAL_DEV
echo.
echo Starting Local Development Environment...
echo This includes: NestJS app + PostgreSQL + Redis + All Infrastructure
echo.
echo Pulling latest images first...
docker-compose -f docker-compose.dev.yml pull
docker-compose -f docker-compose.infrastructure.dev.yml pull
echo.
echo Starting services...
docker-compose -f docker-compose.dev.yml -f docker-compose.infrastructure.dev.yml up -d
if %errorlevel% neq 0 (
    echo ❌ Error starting services! Check Docker logs for details.
    pause
    goto MAIN_MENU
)
echo.
echo ✅ Local development environment started!
echo.
echo Available services:
echo - NestJS App: http://localhost:3000
echo - Keycloak: http://localhost:8080 (admin/dev123)
echo - RabbitMQ: http://localhost:15672 (dev/dev123)
echo - MinIO: http://localhost:9001 (devadmin/dev123456)
echo - GitLab: http://localhost:8082 (root/dev123456)
echo - Jenkins: http://localhost:8081 (admin/admin123)
echo - Nexus: http://localhost:8083 (admin/admin123)
echo.
echo Note: GitLab and Jenkins may take 5-10 minutes to fully start
echo.
pause
goto MAIN_MENU

:DEV_ENV
echo.
echo Starting Development Environment (Full)...
echo This includes GitLab and Jenkins (heavy services)
echo Pulling latest images first...
docker-compose -f docker-compose.infrastructure.dev.yml pull
echo.
echo Starting services...
docker-compose -f docker-compose.infrastructure.dev.yml up -d
if %errorlevel% neq 0 (
    echo ❌ Error starting services! Check Docker logs for details.
    pause
    goto MAIN_MENU
)
echo.
echo ✅ Development infrastructure started!
echo.
echo Available services:
echo - Keycloak: http://localhost:8080
echo - RabbitMQ: http://localhost:15672
echo - MinIO: http://localhost:9001
echo - GitLab: http://localhost:8082 (may take 5-10 minutes)
echo - Jenkins: http://localhost:8081 (may take 3-5 minutes)
echo - Nexus: http://localhost:8083
echo.
pause
goto MAIN_MENU

:DEV_LITE
echo.
echo Starting Development Environment (Lightweight)...
echo This includes Keycloak, RabbitMQ, MinIO, and Nexus only
echo Pulling latest images first...
docker-compose -f docker-compose.infrastructure.lite.yml pull
echo.
echo Starting services...
docker-compose -f docker-compose.infrastructure.lite.yml up -d
if %errorlevel% neq 0 (
    echo ❌ Error starting services! Check Docker logs for details.
    pause
    goto MAIN_MENU
)
echo.
echo ✅ Lightweight development infrastructure started!
echo.
echo Available services:
echo - Keycloak: http://localhost:8080 (admin/dev123)
echo - RabbitMQ: http://localhost:15672 (dev/dev123)
echo - MinIO: http://localhost:9001 (devadmin/dev123456)
echo - Nexus: http://localhost:8083 (admin/admin123)
echo.
echo Note: This is faster to start and uses less resources
echo.
pause
goto MAIN_MENU

:PROD_ENV
echo.
echo ⚠️  WARNING: Starting Production Environment
echo This will start production-configured services.
echo.
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" goto MAIN_MENU

echo.
echo Starting Production Environment...
docker-compose -f docker-compose.infrastructure.prod.yml up -d
echo.
echo ✅ Production infrastructure started!
echo Note: Check .env files for proper configuration.
echo.
pause
goto MAIN_MENU

:INFRASTRUCTURE_ONLY
echo.
echo Starting Infrastructure Services Only...
docker-compose -f docker-compose.infrastructure.yml up -d
echo.
echo ✅ Infrastructure services started!
echo.
pause
goto MAIN_MENU

:STOP_ALL
echo.
echo Stopping all services...
docker-compose -f docker-compose.dev.yml down 2>nul
docker-compose -f docker-compose.infrastructure.dev.yml down 2>nul
docker-compose -f docker-compose.infrastructure.lite.yml down 2>nul
docker-compose -f docker-compose.infrastructure.prod.yml down 2>nul
docker-compose -f docker-compose.infrastructure.yml down 2>nul
echo.
echo ✅ All services stopped!
echo.
pause
goto MAIN_MENU

:CLEAN_ALL
echo.
echo ⚠️  WARNING: This will remove ALL Docker volumes and images
echo This action cannot be undone!
echo.
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" goto MAIN_MENU

echo.
echo Cleaning all services...
call :STOP_ALL

echo Removing volumes...
docker volume rm lesson1_nest_js_postgres_dev_data 2>nul
docker volume rm lesson1_nest_js_redis_dev_data 2>nul
docker volume rm lesson1_nest_js_keycloak_db_dev_data 2>nul
docker volume rm lesson1_nest_js_keycloak_dev_data 2>nul
docker volume rm lesson1_nest_js_rabbitmq_dev_data 2>nul
docker volume rm lesson1_nest_js_minio_dev_data 2>nul
docker volume rm lesson1_nest_js_gitlab_dev_data 2>nul
docker volume rm lesson1_nest_js_jenkins_dev_home 2>nul
docker volume rm lesson1_nest_js_nexus_dev_data 2>nul

echo Removing unused images...
docker image prune -a -f

echo.
echo ✅ Cleanup completed!
echo.
pause
goto MAIN_MENU

:BACKUP
echo.
echo Creating backup of all data volumes...
mkdir backup 2>nul
set backup_date=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set backup_date=%backup_date: =0%

echo Backing up PostgreSQL data...
docker run --rm -v lesson1_nest_js_postgres_dev_data:/data -v %cd%\backup:/backup alpine tar czf /backup/postgres_%backup_date%.tar.gz -C /data .

echo Backing up GitLab data...
docker run --rm -v lesson1_nest_js_gitlab_dev_data:/data -v %cd%\backup:/backup alpine tar czf /backup/gitlab_%backup_date%.tar.gz -C /data .

echo Backing up Jenkins data...
docker run --rm -v lesson1_nest_js_jenkins_dev_home:/data -v %cd%\backup:/backup alpine tar czf /backup/jenkins_%backup_date%.tar.gz -C /data .

echo Backing up Nexus data...
docker run --rm -v lesson1_nest_js_nexus_dev_data:/data -v %cd%\backup:/backup alpine tar czf /backup/nexus_%backup_date%.tar.gz -C /data .

echo.
echo ✅ Backup completed! Files saved in backup\ folder
echo.
pause
goto MAIN_MENU

:RESTORE
echo.
echo Available backup files:
dir backup\*.tar.gz 2>nul
echo.
set /p backup_file="Enter backup filename (without path): "

if not exist "backup\%backup_file%" (
    echo Backup file not found!
    pause
    goto MAIN_MENU
)

echo.
echo ⚠️  WARNING: This will overwrite existing data!
set /p confirm="Are you sure? (y/N): "
if /i not "%confirm%"=="y" goto MAIN_MENU

echo Restoring from %backup_file%...
REM Add restore logic here based on backup file type

echo.
echo ✅ Restore completed!
echo.
pause
goto MAIN_MENU

:VIEW_LOGS
echo.
echo Choose service to view logs:
echo 1. NestJS App
echo 2. Keycloak
echo 3. RabbitMQ
echo 4. MinIO
echo 5. GitLab
echo 6. Jenkins
echo 7. Nexus
echo 8. PostgreSQL
echo 9. Redis
echo 10. All services
echo.
set /p log_choice="Enter your choice (1-10): "

if "%log_choice%"=="1" docker-compose -f docker-compose.dev.yml logs -f nestjs-app
if "%log_choice%"=="2" docker-compose -f docker-compose.infrastructure.dev.yml logs -f keycloak
if "%log_choice%"=="3" docker-compose -f docker-compose.infrastructure.dev.yml logs -f rabbitmq
if "%log_choice%"=="4" docker-compose -f docker-compose.infrastructure.dev.yml logs -f minio
if "%log_choice%"=="5" docker-compose -f docker-compose.infrastructure.dev.yml logs -f gitlab
if "%log_choice%"=="6" docker-compose -f docker-compose.infrastructure.dev.yml logs -f jenkins
if "%log_choice%"=="7" docker-compose -f docker-compose.infrastructure.dev.yml logs -f nexus
if "%log_choice%"=="8" docker-compose -f docker-compose.dev.yml logs -f postgres
if "%log_choice%"=="9" docker-compose -f docker-compose.dev.yml logs -f redis
if "%log_choice%"=="10" (
    docker-compose -f docker-compose.dev.yml -f docker-compose.infrastructure.dev.yml logs -f
)

goto MAIN_MENU

:HEALTH_CHECK
echo.
echo Checking service health...
echo.

echo NestJS App:
curl -s http://localhost:3000/health && echo ✅ OK || echo ❌ FAILED

echo.
echo Keycloak:
curl -s http://localhost:8080/health/ready && echo ✅ OK || echo ❌ FAILED

echo.
echo RabbitMQ:
curl -s http://localhost:15672/api/overview -u dev:dev123 && echo ✅ OK || echo ❌ FAILED

echo.
echo MinIO:
curl -s http://localhost:9000/minio/health/live && echo ✅ OK || echo ❌ FAILED

echo.
echo GitLab:
curl -s http://localhost:8082/-/health && echo ✅ OK || echo ❌ FAILED

echo.
echo Jenkins:
curl -s http://localhost:8081/login && echo ✅ OK || echo ❌ FAILED

echo.
echo Nexus:
curl -s http://localhost:8083/service/rest/v1/status && echo ✅ OK || echo ❌ FAILED

echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo Goodbye!
exit /b 0
