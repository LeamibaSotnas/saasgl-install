@echo off
SET BACKUP_DIR=C:\Users\SAAS.GL\saas-multitenant\backups
SET DATA=%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%
SET DATA=%DATA: =0%
SET ARQUIVO=%BACKUP_DIR%\backup_%DATA%.sql

echo [%date% %time%] Iniciando backup...

REM Fazer dump do PostgreSQL
docker exec saas-multitenant-db-1 pg_dump -U postgres saas_db > "%ARQUIVO%"

IF %ERRORLEVEL% EQU 0 (
    echo [%date% %time%] Backup salvo: %ARQUIVO%
) ELSE (
    echo [%date% %time%] ERRO no backup!
)

REM Manter apenas os ultimos 7 backups
FOR /F "skip=7 delims=" %%F IN ('DIR "%BACKUP_DIR%\*.sql" /B /O-D') DO DEL "%BACKUP_DIR%\%%F"

echo [%date% %time%] Backup concluido!