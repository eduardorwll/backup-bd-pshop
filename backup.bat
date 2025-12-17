@echo off
setlocal enabledelayedexpansion

:: Carrega variáveis do env.bat
CALL env.bat

set LOG_FILE=backup_databases_%timestamp%.log

echo ======================================= >> "%LOG_FILE%"
echo script iniciado: %DATE% %TIME% >> "%LOG_FILE%"
echo ======================================= >> "%LOG_FILE%"

set /a ERROS=0

for %%d in (%databases%) do (
    echo ------------------------------------------------------- >> "%LOG_FILE%"
    echo [%TIME%] Database: "%%d" >> "%LOG_FILE%"

    :: 1. BACKUP
    sqlcmd.exe -S localhost\SQLExpress -b -Q "BACKUP DATABASE %%d TO DISK='C:\Temp\%%d_%timestamp%.bak' WITH FORMAT" >> "%LOG_FILE%" 2>&1

    if !ERRORLEVEL! equ 0 (
        echo [%TIME%] SUCESSO: Backup de "%%d" gerado. >> "%LOG_FILE%"
        
        echo [%TIME%] comprimindo arquivo... >> "%LOG_FILE%"
        
        :: 2. COMPRESSÃO
        "c:\Program Files (x86)\7-Zip\7z.exe" a -t7z "C:\Temp\%%d_%timestamp%.7z" "C:\Temp\%%d_%timestamp%.bak" >> "%LOG_FILE%" 2>&1

        if !ERRORLEVEL! equ 0 (
            echo [%TIME%] SUCESSO: Arquivo 7z criado. >> "%LOG_FILE%"
            del "C:\Temp\%%d_%timestamp%.bak"
        ) else (
            echo [%TIME%] ERRO: Falha na compressao (7-zip) de "%%d". >> "%LOG_FILE%"
            set /a ERROS+=1
        )
    ) else (
        echo [%TIME%] ERRO CRITICO: Falha no processo de backup para "%%d". >> "%LOG_FILE%"
        set /a ERROS+=1
    )
)

echo. >> "%LOG_FILE%"
echo ======================================= >> "%LOG_FILE%"
if %ERROS% neq 0 (
    echo script finalizado com %ERROS% erro(s) em %DATE% as %TIME% >> "%LOG_FILE%"
) else (
    echo script finalizado com SUCESSO em %DATE% as %TIME% >> "%LOG_FILE%"
)
echo ======================================= >> "%LOG_FILE%"