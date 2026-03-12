@echo off
chcp 65001 >nul 2>&1
title U-Claw - Diagnostic Tool

set "UCLAW_DIR=%~dp0"
set "LOG_FILE=%UCLAW_DIR%diagnostic-log.txt"

echo.
echo   ========================================
echo     U-Claw Diagnostic Tool
echo     诊断工具
echo   ========================================
echo.
echo   Checking system... 正在检查系统...
echo.

REM Clear old log
echo U-Claw Diagnostic Report > "%LOG_FILE%"
echo Generated: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM 1. Check Node.js
echo [1/6] Checking Node.js runtime...
set "NODE_BIN=%UCLAW_DIR%app\runtime\node-win-x64\node.exe"
if exist "%NODE_BIN%" (
    echo   [OK] Node.js found >> "%LOG_FILE%"
    for /f "tokens=*" %%v in ('"%NODE_BIN%" --version 2^>^&1') do echo       Version: %%v >> "%LOG_FILE%"
    echo   ✓ Node.js: Found
) else (
    echo   [ERROR] Node.js not found >> "%LOG_FILE%"
    echo   [X] Node.js: NOT FOUND
    echo       Path: %NODE_BIN% >> "%LOG_FILE%"
)

REM 2. Check core-win directory
echo [2/6] Checking core-win directory...
set "CORE_DIR=%UCLAW_DIR%app\core-win"
if exist "%CORE_DIR%" (
    echo   [OK] core-win directory exists >> "%LOG_FILE%"
    echo   ✓ core-win: Found
) else (
    echo   [ERROR] core-win directory not found >> "%LOG_FILE%"
    echo   [X] core-win: NOT FOUND
)

REM 3. Check node_modules
echo [3/6] Checking dependencies...
if exist "%CORE_DIR%\node_modules" (
    echo   [OK] node_modules exists >> "%LOG_FILE%"
    echo   ✓ Dependencies: Found
) else (
    echo   [ERROR] node_modules not found >> "%LOG_FILE%"
    echo   [X] Dependencies: NOT FOUND
)

REM 4. Check OpenClaw
echo [4/6] Checking OpenClaw...
set "OPENCLAW_MJS=%CORE_DIR%\node_modules\openclaw\openclaw.mjs"
if exist "%OPENCLAW_MJS%" (
    echo   [OK] openclaw.mjs found >> "%LOG_FILE%"
    echo   ✓ OpenClaw: Found
) else (
    echo   [ERROR] openclaw.mjs not found >> "%LOG_FILE%"
    echo   [X] OpenClaw: NOT FOUND
    echo       Path: %OPENCLAW_MJS% >> "%LOG_FILE%"
)

REM 5. Check port availability
echo [5/6] Checking port 18789...
netstat -an | findstr ":18789 " | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 (
    echo   [WARNING] Port 18789 is in use >> "%LOG_FILE%"
    echo   ⚠ Port 18789: IN USE
    netstat -ano | findstr ":18789 " >> "%LOG_FILE%"
) else (
    echo   [OK] Port 18789 is available >> "%LOG_FILE%"
    echo   ✓ Port 18789: Available
)

REM 6. Test OpenClaw startup
echo [6/6] Testing OpenClaw startup...
echo. >> "%LOG_FILE%"
echo Testing OpenClaw startup: >> "%LOG_FILE%"
echo ---------------------------------------- >> "%LOG_FILE%"

set "OPENCLAW_HOME=%UCLAW_DIR%data"
set "OPENCLAW_STATE_DIR=%UCLAW_DIR%data\.openclaw"
set "OPENCLAW_CONFIG_PATH=%OPENCLAW_STATE_DIR%\openclaw.json"

if exist "%NODE_BIN%" if exist "%OPENCLAW_MJS%" (
    cd /d "%CORE_DIR%"
    "%NODE_BIN%" "%OPENCLAW_MJS%" --version >> "%LOG_FILE%" 2>&1
    if %errorlevel%==0 (
        echo   ✓ OpenClaw: Can run
    ) else (
        echo   [X] OpenClaw: Failed to run
        echo   [ERROR] OpenClaw failed to start >> "%LOG_FILE%"
    )
) else (
    echo   [X] Cannot test - files missing
    echo   [SKIP] Cannot test - required files missing >> "%LOG_FILE%"
)

echo.
echo. >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo Diagnostic complete. >> "%LOG_FILE%"

echo   ========================================
echo     Diagnostic Complete
echo   ========================================
echo.
echo   Log saved to: diagnostic-log.txt
echo.
echo   Next steps:
echo   1. Check diagnostic-log.txt for details
echo   2. If errors found, try running Windows-Start.bat
echo      to auto-install missing dependencies
echo.
pause
