@echo off
title Development Environment Resource Monitor
color 0B

:MAIN_MENU
cls
echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                    RESOURCE USAGE MONITOR                        ║
echo ╠══════════════════════════════════════════════════════════════════╣
echo ║                                                                  ║
echo ║  1. 📊 REAL-TIME RESOURCE USAGE                                 ║
echo ║  2. 💾 MEMORY USAGE BY SERVICE                                   ║
echo ║  3. ⚡ CPU USAGE BY SERVICE                                      ║
echo ║  4. 💿 DISK USAGE ANALYSIS                                       ║
echo ║  5. 🌐 NETWORK USAGE                                            ║
echo ║  6. 🧹 CLEANUP RESOURCES                                         ║
echo ║  7. 📈 GENERATE USAGE REPORT                                     ║
echo ║  8. ❌ EXIT                                                      ║
echo ║                                                                  ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.
set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto REALTIME_USAGE
if "%choice%"=="2" goto MEMORY_USAGE
if "%choice%"=="3" goto CPU_USAGE
if "%choice%"=="4" goto DISK_USAGE
if "%choice%"=="5" goto NETWORK_USAGE
if "%choice%"=="6" goto CLEANUP_RESOURCES
if "%choice%"=="7" goto GENERATE_REPORT
if "%choice%"=="8" goto EXIT
goto MAIN_MENU

:REALTIME_USAGE
echo.
echo 📊 Real-time Resource Usage (Press Ctrl+C to stop)
echo ================================================================
echo.
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
pause
goto MAIN_MENU

:MEMORY_USAGE
echo.
echo 💾 Memory Usage Analysis
echo ================================================================
echo.
echo Top 10 Memory Consumers:
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}\t{{.MemPerc}}" | head -11
echo.
echo System Memory Info:
powershell "Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-List"
echo.
echo Docker Memory Usage:
docker system df
echo.
pause
goto MAIN_MENU

:CPU_USAGE
echo.
echo ⚡ CPU Usage Analysis  
echo ================================================================
echo.
echo Current CPU Usage by Container:
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}" | sort /r /+2
echo.
echo System CPU Info:
wmic cpu get name,numberofcores,numberoflogicalprocessors,maxclockspeed /format:table
echo.
echo Current System CPU Usage:
wmic cpu get loadpercentage /value
echo.
pause
goto MAIN_MENU

:DISK_USAGE
echo.
echo 💿 Disk Usage Analysis
echo ================================================================
echo.
echo Docker Storage Usage:
docker system df -v
echo.
echo Container Volume Usage:
docker ps --format "table {{.Names}}\t{{.Size}}" 
echo.
echo System Disk Space:
wmic logicaldisk get size,freespace,caption /format:table
echo.
pause
goto MAIN_MENU

:NETWORK_USAGE
echo.
echo 🌐 Network Usage Analysis
echo ================================================================
echo.
echo Container Network I/O:
docker stats --no-stream --format "table {{.Container}}\t{{.NetIO}}"
echo.
echo Docker Networks:
docker network ls
echo.
echo Network Connections:
netstat -an | findstr ":8080 :8081 :8082 :8083 :3000 :5435 :6380 :9090 :3001"
echo.
pause
goto MAIN_MENU

:CLEANUP_RESOURCES
echo.
echo 🧹 Resource Cleanup Options
echo ================================================================
echo.
echo 1. Clean unused images
echo 2. Clean unused volumes  
echo 3. Clean unused networks
echo 4. Clean build cache
echo 5. FULL CLEANUP (WARNING: Removes everything)
echo 6. Back to main menu
echo.
set /p cleanup_choice="Choose cleanup option (1-6): "

if "%cleanup_choice%"=="1" (
    echo Cleaning unused images...
    docker image prune -a -f
    echo ✅ Images cleaned!
)
if "%cleanup_choice%"=="2" (
    echo Cleaning unused volumes...
    docker volume prune -f
    echo ✅ Volumes cleaned!
)
if "%cleanup_choice%"=="3" (
    echo Cleaning unused networks...
    docker network prune -f
    echo ✅ Networks cleaned!
)
if "%cleanup_choice%"=="4" (
    echo Cleaning build cache...
    docker builder prune -a -f
    echo ✅ Build cache cleaned!
)
if "%cleanup_choice%"=="5" (
    echo.
    echo ⚠️  WARNING: This will remove ALL Docker data!
    set /p confirm="Type 'DESTROY' to confirm: "
    if "%confirm%"=="DESTROY" (
        docker system prune -a -f --volumes
        echo ✅ Everything cleaned!
    ) else (
        echo ❌ Cleanup cancelled.
    )
)
if "%cleanup_choice%"=="6" goto MAIN_MENU

echo.
echo Space freed:
docker system df
pause
goto MAIN_MENU

:GENERATE_REPORT
echo.
echo 📈 Generating Resource Usage Report...
echo ================================================================
echo.

set report_file=resource-report-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%.txt
echo Development Environment Resource Report > %report_file%
echo Generated on: %date% %time% >> %report_file%
echo ================================================================ >> %report_file%
echo. >> %report_file%

echo === CONTAINER RESOURCE USAGE === >> %report_file%
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" >> %report_file%
echo. >> %report_file%

echo === DOCKER STORAGE USAGE === >> %report_file%
docker system df >> %report_file%
echo. >> %report_file%

echo === SYSTEM INFORMATION === >> %report_file%
wmic computersystem get TotalPhysicalMemory,NumberOfProcessors /format:list >> %report_file%
wmic cpu get Name,NumberOfCores,MaxClockSpeed /format:list >> %report_file%
echo. >> %report_file%

echo === DISK SPACE === >> %report_file%
wmic logicaldisk get size,freespace,caption /format:table >> %report_file%
echo. >> %report_file%

echo === RUNNING CONTAINERS === >> %report_file%
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> %report_file%

echo ✅ Report generated: %report_file%
echo.
echo Report Contents:
echo ================================================================
type %report_file%
echo ================================================================
pause
goto MAIN_MENU

:EXIT
echo.
echo 📊 Resource monitoring complete!
echo.
echo 💡 Tips for optimization:
echo   • Stop unused services to free resources
echo   • Use 'docker system prune' regularly
echo   • Monitor with Grafana for detailed metrics
echo   • Consider upgrading hardware if consistently over 80% usage
echo.
exit /b 0
