@echo off
rem ---------------------------------------------------------------
rem  Harby operatiw demir yol dasamalaryny guramak - okuw diski
rem  Bu fayl yerli web-serweri isledyar we brauzeri acyar.
rem  Dine seyle acylanda 2D/3D Flash modelleri hem isleyar.
rem ---------------------------------------------------------------
cd /d "%~dp0"
set PORT=8777
echo Okuw diski isledilyar ... http://localhost:%PORT%/index.htm
echo Yapmak ucin su penjiredin X duwmesine basyn.
start "" http://localhost:%PORT%/index.htm
python -m http.server %PORT% --bind 127.0.0.1
pause
