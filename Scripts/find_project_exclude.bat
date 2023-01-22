@echo off
set old_path='%cd%'
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%old_path% -replace '\\((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)', ''"') do set path=%%i
set "jsonFile=%path%\config.json"

setlocal enabledelayedexpansion

set "ExcludeFolders="
if not exist %jsonFile% (
    set "ExcludeFolders=\b"
    echo !ExcludeFolders!
    exit /b
)

for /f "delims=" %%i in ('%1 -r ".ExcludeFolders[]" "%jsonFile%"') do (
    if defined ExcludeFolders (
        set "ExcludeFolders=!ExcludeFolders!,%%i"
    ) else (
        set "ExcludeFolders=%%i"
    )
)

if not defined ExcludeFolders (
    set "ExcludeFolders=\b"
)
echo %ExcludeFolders%