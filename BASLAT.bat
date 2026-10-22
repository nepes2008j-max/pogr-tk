@echo off
rem  Harby operatiw demir yol dasamalaryny guramak - okuw diski
rem  Yerli web-serweri isledyar (2D/3D Flash modelleri ucin gerek).
cd /d "%~dp0"
set PORT=8777

set PY=
py -3 --version >nul 2>&1 && set PY=py -3
if not defined PY python --version >nul 2>&1 && set PY=python

if not defined PY (
  echo.
  echo  Python tapylmady - modeller isledip bolmaz.
  echo  Disk adaty gornusde acylyar; 2D/3D modeller ucin Python gerek:
  echo  https://www.python.org/downloads/  ^(gurnanynda "Add to PATH" bellan^)
  echo.
  start "" "index.htm"
  pause
  exit /b
)

echo  Okuw diski isledilyar ... http://localhost:%PORT%/index.htm
echo  Yapmak ucin su penjirani yapyn.
start "" http://localhost:%PORT%/index.htm
%PY% -m http.server %PORT% --bind 127.0.0.1
pause
