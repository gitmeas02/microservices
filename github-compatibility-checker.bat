@echo off
REM GitHub File Size and Type Checker
REM This script identifies files that cannot be pushed to GitHub and provides solutions

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   GitHub Compatibility Checker
echo ==========================================
echo.

set "PROJECT_DIR=%~dp0"
set "REPORT_FILE=%PROJECT_DIR%github-issues-report.txt"

echo 📁 Scanning: %PROJECT_DIR%
echo 📄 Report: %REPORT_FILE%
echo.

REM Clear previous report
if exist "%REPORT_FILE%" del "%REPORT_FILE%"

echo ==========================================
echo  Scanning for GitHub Issues
echo ==========================================
echo.

REM Initialize counters
set "LARGE_FILES=0"
set "BLOCKED_TYPES=0"
set "BINARY_FILES=0"
set "PROBLEMATIC_PATHS=0"

echo # GitHub Issues Report > "%REPORT_FILE%"
echo Generated: %date% %time% >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

REM Check for files larger than 100MB (GitHub limit)
echo 📊 Checking file sizes (GitHub limit: 100MB)...
echo ## Large Files (>100MB) >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

for /r "%PROJECT_DIR%" %%f in (*) do (
    if exist "%%f" (
        for %%s in ("%%f") do (
            if %%~zs gtr 104857600 (
                set /a LARGE_FILES+=1
                echo ⚠️  Large: %%f ^(%%~zs bytes^)
                echo - %%f ^(%%~zs bytes^) >> "%REPORT_FILE%"
            )
        )
    )
)

if %LARGE_FILES% equ 0 (
    echo ✅ No files larger than 100MB found
    echo No large files found >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"

REM Check for blocked file types
echo 📋 Checking for blocked file types...
echo ## Potentially Blocked File Types >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

set "BLOCKED_EXTENSIONS=.exe .msi .dll .so .dylib .app .deb .rpm .dmg .iso .img .bin .dat .db .sqlite .log .tmp .temp .cache .lock .pid"

for %%e in (%BLOCKED_EXTENSIONS%) do (
    for /r "%PROJECT_DIR%" %%f in (*%%e) do (
        if exist "%%f" (
            set /a BLOCKED_TYPES+=1
            echo ⚠️  Blocked type: %%f
            echo - %%f >> "%REPORT_FILE%"
        )
    )
)

if %BLOCKED_TYPES% equ 0 (
    echo ✅ No obviously blocked file types found
    echo No blocked file types found >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"

REM Check for binary files that might cause issues
echo 🔍 Checking for binary files...
echo ## Binary Files >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

set "BINARY_EXTENSIONS=.pdf .doc .docx .xls .xlsx .ppt .pptx .zip .tar .gz .7z .rar .jar .war .ear .class .pyc"

for %%e in (%BINARY_EXTENSIONS%) do (
    for /r "%PROJECT_DIR%" %%f in (*%%e) do (
        if exist "%%f" (
            set /a BINARY_FILES+=1
            echo ℹ️  Binary: %%f
            echo - %%f >> "%REPORT_FILE%"
        )
    )
)

if %BINARY_FILES% equ 0 (
    echo ✅ No problematic binary files found
    echo No problematic binary files found >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"

REM Check for problematic paths (long paths, special characters)
echo 🛤️ Checking for problematic paths...
echo ## Problematic Paths >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

for /r "%PROJECT_DIR%" %%f in (*) do (
    set "FILEPATH=%%f"
    set "FILENAME=%%~nxf"
    
    REM Check path length (Windows limit ~260 chars, GitHub might have issues)
    if "!FILEPATH:~250!" neq "" (
        set /a PROBLEMATIC_PATHS+=1
        echo ⚠️  Long path: %%f
        echo - Long path: %%f >> "%REPORT_FILE%"
    )
    
    REM Check for spaces in filenames (can cause issues)
    echo "!FILENAME!" | find " " >nul && (
        echo ℹ️  Space in name: %%f
        echo - Space in filename: %%f >> "%REPORT_FILE%"
    )
)

if %PROBLEMATIC_PATHS% equ 0 (
    echo ✅ No problematic paths found
    echo No problematic paths found >> "%REPORT_FILE%"
)
echo. >> "%REPORT_FILE%"

echo.
echo ==========================================
echo  Scan Results Summary
echo ==========================================
echo.

echo ## Summary >> "%REPORT_FILE%"
echo - Large files: %LARGE_FILES% >> "%REPORT_FILE%"
echo - Blocked file types: %BLOCKED_TYPES% >> "%REPORT_FILE%"
echo - Binary files: %BINARY_FILES% >> "%REPORT_FILE%"
echo - Problematic paths: %PROBLEMATIC_PATHS% >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo 📊 Found Issues:
echo ├─ Large files (>100MB): %LARGE_FILES%
echo ├─ Blocked file types: %BLOCKED_TYPES%
echo ├─ Binary files: %BINARY_FILES%
echo └─ Problematic paths: %PROBLEMATIC_PATHS%
echo.

set /a TOTAL_ISSUES=%LARGE_FILES%+%BLOCKED_TYPES%+%PROBLEMATIC_PATHS%

if %TOTAL_ISSUES% equ 0 (
    echo ✅ Great! No major GitHub compatibility issues found.
    echo Your project should push to GitHub without problems.
) else (
    echo ⚠️  Found %TOTAL_ISSUES% potential issues that might prevent GitHub push.
    echo 📄 Detailed report saved to: %REPORT_FILE%
)

echo.
echo ==========================================
echo  Solutions for Common Issues
echo ==========================================
echo.

echo ## Solutions >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

echo 💡 Solutions for GitHub Issues:
echo.
echo 🔧 For Large Files:
echo ├─ Use Git LFS (Large File Storage): git lfs track "*.large-extension"
echo ├─ Split large files into smaller chunks
echo ├─ Store large files externally (cloud storage, CDN)
echo └─ Use .gitignore to exclude them
echo.

echo 🔧 For Binary Files:
echo ├─ Use .gitignore to exclude unnecessary binaries
echo ├─ Document how to obtain/generate these files
echo ├─ Use package managers instead (npm, maven, etc.)
echo └─ Store in external artifact repositories
echo.

echo 🔧 For Blocked File Types:
echo ├─ Rename extensions if needed (.exe.txt, .dll.backup)
echo ├─ Use .gitignore to exclude them
echo ├─ Store in releases section instead of main repository
echo └─ Document alternative installation methods
echo.

echo 🔧 For Path Issues:
echo ├─ Shorten directory names
echo ├─ Remove spaces from filenames
echo ├─ Use underscores instead of spaces
echo └─ Restructure deep directory hierarchies
echo.

echo ### Large Files Solutions >> "%REPORT_FILE%"
echo - Use Git LFS: git lfs track "*.extension" >> "%REPORT_FILE%"
echo - Split files or store externally >> "%REPORT_FILE%"
echo - Add to .gitignore >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo ### Binary Files Solutions >> "%REPORT_FILE%"
echo - Add to .gitignore if not essential >> "%REPORT_FILE%"
echo - Use package managers for dependencies >> "%REPORT_FILE%"
echo - Store in artifact repositories >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"
echo ### Blocked Files Solutions >> "%REPORT_FILE%"
echo - Rename extensions temporarily >> "%REPORT_FILE%"
echo - Use GitHub releases for executables >> "%REPORT_FILE%"
echo - Document installation procedures >> "%REPORT_FILE%"
echo. >> "%REPORT_FILE%"

set /p "VIEW_REPORT=Do you want to view the detailed report? (y/N): "
if /i "!VIEW_REPORT!" equ "y" (
    notepad "%REPORT_FILE%"
)

set /p "FIX_ISSUES=Do you want to automatically fix common issues? (y/N): "
if /i "!FIX_ISSUES!" equ "y" (
    echo.
    echo 🔧 Applying automatic fixes...
    call :apply_fixes
)

echo.
echo ✅ Scan completed! Check the report for details.
pause
goto :eof

:apply_fixes
echo.
echo ==========================================
echo  Applying Automatic Fixes
echo ==========================================
echo.

REM Update .gitignore with common problematic files
echo 📝 Updating .gitignore...

set "GITIGNORE_FILE=%PROJECT_DIR%.gitignore"

REM Add common exclusions if not already present
findstr /C:"# Auto-generated exclusions" "%GITIGNORE_FILE%" >nul 2>&1
if errorlevel 1 (
    echo. >> "%GITIGNORE_FILE%"
    echo # Auto-generated exclusions for GitHub compatibility >> "%GITIGNORE_FILE%"
    echo. >> "%GITIGNORE_FILE%"
    echo # Large files and binary content >> "%GITIGNORE_FILE%"
    echo *.exe >> "%GITIGNORE_FILE%"
    echo *.dll >> "%GITIGNORE_FILE%"
    echo *.so >> "%GITIGNORE_FILE%"
    echo *.dylib >> "%GITIGNORE_FILE%"
    echo *.app >> "%GITIGNORE_FILE%"
    echo *.deb >> "%GITIGNORE_FILE%"
    echo *.rpm >> "%GITIGNORE_FILE%"
    echo *.dmg >> "%GITIGNORE_FILE%"
    echo *.iso >> "%GITIGNORE_FILE%"
    echo *.img >> "%GITIGNORE_FILE%"
    echo *.bin >> "%GITIGNORE_FILE%"
    echo. >> "%GITIGNORE_FILE%"
    echo # Database and cache files >> "%GITIGNORE_FILE%"
    echo *.db >> "%GITIGNORE_FILE%"
    echo *.sqlite >> "%GITIGNORE_FILE%"
    echo *.sqlite3 >> "%GITIGNORE_FILE%"
    echo *.cache >> "%GITIGNORE_FILE%"
    echo *.lock >> "%GITIGNORE_FILE%"
    echo *.pid >> "%GITIGNORE_FILE%"
    echo. >> "%GITIGNORE_FILE%"
    echo # Large archives >> "%GITIGNORE_FILE%"
    echo *.zip >> "%GITIGNORE_FILE%"
    echo *.tar >> "%GITIGNORE_FILE%"
    echo *.tar.gz >> "%GITIGNORE_FILE%"
    echo *.7z >> "%GITIGNORE_FILE%"
    echo *.rar >> "%GITIGNORE_FILE%"
    echo. >> "%GITIGNORE_FILE%"
    
    echo ✅ Updated .gitignore with common exclusions
) else (
    echo ℹ️  .gitignore already contains auto-generated exclusions
)

REM Remove problematic files that are commonly generated
echo 🧹 Cleaning up generated files...

REM Remove common cache and temporary files
for /r "%PROJECT_DIR%" %%f in (*.tmp *.temp *.cache *.lock *.pid) do (
    if exist "%%f" (
        del "%%f" >nul 2>&1
        echo ├─ Removed: %%f
    )
)

REM Remove build artifacts if they exist
if exist "%PROJECT_DIR%lesson1\dist" (
    rmdir /s /q "%PROJECT_DIR%lesson1\dist" >nul 2>&1
    echo ├─ Removed: lesson1\dist (build artifacts)
)

if exist "%PROJECT_DIR%lesson1\node_modules" (
    echo ├─ Found: lesson1\node_modules (large directory - add to .gitignore)
    findstr /C:"node_modules" "%GITIGNORE_FILE%" >nul 2>&1
    if errorlevel 1 (
        echo node_modules/ >> "%GITIGNORE_FILE%"
        echo ├─ Added node_modules/ to .gitignore
    )
)

echo ✅ Automatic fixes applied
echo.
return
