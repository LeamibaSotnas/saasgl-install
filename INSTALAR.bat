@echo off
title SAAS.GL - Instalador
color 0A
echo.
echo  ===================================
echo   SAAS.GL - Sistema de Gestao
echo   Instalador Automatico v1.0
echo  ===================================
echo.

REM Verificar se Docker esta instalado
docker --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Docker nao encontrado!
    echo.
    echo Por favor instale o Docker Desktop antes de continuar:
    echo https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)
echo [OK] Docker encontrado!

REM Verificar se Docker esta rodando
docker ps >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [INFO] Iniciando Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Aguardando Docker iniciar (30 segundos)...
    timeout /t 30 /nobreak >nul
)
echo [OK] Docker rodando!

REM Instalar mkcert se nao existir
mkcert --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [INFO] Instalando mkcert para HTTPS...
    choco install mkcert -y >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo [AVISO] Chocolatey nao encontrado. Instalando...
        powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        choco install mkcert -y
    )
)
echo [OK] mkcert disponivel!

REM Instalar CA e gerar certificados
echo [INFO] Configurando certificados HTTPS...
mkcert -install >nul 2>&1
IF NOT EXIST "%~dp0certs\localhost+2.pem" (
    mkdir "%~dp0certs" 2>nul
    cd "%~dp0certs"
    mkcert localhost 127.0.0.1 ::1 >nul 2>&1
    cd "%~dp0"
)
echo [OK] Certificados configurados!

REM Copiar certificados
IF EXIST "%~dp0certs\localhost+2.pem" (
    copy /Y "%~dp0certs\localhost+2.pem" "%~dp0gateway-api\cert.pem" >nul
    copy /Y "%~dp0certs\localhost+2-key.pem" "%~dp0gateway-api\key.pem" >nul
    copy /Y "%~dp0certs\localhost+2.pem" "%~dp0frontend\cert.pem" >nul
    copy /Y "%~dp0certs\localhost+2-key.pem" "%~dp0frontend\key.pem" >nul
    copy /Y "%~dp0certs\localhost+2.pem" "%~dp0admin-panel\cert.pem" >nul
    copy /Y "%~dp0certs\localhost+2-key.pem" "%~dp0admin-panel\key.pem" >nul
)
echo [OK] Certificados copiados!

REM Subir os containers
echo.
echo [INFO] Iniciando o sistema (pode demorar alguns minutos na primeira vez)...
echo.
cd "%~dp0"
docker-compose up -d

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo  ===================================
    echo   SAAS.GL instalado com sucesso!
    echo  ===================================
    echo.
    echo  Acesse o sistema em:
    echo  - Painel da Oficina: https://localhost:3000
    echo  - Painel Admin:      https://localhost:3002
    echo.
    echo  O sistema inicia automaticamente com o Windows.
    echo  Backup automatico diario as 23:00.
    echo.
    REM Agendar backup automatico
    schtasks /Create /TN "SAASGL_Backup" /TR "%~dp0backup.bat" /SC DAILY /ST 23:00 /RL HIGHEST /F >nul 2>&1
    echo  [OK] Backup agendado!
    echo.
    REM Abrir o browser automaticamente
    timeout /t 5 /nobreak >nul
    start https://localhost:3000
) ELSE (
    echo.
    echo [ERRO] Falha ao iniciar o sistema!
    echo Verifique se o Docker esta funcionando corretamente.
)

echo.
pause