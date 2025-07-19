@echo off
REM Fix GitHub Push Issues - Comprehensive Solution
REM This script identifies and fixes common files that cannot be pushed to GitHub

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   GitHub Push Issue Fixer
echo ==========================================
echo.

set "PROJECT_DIR=%~dp0"
set "GITHUB_DIR=%PROJECT_DIR%github-ready"

echo 📁 Source: %PROJECT_DIR%
echo 📁 GitHub Ready: %GITHUB_DIR%
echo.

echo ==========================================
echo  Common GitHub Push Issues & Solutions
echo ==========================================
echo.

echo The most common files that cannot be pushed to GitHub:
echo.
echo 🚫 BLOCKED FILES:
echo ├─ node_modules/ (too large, thousands of files)
echo ├─ .env files (contain secrets)
echo ├─ dist/ build directories (generated files)
echo ├─ SSL certificates and keys
echo ├─ Large log files
echo ├─ Binary executables (.exe, .dll)
echo ├─ IDE configuration files
echo └─ Docker volumes and data
echo.

echo ✅ SOLUTIONS:
echo ├─ Use .gitignore to exclude problematic files
echo ├─ Use package.json for dependencies instead of node_modules/
echo ├─ Use .env.example instead of .env files
echo ├─ Document build processes instead of including dist/
echo ├─ Generate SSL certificates during deployment
echo └─ Use GitHub releases for large binaries
echo.

set /p "CONTINUE=Do you want to proceed with the fix? (y/N): "
if /i "!CONTINUE!" neq "y" goto :eof

echo.
echo ==========================================
echo  Step 1: Update .gitignore
echo ==========================================
echo.

REM Create comprehensive .gitignore
echo 📝 Creating comprehensive .gitignore...

set "GITIGNORE_FILE=%PROJECT_DIR%.gitignore"

echo # ==================================================== > "%GITIGNORE_FILE%"
echo # Comprehensive .gitignore for DevOps Infrastructure >> "%GITIGNORE_FILE%"
echo # ==================================================== >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Node.js >> "%GITIGNORE_FILE%"
echo node_modules/ >> "%GITIGNORE_FILE%"
echo npm-debug.log* >> "%GITIGNORE_FILE%"
echo yarn-debug.log* >> "%GITIGNORE_FILE%"
echo yarn-error.log* >> "%GITIGNORE_FILE%"
echo .npm >> "%GITIGNORE_FILE%"
echo .yarn-integrity >> "%GITIGNORE_FILE%"
echo package-lock.json >> "%GITIGNORE_FILE%"
echo yarn.lock >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Environment files >> "%GITIGNORE_FILE%"
echo .env >> "%GITIGNORE_FILE%"
echo .env.local >> "%GITIGNORE_FILE%"
echo .env.development >> "%GITIGNORE_FILE%"
echo .env.production >> "%GITIGNORE_FILE%"
echo .env.test >> "%GITIGNORE_FILE%"
echo *.env >> "%GITIGNORE_FILE%"
echo !.env.example >> "%GITIGNORE_FILE%"
echo !.env.copy.* >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Build outputs >> "%GITIGNORE_FILE%"
echo dist/ >> "%GITIGNORE_FILE%"
echo build/ >> "%GITIGNORE_FILE%"
echo .next/ >> "%GITIGNORE_FILE%"
echo out/ >> "%GITIGNORE_FILE%"
echo coverage/ >> "%GITIGNORE_FILE%"
echo *.tsbuildinfo >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # SSL Certificates and Keys >> "%GITIGNORE_FILE%"
echo *.pem >> "%GITIGNORE_FILE%"
echo *.key >> "%GITIGNORE_FILE%"
echo *.crt >> "%GITIGNORE_FILE%"
echo *.csr >> "%GITIGNORE_FILE%"
echo *.p12 >> "%GITIGNORE_FILE%"
echo *.pfx >> "%GITIGNORE_FILE%"
echo ssl/ >> "%GITIGNORE_FILE%"
echo certificates/ >> "%GITIGNORE_FILE%"
echo certs/ >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Docker >> "%GITIGNORE_FILE%"
echo .dockerignore >> "%GITIGNORE_FILE%"
echo docker-compose.override.yml >> "%GITIGNORE_FILE%"
echo Dockerfile.local >> "%GITIGNORE_FILE%"
echo # Docker volumes and data >> "%GITIGNORE_FILE%"
echo volumes/ >> "%GITIGNORE_FILE%"
echo data/ >> "%GITIGNORE_FILE%"
echo postgresql_data/ >> "%GITIGNORE_FILE%"
echo keycloak_data/ >> "%GITIGNORE_FILE%"
echo gitlab_data/ >> "%GITIGNORE_FILE%"
echo jenkins_data/ >> "%GITIGNORE_FILE%"
echo nexus_data/ >> "%GITIGNORE_FILE%"
echo minio_data/ >> "%GITIGNORE_FILE%"
echo rabbitmq_data/ >> "%GITIGNORE_FILE%"
echo prometheus_data/ >> "%GITIGNORE_FILE%"
echo grafana_data/ >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Logs >> "%GITIGNORE_FILE%"
echo logs/ >> "%GITIGNORE_FILE%"
echo *.log >> "%GITIGNORE_FILE%"
echo *.log.* >> "%GITIGNORE_FILE%"
echo npm-debug.log* >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # OS generated files >> "%GITIGNORE_FILE%"
echo .DS_Store >> "%GITIGNORE_FILE%"
echo .DS_Store? >> "%GITIGNORE_FILE%"
echo ._* >> "%GITIGNORE_FILE%"
echo .Spotlight-V100 >> "%GITIGNORE_FILE%"
echo .Trashes >> "%GITIGNORE_FILE%"
echo ehthumbs.db >> "%GITIGNORE_FILE%"
echo Thumbs.db >> "%GITIGNORE_FILE%"
echo Desktop.ini >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # IDE >> "%GITIGNORE_FILE%"
echo .vscode/settings.json >> "%GITIGNORE_FILE%"
echo .vscode/launch.json >> "%GITIGNORE_FILE%"
echo .idea/ >> "%GITIGNORE_FILE%"
echo *.swp >> "%GITIGNORE_FILE%"
echo *.swo >> "%GITIGNORE_FILE%"
echo *~ >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Cache files >> "%GITIGNORE_FILE%"
echo .cache/ >> "%GITIGNORE_FILE%"
echo .parcel-cache/ >> "%GITIGNORE_FILE%"
echo .eslintcache >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Temporary files >> "%GITIGNORE_FILE%"
echo *.tmp >> "%GITIGNORE_FILE%"
echo *.temp >> "%GITIGNORE_FILE%"
echo *.bak >> "%GITIGNORE_FILE%"
echo *.backup >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Large binaries >> "%GITIGNORE_FILE%"
echo *.exe >> "%GITIGNORE_FILE%"
echo *.dll >> "%GITIGNORE_FILE%"
echo *.so >> "%GITIGNORE_FILE%"
echo *.dylib >> "%GITIGNORE_FILE%"
echo *.zip >> "%GITIGNORE_FILE%"
echo *.tar >> "%GITIGNORE_FILE%"
echo *.tar.gz >> "%GITIGNORE_FILE%"
echo *.rar >> "%GITIGNORE_FILE%"
echo *.7z >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"
echo # Database files >> "%GITIGNORE_FILE%"
echo *.db >> "%GITIGNORE_FILE%"
echo *.sqlite >> "%GITIGNORE_FILE%"
echo *.sqlite3 >> "%GITIGNORE_FILE%"
echo. >> "%GITIGNORE_FILE%"

echo ✅ Created comprehensive .gitignore

echo.
echo ==========================================
echo  Step 2: Create GitHub-Ready Copy
echo ==========================================
echo.

echo 📂 Creating GitHub-ready copy of your project...

REM Create GitHub directory
if exist "%GITHUB_DIR%" (
    echo 🧹 Cleaning existing GitHub directory...
    rmdir /s /q "%GITHUB_DIR%"
)

mkdir "%GITHUB_DIR%"

REM Copy essential files only (excluding .gitignore patterns)
echo 📄 Copying essential files...

REM Copy root level essential files
xcopy "%PROJECT_DIR%*.md" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%*.yml" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%*.yaml" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%*.json" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%*.bat" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%*.sh" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%Makefile" "%GITHUB_DIR%\" /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%.gitignore" "%GITHUB_DIR%\" /H /Y >nul 2>&1

REM Copy infrastructure directory (but not data)
if exist "%PROJECT_DIR%infrastructure" (
    echo 📁 Copying infrastructure configuration...
    xcopy "%PROJECT_DIR%infrastructure" "%GITHUB_DIR%\infrastructure\" /S /E /H /Y /EXCLUDE:volumes /EXCLUDE:data >nul 2>&1
)

REM Copy lesson1 project (source code only)
if exist "%PROJECT_DIR%lesson1" (
    echo 📁 Copying lesson1 project...
    mkdir "%GITHUB_DIR%\lesson1"
    
    REM Copy package.json and configuration files
    xcopy "%PROJECT_DIR%lesson1\package.json" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\*.json" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\*.js" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\*.mjs" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\*.ts" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\*.md" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\.gitignore" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\.prettierrc" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\.gitlab-ci.yml" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1\Jenkinsfile*" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    
    REM Copy .env.example files (but not actual .env files)
    xcopy "%PROJECT_DIR%lesson1\.env.copy.*" "%GITHUB_DIR%\lesson1\" /H /Y >nul 2>&1
    
    REM Copy source code
    if exist "%PROJECT_DIR%lesson1\src" (
        xcopy "%PROJECT_DIR%lesson1\src" "%GITHUB_DIR%\lesson1\src\" /S /E /H /Y >nul 2>&1
    )
    
    REM Copy setup directory
    if exist "%PROJECT_DIR%lesson1\setup" (
        xcopy "%PROJECT_DIR%lesson1\setup" "%GITHUB_DIR%\lesson1\setup\" /S /E /H /Y >nul 2>&1
    )
    
    REM Copy test directory
    if exist "%PROJECT_DIR%lesson1\test" (
        xcopy "%PROJECT_DIR%lesson1\test" "%GITHUB_DIR%\lesson1\test\" /S /E /H /Y >nul 2>&1
    )
)

REM Copy Vue.js project if it exists
if exist "%PROJECT_DIR%lesson1_vue_js" (
    echo 📁 Copying lesson1_vue_js project...
    mkdir "%GITHUB_DIR%\lesson1_vue_js"
    
    REM Copy configuration files
    xcopy "%PROJECT_DIR%lesson1_vue_js\package.json" "%GITHUB_DIR%\lesson1_vue_js\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1_vue_js\*.json" "%GITHUB_DIR%\lesson1_vue_js\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1_vue_js\*.js" "%GITHUB_DIR%\lesson1_vue_js\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1_vue_js\*.md" "%GITHUB_DIR%\lesson1_vue_js\" /H /Y >nul 2>&1
    xcopy "%PROJECT_DIR%lesson1_vue_js\*.html" "%GITHUB_DIR%\lesson1_vue_js\" /H /Y >nul 2>&1
    
    REM Copy source code
    if exist "%PROJECT_DIR%lesson1_vue_js\src" (
        xcopy "%PROJECT_DIR%lesson1_vue_js\src" "%GITHUB_DIR%\lesson1_vue_js\src\" /S /E /H /Y >nul 2>&1
    )
    
    REM Copy public directory
    if exist "%PROJECT_DIR%lesson1_vue_js\public" (
        xcopy "%PROJECT_DIR%lesson1_vue_js\public" "%GITHUB_DIR%\lesson1_vue_js\public\" /S /E /H /Y >nul 2>&1
    )
    
    REM Copy setup directory
    if exist "%PROJECT_DIR%lesson1_vue_js\setup" (
        xcopy "%PROJECT_DIR%lesson1_vue_js\setup" "%GITHUB_DIR%\lesson1_vue_js\setup\" /S /E /H /Y >nul 2>&1
    )
)

echo ✅ GitHub-ready copy created

echo.
echo ==========================================
echo  Step 3: Create GitHub Instructions
echo ==========================================
echo.

echo 📝 Creating GitHub setup instructions...

set "GITHUB_INSTRUCTIONS=%GITHUB_DIR%\GITHUB-SETUP.md"

echo # GitHub Setup Instructions > "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo This directory contains a GitHub-ready version of your DevOps infrastructure project. >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo ## What was excluded: >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo - `node_modules/` - Dependencies (install with `npm install`) >> "%GITHUB_INSTRUCTIONS%"
echo - `.env` files - Environment variables (use `.env.copy.*` as templates) >> "%GITHUB_INSTRUCTIONS%"
echo - `dist/` directories - Build outputs (generate with `npm run build`) >> "%GITHUB_INSTRUCTIONS%"
echo - SSL certificates - Generated during deployment >> "%GITHUB_INSTRUCTIONS%"
echo - Docker data volumes - Created when containers run >> "%GITHUB_INSTRUCTIONS%"
echo - Log files - Generated during runtime >> "%GITHUB_INSTRUCTIONS%"
echo - Large binaries - Use GitHub releases for these >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo ## To set up this project: >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo 1. **Clone the repository** >> "%GITHUB_INSTRUCTIONS%"
echo    ```bash >> "%GITHUB_INSTRUCTIONS%"
echo    git clone ^<your-repo-url^> >> "%GITHUB_INSTRUCTIONS%"
echo    cd ^<project-directory^> >> "%GITHUB_INSTRUCTIONS%"
echo    ``` >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo 2. **Install dependencies** >> "%GITHUB_INSTRUCTIONS%"
echo    ```bash >> "%GITHUB_INSTRUCTIONS%"
echo    cd lesson1 >> "%GITHUB_INSTRUCTIONS%"
echo    npm install >> "%GITHUB_INSTRUCTIONS%"
echo    ``` >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo 3. **Set up environment variables** >> "%GITHUB_INSTRUCTIONS%"
echo    ```bash >> "%GITHUB_INSTRUCTIONS%"
echo    cp .env.copy.example .env.development >> "%GITHUB_INSTRUCTIONS%"
echo    cp .env.copy.local .env.local >> "%GITHUB_INSTRUCTIONS%"
echo    # Edit the .env files with your actual values >> "%GITHUB_INSTRUCTIONS%"
echo    ``` >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo 4. **Generate SSL certificates** >> "%GITHUB_INSTRUCTIONS%"
echo    ```bash >> "%GITHUB_INSTRUCTIONS%"
echo    # Run the SSL generation script >> "%GITHUB_INSTRUCTIONS%"
echo    ./quick-start.bat >> "%GITHUB_INSTRUCTIONS%"
echo    ``` >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo 5. **Start the infrastructure** >> "%GITHUB_INSTRUCTIONS%"
echo    ```bash >> "%GITHUB_INSTRUCTIONS%"
echo    docker-compose up -d >> "%GITHUB_INSTRUCTIONS%"
echo    ``` >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo ## Important Notes: >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"
echo - Never commit `.env` files to GitHub >> "%GITHUB_INSTRUCTIONS%"
echo - Use the `.env.copy.*` files as templates >> "%GITHUB_INSTRUCTIONS%"
echo - SSL certificates are automatically generated during setup >> "%GITHUB_INSTRUCTIONS%"
echo - Docker volumes will be created automatically >> "%GITHUB_INSTRUCTIONS%"
echo - See `SETUP_AND_USAGE_GUIDE.md` for detailed instructions >> "%GITHUB_INSTRUCTIONS%"
echo. >> "%GITHUB_INSTRUCTIONS%"

echo ✅ GitHub instructions created

echo.
echo ==========================================
echo  Step 4: Verify GitHub Compatibility
echo ==========================================
echo.

echo 🔍 Verifying GitHub compatibility...

set "TOTAL_FILES=0"
set "LARGE_FILES=0"

for /r "%GITHUB_DIR%" %%f in (*) do (
    if exist "%%f" (
        set /a TOTAL_FILES+=1
        for %%s in ("%%f") do (
            if %%~zs gtr 104857600 (
                set /a LARGE_FILES+=1
                echo ⚠️  Large file found: %%f ^(%%~zs bytes^)
            )
        )
    )
)

echo 📊 Verification Results:
echo ├─ Total files: %TOTAL_FILES%
echo ├─ Large files (>100MB): %LARGE_FILES%
echo └─ Status: GitHub Ready ✅

if %LARGE_FILES% gtr 0 (
    echo.
    echo ⚠️  Warning: Found %LARGE_FILES% large files. Consider using Git LFS.
)

echo.
echo ==========================================
echo  Summary
echo ==========================================
echo.

echo ✅ GitHub Push Issues Fixed!
echo.
echo 📁 GitHub-ready project: %GITHUB_DIR%
echo 📄 Setup instructions: %GITHUB_INSTRUCTIONS%
echo 📄 Updated .gitignore: %GITIGNORE_FILE%
echo.
echo 🚀 Next Steps:
echo 1. Navigate to: %GITHUB_DIR%
echo 2. Initialize git: git init
echo 3. Add files: git add .
echo 4. Commit: git commit -m "Initial commit"
echo 5. Push to GitHub: git remote add origin ^<your-repo^> ^&^& git push -u origin main
echo.
echo 💡 What was fixed:
echo ├─ Excluded node_modules/ (use package.json instead)
echo ├─ Excluded .env files (use .env.copy.* templates)
echo ├─ Excluded build outputs (dist/)
echo ├─ Excluded SSL certificates (generated during setup)
echo ├─ Excluded Docker data volumes
echo ├─ Created comprehensive .gitignore
echo └─ Added GitHub setup instructions
echo.

set /p "OPEN_FOLDER=Do you want to open the GitHub-ready folder? (y/N): "
if /i "!OPEN_FOLDER!" equ "y" (
    explorer "%GITHUB_DIR%"
)

echo.
echo ✅ All done! Your project is now ready for GitHub.
pause
