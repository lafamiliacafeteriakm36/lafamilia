@echo off
title Sistema La Familia
echo ===================================================
echo     INICIANDO SISTEMA LA FAMILIA
echo ===================================================
echo Por favor, no cierres esta ventana mientras uses el programa.
echo.

cd /d "%~dp0"

:: Esperar 2 segundos y abrir en el navegador
timeout /t 2 /nobreak >nul
start "" "http://localhost:5173"

:: Iniciar Vite con npm.cmd para evitar problemas de PowerShell
call npm.cmd run dev

pause
