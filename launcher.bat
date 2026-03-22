@echo off
set "scriptName=machinechaos.ps1"
set "folderName=Ryoiki-Tenkai-main"

if exist "%~dp0%scriptName%" (
    set "finalPath=%~dp0%scriptName%"
    goto launch
)

if exist "%~dp0%folderName%\%scriptName%" (
    set "finalPath=%~dp0%folderName%\%scriptName%"
    goto launch
)

for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-ChildItem -Path $env:USERPROFILE -Filter '%folderName%' -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -First 1).FullName"') do (
    set "finalPath=%%i\%scriptName%"
)

:launch
if defined finalPath (
    start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%finalPath%"
    exit
)

echo The domain could not be expanded. Ensure the folder is in your Downloads or Desktop.
pause