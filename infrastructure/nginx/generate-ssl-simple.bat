@echo off
REM Simple SSL Certificate Generation using Docker
REM This script uses Docker to generate SSL certificates when OpenSSL is not available

setlocal enabledelayedexpansion

echo.
echo ========================================
echo  Simple Docker SSL Certificate Generator
echo ========================================
echo.

set "SSL_DIR=%~dp0ssl"
set "CERT_FILE=%SSL_DIR%\dev-cert.pem"
set "KEY_FILE=%SSL_DIR%\dev-key.pem"

REM Check if Docker is available
docker info >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ Docker is not running or not installed
    echo Please start Docker Desktop
    pause
    exit /b 1
)

echo ✅ Docker is running
echo.

REM Create SSL directory if it doesn't exist
if not exist "%SSL_DIR%" (
    mkdir "%SSL_DIR%"
    echo 📁 Created SSL directory: %SSL_DIR%
)

REM Check if certificates already exist
if exist "%CERT_FILE%" (
    echo ⚠️  SSL certificates already exist
    echo.
    set /p "REGENERATE=Do you want to regenerate certificates? (y/N): "
    if /i "!REGENERATE!" neq "y" (
        echo ℹ️  Using existing certificates
        goto :show_info
    )
    echo 🔄 Regenerating certificates...
)

echo 🔐 Generating SSL certificates using Docker...
echo.

REM First, create a configuration file for better certificate
set "CONFIG_FILE=%SSL_DIR%\ssl.conf"
(
echo [req]
echo distinguished_name = req_distinguished_name
echo req_extensions = v3_req
echo prompt = no
echo.
echo [req_distinguished_name]
echo C = US
echo ST = Development
echo L = Local
echo O = DevOps Infrastructure
echo OU = Development Team
echo CN = localhost
echo emailAddress = dev@localhost
echo.
echo [v3_req]
echo basicConstraints = CA:FALSE
echo keyUsage = nonRepudiation, digitalSignature, keyEncipherment
echo subjectAltName = @alt_names
echo.
echo [alt_names]
echo DNS.1 = localhost
echo DNS.2 = *.local
echo DNS.3 = auth.local
echo DNS.4 = git.local
echo DNS.5 = ci.local
echo DNS.6 = nexus.local
echo DNS.7 = storage.local
echo DNS.8 = rabbit.local
echo DNS.9 = prometheus.local
echo DNS.10 = grafana.local
echo DNS.11 = jenkins.local
echo DNS.12 = gitlab.local
echo DNS.13 = keycloak.local
echo DNS.14 = rabbitmq.local
echo DNS.15 = minio.local
echo DNS.16 = dashboards.local
echo DNS.17 = metrics.local
echo DNS.18 = artifacts.local
echo IP.1 = 127.0.0.1
echo IP.2 = ::1
) > "%CONFIG_FILE%"

echo � Created SSL configuration file

REM Generate certificate with proper extensions using Docker
echo 📜 Generating enhanced self-signed certificate and key...
docker run --rm -v "%SSL_DIR%:/ssl" -w /ssl alpine sh -c "apk add --no-cache openssl && openssl req -x509 -newkey rsa:2048 -keyout dev-key.pem -out dev-cert.pem -days 365 -nodes -config ssl.conf -extensions v3_req"

if !errorlevel! neq 0 (
    echo ❌ Enhanced method failed, trying simple method...
    docker run --rm -v "%SSL_DIR%:/ssl" -w /ssl alpine sh -c "apk add --no-cache openssl && openssl req -x509 -newkey rsa:2048 -keyout dev-key.pem -out dev-cert.pem -days 365 -nodes -subj '/C=US/ST=Development/L=Local/O=DevOps Infrastructure/OU=Development Team/CN=localhost'"
    
    if !errorlevel! neq 0 (
        echo ❌ All certificate generation methods failed
        echo.
        echo 💡 Alternative options:
        echo 1. Install Git for Windows (includes OpenSSL^)
        echo 2. Install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html
        echo 3. Use WSL with OpenSSL installed
        echo 4. Start services without SSL (option 2 in main menu^)
        pause
        exit /b 1
    )
)

REM Clean up config file
del "%CONFIG_FILE%" 2>nul

echo ✅ SSL certificates generated successfully using Docker!
echo.

:show_info
echo ========================================
echo  Certificate Information
echo ========================================
echo.
echo 📁 Location: %SSL_DIR%
echo 📜 Certificate: dev-cert.pem
echo 🔑 Private Key: dev-key.pem
echo.

echo ========================================
echo  Security Notes
echo ========================================
echo.
echo ⚠️  These are SELF-SIGNED certificates for DEVELOPMENT ONLY
echo 🚫 DO NOT use these certificates in production
echo 🔒 Browsers will show security warnings - this is normal
echo 💡 Add certificate exception in browser for local development
echo.

echo ========================================
echo  Browser Setup Instructions
echo ========================================
echo.
echo 1. Chrome/Edge: Click "Advanced" → "Proceed to localhost (unsafe)"
echo 2. Firefox: Click "Advanced" → "Accept the Risk and Continue"
echo 3. Or import the certificate to your browser's trusted certificates
echo.

echo ========================================
echo  Hosts File Configuration
echo ========================================
echo.
echo Add these entries to your hosts file:
echo Location: C:\Windows\System32\drivers\etc\hosts
echo.
echo # DevOps Infrastructure Development
echo 127.0.0.1 auth.local keycloak.local
echo 127.0.0.1 git.local gitlab.local
echo 127.0.0.1 ci.local jenkins.local
echo 127.0.0.1 nexus.local artifacts.local
echo 127.0.0.1 storage.local minio.local
echo 127.0.0.1 rabbit.local rabbitmq.local
echo 127.0.0.1 prometheus.local metrics.local
echo 127.0.0.1 grafana.local dashboards.local
echo.

set /p "OPEN_HOSTS=Do you want to open the hosts file for editing? (y/N): "
if /i "!OPEN_HOSTS!" equ "y" (
    notepad C:\Windows\System32\drivers\etc\hosts
)

echo.
echo ✅ SSL setup complete! Your certificates are ready for development.
echo 🚀 You can now start the Docker services with HTTPS support.
echo.
pause
