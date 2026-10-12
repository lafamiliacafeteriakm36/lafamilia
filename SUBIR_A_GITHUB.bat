@echo off
title SUBIR LA FAMILIA A GITHUB
echo ===================================================
echo     SUBIENDO SISTEMA LA FAMILIA A GITHUB
echo ===================================================
echo.
git push -u origin main
echo.
if %errorlevel% equ 0 (
    echo ===================================================
    echo  !SUBIDA EXITOSA A GITHUB!
    echo ===================================================
) else (
    echo ===================================================
    echo  Hubo un detalle con las credenciales de GitHub.
    echo ===================================================
)
pause
