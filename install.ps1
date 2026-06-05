# SAAS.GL - Instalador Automatico
# github.com/LeamibaSotnas/saasgl-install

Write-Host ""
Write-Host "  =================================" -ForegroundColor Cyan
Write-Host "   SAAS.GL - Sistema de Gestao" -ForegroundColor Cyan
Write-Host "   Instalador Automatico v1.0" -ForegroundColor Cyan
Write-Host "  =================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/6] Verificando Docker..." -ForegroundColor Yellow
try { docker --version | Out-Null; Write-Host "  OK - Docker encontrado!" -ForegroundColor Green }
catch { Write-Host "  ERRO - Instale o Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Red; pause; exit 1 }

Write-Host "[2/6] Verificando Docker Engine..." -ForegroundColor Yellow
try { docker ps | Out-Null; Write-Host "  OK - Docker rodando!" -ForegroundColor Green }
catch { Write-Host "  Iniciando Docker Desktop..." -ForegroundColor White; Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"; Start-Sleep 30 }

Write-Host "[3/6] Configurando HTTPS..." -ForegroundColor Yellow
$mkcertOk = $false
try { mkcert --version | Out-Null; $mkcertOk = $true } catch {}
if (-not $mkcertOk) { choco install mkcert -y | Out-Null }
mkcert -install
Write-Host "  OK - HTTPS configurado!" -ForegroundColor Green

Write-Host "[4/6] Gerando certificados SSL..." -ForegroundColor Yellow
$certsDir = Join-Path $PSScriptRoot "certs"
if (!(Test-Path $certsDir)) { New-Item -ItemType Directory -Path $certsDir | Out-Null }
Push-Location $certsDir
mkcert localhost 127.0.0.1 ::1
Pop-Location
if (Test-Path "$certsDir\localhost+2.pem") {
    Copy-Item "$certsDir\localhost+2.pem" ".\gateway-api\cert.pem" -Force
    Copy-Item "$certsDir\localhost+2-key.pem" ".\gateway-api\key.pem" -Force
    Copy-Item "$certsDir\localhost+2.pem" ".\frontend\cert.pem" -Force
    Copy-Item "$certsDir\localhost+2-key.pem" ".\frontend\key.pem" -Force
    Copy-Item "$certsDir\localhost+2.pem" ".\admin-panel\cert.pem" -Force
    Copy-Item "$certsDir\localhost+2-key.pem" ".\admin-panel\key.pem" -Force
    Write-Host "  OK - Certificados copiados!" -ForegroundColor Green
}

Write-Host "[5/6] Iniciando o sistema..." -ForegroundColor Yellow
Write-Host "  (Primeira vez pode demorar alguns minutos)" -ForegroundColor White
docker-compose up -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Sistema iniciado!" -ForegroundColor Green
} else {
    Write-Host "  ERRO - Falha ao iniciar!" -ForegroundColor Red
    pause; exit 1
}

Write-Host "[6/6] Configurando backup automatico..." -ForegroundColor Yellow
schtasks /Create /TN "SAASGL_Backup" /TR "$PSScriptRoot\backup.bat" /SC DAILY /ST 23:00 /RL HIGHEST /F | Out-Null
Write-Host "  OK - Backup agendado para 23:00!" -ForegroundColor Green

Write-Host ""
Write-Host "  =================================" -ForegroundColor Green
Write-Host "   SAAS.GL instalado com sucesso!" -ForegroundColor Green
Write-Host "  =================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Painel da Oficina: https://localhost:3000" -ForegroundColor Cyan
Write-Host "  Painel Admin:      https://localhost:3002" -ForegroundColor Cyan
Write-Host ""
Start-Sleep 3
Start-Process "https://localhost:3000"
pause