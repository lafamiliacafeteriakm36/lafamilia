@echo off
title BAJAR CAMBIOS DE GITHUB - LA FAMILIA
echo ===================================================
echo     BAJANDO ULTIMA VERSION DESDE GITHUB
echo ===================================================
echo.
cd /d "%~dp0"
git pull origin main
echo.
if %errorlevel% equ 0 (
    echo ===================================================
    echo  !ACTUALIZACION EXITOSA!
    echo  Tu sistema ya tiene los ultimos cambios.
    echo ===================================================
) else (
    echo ===================================================
    echo  Hubo un detalle. Intentando resolver...
    echo ===================================================
    git stash
    git pull origin main
)
pause
