# SAAS.GL - Instalador Automatico
# github.com/LeamibaSotnas/saasgl-install

Write-Host ""
Write-Host "  =================================" -ForegroundColor Cyan
Write-Host "   SAAS.GL - Sistema de Gestao" -ForegroundColor Cyan
Write-Host "   Instalador Automatico v1.0" -ForegroundColor Cyan
Write-Host "  =================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Docker
Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try { docker --version | Out-Null; Write-Host "  OK - Docker encontrado!" -ForegroundColor Green }
catch {
    Write-Host "  ERRO - Docker nao encontrado!" -ForegroundColor Red
    Write-Host "  Instale o Docker Desktop em: https://www.docker.com/products/docker-desktop" -ForegroundColor White
    pause; exit 1
}

# 2. Verificar se Docker esta rodando
Write-Host "[2/6] Verificando Docker Engine..." -ForegroundColor Yellow
try { docker ps | Out-Null; Write-Host "  OK - Docker rodando!" -ForegroundColor Green }
catch {
    Write-Host "  Iniciando Docker Desktop..." -ForegroundColor White
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Write-Host "  Aguardando 30 segundos..." -ForegroundColor White
    Start-Sleep 30
}

# 3. Instalar mkcert
Write-Host "[3/6] Configurando HTTPS..." -ForegroundColor Yellow
try {
    mkcert --version | Out-Null
    Write-Host "  OK - mkcert encontrado!" -ForegroundColor Green
} catch {
    Write-Host "  Instalando mkcert..." -ForegroundColor White
    choco install mkcert -y | Out-Null
}
mkcert -install 2>
Write-Host "  OK - Certificados HTTPS configurados!" -ForegroundColor Green

# 4. Gerar certificados
Write-Host "[4/6] Gerando certificados SSL..." -ForegroundColor Yellow
 = "C:\Users\SAAS.GL\certs"
if (!(Test-Path )) { New-Item -ItemType Directory -Path  | Out-Null }
Set-Location 
mkcert localhost 127.0.0.1 ::1 2>
Set-Location C:\Users\SAAS.GL

# Copiar certificados
if (Test-Path "\localhost+2.pem") {
    Copy-Item "\localhost+2.pem" ".\gateway-api\cert.pem" -Force
    Copy-Item "\localhost+2-key.pem" ".\gateway-api\key.pem" -Force
    Copy-Item "\localhost+2.pem" ".\frontend\cert.pem" -Force
    Copy-Item "\localhost+2-key.pem" ".\frontend\key.pem" -Force
    Copy-Item "\localhost+2.pem" ".\admin-panel\cert.pem" -Force
    Copy-Item "\localhost+2-key.pem" ".\admin-panel\key.pem" -Force
    Write-Host "  OK - Certificados copiados!" -ForegroundColor Green
}

# 5. Subir containers
Write-Host "[5/6] Iniciando o sistema..." -ForegroundColor Yellow
Write-Host "  (Primeira vez pode demorar alguns minutos)" -ForegroundColor White
docker-compose up -d
if ( -eq 0) {
    Write-Host "  OK - Sistema iniciado!" -ForegroundColor Green
} else {
    Write-Host "  ERRO - Falha ao iniciar o sistema!" -ForegroundColor Red
    pause; exit 1
}

# 6. Agendar backup
Write-Host "[6/6] Configurando backup automatico..." -ForegroundColor Yellow
schtasks /Create /TN "SAASGL_Backup" /TR "C:\Users\SAAS.GL\backup.bat" /SC DAILY /ST 23:00 /RL HIGHEST /F | Out-Null
Write-Host "  OK - Backup agendado para 23:00!" -ForegroundColor Green

Write-Host ""
Write-Host "  =================================" -ForegroundColor Green
Write-Host "   SAAS.GL instalado com sucesso!" -ForegroundColor Green
Write-Host "  =================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Acesse o sistema em:" -ForegroundColor White
Write-Host "  Painel da Oficina: https://localhost:3000" -ForegroundColor Cyan
Write-Host "  Painel Admin:      https://localhost:3002" -ForegroundColor Cyan
Write-Host ""
Write-Host "  O sistema inicia automaticamente com o Windows." -ForegroundColor White
Write-Host "  Backup automatico diario as 23:00." -ForegroundColor White
Write-Host ""

Start-Sleep 3
Start-Process "https://localhost:3000"
pause