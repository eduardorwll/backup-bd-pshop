@echo off

setlocal enabledelayedexpansion
set LOG_FILE=backup_databases_%timestamp%.log

CALL env.bat

echo ======================================= >> "%LOG_FILE%"
echo Script iniciado: %DATE% %TIME% >> "%LOG_FILE%"
echo ======================================= >> "%LOG_FILE%"

REM Contador de erros
set /a ERROS=0

for %%d in (%databases%) do (
    echo ------------------------------------------------------- >> "%LOG_FILE%"
    echo Iniciando backup da database: "%%d" >> "%LOG_FILE%"

    sqlcmd.exe -S localhost\SQLExpress -Q "BACKUP DATABASE %%d TO DISK='C:\Temp\%%d_%timestamp%.bak' WITH FORMAT" 2>> "%LOG_FILE%"

    if !ERRORLEVEL! equ 0 (
        echo [%TIME%] SUCESSO: Backup de "%%d" concluido >> "%LOG_FILE%"
    ) else (
        echo [%TIME%] ERRO !ERRORLEVEL!: Falha no backup de "%%d" >> "%LOG_FILE%"
        set /a ERROS+=1
    )
)

for %%d in (%databases%) do (
    echo ------------------------------------------------------- >> "%LOG_FILE%"
    echo Iniciando compressão do backup da database: "%%d" >> "%LOG_FILE%"

    "c:\Program Files (x86)\7-Zip\7z.exe" a -t7z C:\Temp\"%%d_%timestamp%".7z C:\Temp\"%%d_%timestamp%".bak

    if !ERRORLEVEL! equ 0 (
        echo [%TIME%] SUCESSO: Compressão do backup de "%%d" concluido >> "%LOG_FILE%"

        del C:\Temp\"%%d_%timestamp%".bak
    ) else (
        echo [%TIME%] ERRO !ERRORLEVEL!: Falha na compressão do backup de "%%d" >> "%LOG_FILE%"
        set /a ERROS+=1
    )
)
