@echo off
REM GitHub Preparation Script
REM This script helps prepare your project for GitHub by cleaning up unnecessary files

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   GitHub Repository Preparation Tool
echo ==========================================
echo.

set "PROJECT_DIR=%~dp0"
set "GITHUB_DIR=%PROJECT_DIR%github-ready"

echo 📁 Project Directory: %PROJECT_DIR%
echo 📁 GitHub Ready Directory: %GITHUB_DIR%
echo.

REM Create GitHub-ready directory
if exist "%GITHUB_DIR%" (
    echo ⚠️  GitHub-ready directory already exists
    set /p "CLEAN=Do you want to clean it first? (y/N): "
    if /i "!CLEAN!" equ "y" (
        echo 🧹 Cleaning existing directory...
        rmdir /s /q "%GITHUB_DIR%"
    )
)

if not exist "%GITHUB_DIR%" (
    mkdir "%GITHUB_DIR%"
    echo ✅ Created GitHub-ready directory
)

echo.
echo ==========================================
echo  Copying Files for GitHub
echo ==========================================
echo.

REM Copy essential files and directories
echo 📂 Copying project structure...

REM Root level files
echo ├─ Copying root configuration files...
copy "%PROJECT_DIR%docker-compose*.yml" "%GITHUB_DIR%\" >nul 2>&1
copy "%PROJECT_DIR%*.md" "%GITHUB_DIR%\" >nul 2>&1
copy "%PROJECT_DIR%*.bat" "%GITHUB_DIR%\" >nul 2>&1
copy "%PROJECT_DIR%*.sh" "%GITHUB_DIR%\" >nul 2>&1
copy "%PROJECT_DIR%Makefile" "%GITHUB_DIR%\" >nul 2>&1
copy "%PROJECT_DIR%.gitignore" "%GITHUB_DIR%\" >nul 2>&1

REM Infrastructure directory
echo ├─ Copying infrastructure configurations...
if not exist "%GITHUB_DIR%\infrastructure" mkdir "%GITHUB_DIR%\infrastructure"

REM Copy infrastructure files
xcopy "%PROJECT_DIR%infrastructure" "%GITHUB_DIR%\infrastructure" /E /I /H /Y >nul 2>&1

REM Clean up generated files from infrastructure
echo ├─ Cleaning generated files...
if exist "%GITHUB_DIR%\infrastructure\nginx\ssl\*.pem" del "%GITHUB_DIR%\infrastructure\nginx\ssl\*.pem" >nul 2>&1
if exist "%GITHUB_DIR%\infrastructure\nginx\ssl\*.key" del "%GITHUB_DIR%\infrastructure\nginx\ssl\*.key" >nul 2>&1
if exist "%GITHUB_DIR%\infrastructure\nginx\ssl\openssl.conf" del "%GITHUB_DIR%\infrastructure\nginx\ssl\openssl.conf" >nul 2>&1
if exist "%GITHUB_DIR%\infrastructure\nginx\logs\*.log" del "%GITHUB_DIR%\infrastructure\nginx\logs\*.log" >nul 2>&1

REM NestJS Application
echo ├─ Copying NestJS application...
if not exist "%GITHUB_DIR%\lesson1" mkdir "%GITHUB_DIR%\lesson1"

REM Copy lesson1 source files
xcopy "%PROJECT_DIR%lesson1\src" "%GITHUB_DIR%\lesson1\src" /E /I /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%lesson1\test" "%GITHUB_DIR%\lesson1\test" /E /I /H /Y >nul 2>&1
xcopy "%PROJECT_DIR%lesson1\setup" "%GITHUB_DIR%\lesson1\setup" /E /I /H /Y >nul 2>&1

REM Copy lesson1 configuration files
copy "%PROJECT_DIR%lesson1\package.json" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\package-lock.json" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\tsconfig*.json" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\nest-cli.json" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\eslint.config.mjs" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\.prettierrc" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\README.md" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\Jenkinsfile*" "%GITHUB_DIR%\lesson1\" >nul 2>&1
copy "%PROJECT_DIR%lesson1\healthcheck.js" "%GITHUB_DIR%\lesson1\" >nul 2>&1

REM Copy environment template files (not actual .env files)
copy "%PROJECT_DIR%lesson1\.env.copy.*" "%GITHUB_DIR%\lesson1\" >nul 2>&1

REM Vue.js Application (if exists)
if exist "%PROJECT_DIR%lesson1_vue_js" (
    echo ├─ Copying Vue.js application...
    if not exist "%GITHUB_DIR%\lesson1_vue_js" mkdir "%GITHUB_DIR%\lesson1_vue_js"
    xcopy "%PROJECT_DIR%lesson1_vue_js" "%GITHUB_DIR%\lesson1_vue_js" /E /I /H /Y >nul 2>&1
    REM Clean up node_modules and dist if they exist
    if exist "%GITHUB_DIR%\lesson1_vue_js\node_modules" rmdir /s /q "%GITHUB_DIR%\lesson1_vue_js\node_modules" >nul 2>&1
    if exist "%GITHUB_DIR%\lesson1_vue_js\dist" rmdir /s /q "%GITHUB_DIR%\lesson1_vue_js\dist" >nul 2>&1
)

echo ├─ Cleaning up unnecessary files...

REM Remove dist and node_modules from copied files
if exist "%GITHUB_DIR%\lesson1\dist" rmdir /s /q "%GITHUB_DIR%\lesson1\dist" >nul 2>&1
if exist "%GITHUB_DIR%\lesson1\node_modules" rmdir /s /q "%GITHUB_DIR%\lesson1\node_modules" >nul 2>&1

REM Remove actual environment files (keep only templates)
if exist "%GITHUB_DIR%\lesson1\.env" del "%GITHUB_DIR%\lesson1\.env" >nul 2>&1
if exist "%GITHUB_DIR%\lesson1\.env.local" del "%GITHUB_DIR%\lesson1\.env.local" >nul 2>&1
if exist "%GITHUB_DIR%\lesson1\.env.development" del "%GITHUB_DIR%\lesson1\.env.development" >nul 2>&1
if exist "%GITHUB_DIR%\lesson1\.env.production" del "%GITHUB_DIR%\lesson1\.env.production" >nul 2>&1

echo └─ Copy completed!
echo.

echo ==========================================
echo  File Analysis
echo ==========================================
echo.

REM Count files in source vs GitHub-ready
echo 📊 Analyzing file counts...

for /f %%i in ('dir "%PROJECT_DIR%" /s /a-d ^| find "File(s)"') do set "SOURCE_FILES=%%i"
for /f %%i in ('dir "%GITHUB_DIR%" /s /a-d ^| find "File(s)"') do set "GITHUB_FILES=%%i"

echo ├─ Original project files: %SOURCE_FILES%
echo ├─ GitHub-ready files: %GITHUB_FILES%
echo └─ Files excluded: Not calculated
echo.

echo ==========================================
echo  GitHub Repository Structure
echo ==========================================
echo.

echo 📁 Your GitHub-ready project structure:
echo.
tree "%GITHUB_DIR%" /F /A
echo.

echo ==========================================
echo  Files Excluded from GitHub
echo ==========================================
echo.
echo 🚫 These files were excluded (as per .gitignore):
echo ├─ SSL Certificates (*.pem, *.key)
echo ├─ Log files (*.log)
echo ├─ Environment files (.env, .env.local, etc.)
echo ├─ Built files (dist/, build/)
echo ├─ Dependencies (node_modules/)
echo ├─ IDE files (.vscode/, .idea/)
echo └─ Temporary files (*.tmp, *.temp)
echo.

echo ==========================================
echo  Next Steps for GitHub
echo ==========================================
echo.
echo 🚀 Ready to push to GitHub:
echo.
echo 1. Navigate to GitHub-ready directory:
echo    cd "%GITHUB_DIR%"
echo.
echo 2. Initialize Git repository:
echo    git init
echo.
echo 3. Add all files:
echo    git add .
echo.
echo 4. Create initial commit:
echo    git commit -m "Initial commit: Complete DevOps infrastructure setup"
echo.
echo 5. Add GitHub remote:
echo    git remote add origin https://github.com/username/repository-name.git
echo.
echo 6. Push to GitHub:
echo    git branch -M main
echo    git push -u origin main
echo.

echo ==========================================
echo  Important Notes
echo ==========================================
echo.
echo 📝 Remember to:
echo ├─ Create environment files from templates after cloning
echo ├─ Generate SSL certificates using provided scripts
echo ├─ Install dependencies with npm install
echo ├─ Review and update README.md files
echo └─ Set up GitHub repository settings (issues, wiki, etc.)
echo.

echo ✅ GitHub preparation completed!
echo 📁 Files ready in: %GITHUB_DIR%
echo.

set /p "OPEN_DIR=Do you want to open the GitHub-ready directory? (y/N): "
if /i "!OPEN_DIR!" equ "y" (
    explorer "%GITHUB_DIR%"
)

echo.
echo 🎉 Your project is ready for GitHub! Happy coding!
pause
