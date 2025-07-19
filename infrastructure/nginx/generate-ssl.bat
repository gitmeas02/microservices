@echo off
REM SSL Certificate Generation Script for Development Environment
REM This script generates self-signed SSL certificates for local development

setlocal enabledelayedexpansion

echo.
echo ========================================
echo  SSL Certificate Generator (Dev Mode)
echo ========================================
echo.

set "SSL_DIR=%~dp0ssl"
set "CERT_FILE=%SSL_DIR%\dev-cert.pem"
set "KEY_FILE=%SSL_DIR%\dev-key.pem"
set "CSR_FILE=%SSL_DIR%\dev-cert.csr"

REM Check if OpenSSL is available
where openssl >nul 2>&1
if !errorlevel! neq 0 (
    echo ❌ OpenSSL not found in PATH
    echo.
    echo Please install OpenSSL or use one of these alternatives:
    echo 1. Install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html
    echo 2. Use Git Bash (includes OpenSSL^)
    echo 3. Use WSL with OpenSSL installed
    echo 4. Use Docker to generate certificates
    echo.
    pause
    exit /b 1
)

echo ✅ OpenSSL found
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

echo 🔐 Generating SSL certificates for development...
echo.

REM Create certificate configuration
set "CONFIG_FILE=%SSL_DIR%\dev-cert.conf"
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
echo keyUsage = keyEncipherment, dataEncipherment
echo extendedKeyUsage = serverAuth
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

echo 📝 Created certificate configuration

REM Generate private key
echo 🔑 Generating private key...
openssl genrsa -out "%KEY_FILE%" 2048 2>nul
if !errorlevel! neq 0 (
    echo ❌ Failed to generate private key
    pause
    exit /b 1
)

REM Generate certificate signing request
echo 📄 Generating certificate signing request...
openssl req -new -key "%KEY_FILE%" -out "%CSR_FILE%" -config "%CONFIG_FILE%" 2>nul
if !errorlevel! neq 0 (
    echo ❌ Failed to generate CSR
    pause
    exit /b 1
)

REM Generate self-signed certificate
echo 📜 Generating self-signed certificate...
openssl x509 -req -in "%CSR_FILE%" -signkey "%KEY_FILE%" -out "%CERT_FILE%" -days 365 -extensions v3_req -extfile "%CONFIG_FILE%" 2>nul
if !errorlevel! neq 0 (
    echo ❌ Failed to generate certificate
    pause
    exit /b 1
)

REM Clean up temporary files
del "%CSR_FILE%" 2>nul
del "%CONFIG_FILE%" 2>nul

echo ✅ SSL certificates generated successfully!
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
echo ⏱️  Certificate Details:
openssl x509 -in "%CERT_FILE%" -text -noout | findstr /C:"Not Before" /C:"Not After" /C:"Subject:" /C:"DNS:" 2>nul
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
