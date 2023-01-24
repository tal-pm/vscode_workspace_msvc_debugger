@echo off
set old_path='%cd%'
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%old_path% -replace '\\((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)|((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)|((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)|((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)|((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)', ''"') do set path=%%i
for %%I in ("%path%") do set "folder=%%~nxI"
set "jsonFile=%path%\config.json"

for /f "delims=" %%i in ('%1 -r ".ProjectName" "%jsonFile%"') do SET "ProjectName="%%i""
if not defined ProjectName (set ProjectName="%folder%")

if [%2]==[] goto OUTPUT_PROJECT_NAME
if /I "%2"=="/NoQuotes" (
    set ProjectName=%ProjectName:"=%
)

:OUTPUT_PROJECT_NAME
echo %ProjectName%