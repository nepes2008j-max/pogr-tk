@echo off
rem  Harby operatiw demir yol dasamalaryny guramak - okuw diski
rem  Yerli web-serweri isledyar (2D/3D Flash modelleri ucin gerek).
cd /d "%~dp0"
set PORT=8777

rem --- 1. Python bar bolsa, sony ulanyas (in calt) ---
set PY=
py -3 --version >nul 2>&1 && set PY=py -3
if not defined PY python --version >nul 2>&1 && set PY=python

if defined PY (
  echo  Okuw diski isledilyar ... http://localhost:%PORT%/index.htm
  echo  Yapmak ucin su penjirani yapyn.
  start "" http://localhost:%PORT%/index.htm
  %PY% -m http.server %PORT% --bind 127.0.0.1
  exit /b
)

rem --- 2. Python yok: Windows-yn oz PowerShell-i bilen (Windows 7 SP1+) ---
rem     Skript diskden -Command arkaly okalyar, sonun ucin ulgamyn
rem     ExecutionPolicy sazlamasy uytgedilmeyar.
if exist "%~dp0SERWER.ps1" (
  powershell -NoProfile -Command "exit 0" >nul 2>&1
  if not errorlevel 1 (
    echo  Okuw diski isledilyar ... http://localhost:%PORT%/index.htm
    echo  Yapmak ucin su penjirani yapyn.
    start "" http://localhost:%PORT%/index.htm
    powershell -NoProfile -Command "$s=[IO.File]::ReadAllText('%~dp0SERWER.ps1'); $f=[ScriptBlock]::Create($s); & $f -Port %PORT%"
    exit /b
  )
)

rem --- 3. Ikisi hem yok: adaty gornusde acyas ---
echo.
echo  Serwer isledip bolmady - disk adaty gornusde acylyar.
echo  Ahli sahypalar we suratlar isleyar, yone 2D/3D modeller acylmaz.
echo.
start "" "index.htm"
pause
