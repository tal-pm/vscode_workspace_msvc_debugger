@echo off
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)$'}).fullname) -join ' '"') do set includepath=%%i
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)$'}).fullname) -join ' '"') do set objectpath=%%i
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)$'}).fullname) -join ' '"') do set libpath=%%i\*.lib

set fileBasenameNoExtension=%1
set buildMode=%2
if not defined buildMode (
    echo "Err: No build mode specified: (options: 0-Build, 1-Rebuild, 2-LinkOnly)"
    exit /b
)
set "isRebuild="
if %buildMode%==0 set "isRebuild=/Gm"

set buildType=%3
if not defined buildType (
    echo "Err: No build type specified: (options: 0-32bit, 1-64bit)"
    exit /b
)

:LOAD_COMPILER
    :: Compiler 2019 ::
    :: set compilerpath="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
    :: Libpath x64 2019 ::
    :: set LIB_VS="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\lib\x64 C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.29.30133\atlmfc\lib\x64 C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\VS\lib\x64"

    :: Compiler x64 2022 ::
    set compilerpath="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    :: Libpath x64 2022 ::
    set LIB_VS="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\lib\x64 C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\atlmfc\lib\x64 C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\VS\lib\x64"
    set LIB_SDK="C:\Program Files (x86)\Windows Kits\10\lib\10.0.22000.0\um\x64 C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\lib\um\x64"
    
    set MACHINE_TYPE="X64"

    :: Compiler x86 2022 ::
    if %buildType%==0 set compilerpath="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"
    :: Libpath x86 2022 ::
    if %buildType%==0 set LIB_VS="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\lib\x86 C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\atlmfc\lib\x86 C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\VS\lib\x86"
    if %buildType%==0 set LIB_SDK="C:\Program Files (x86)\Windows Kits\10\lib\10.0.22000.0\um\x86 C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\lib\um\x86"
    if %buildType%==0 set MACHINE_TYPE="X86"

:: Find all of the files in the source directory while excluding files in the excludeDirs arguments. ::
:GET_FILES
    :: Convert the args for the exclude dirs to a comma separated string. ::
    set "excludeDirs="
    shift
    shift
    shift
    :loop
    if "%1"=="" goto end
    if "%1"=="\b" goto end
    set "excludeDirs=%excludeDirs%,%1"
    shift
    goto loop
    :end
    set "excludeDirs=%excludeDirs:~1%"

    setlocal enabledelayedexpansion
    :: Remove wildcard characters from the excludeDirs as its problematic. ::
    for /f "tokens=*" %%* in ('
    "powershell -NoProfile -ExecutionPolicy Bypass -Command ""$env:excludeDirs"".replace('**','').replace('*','')"
    ') do set excludeDirs=%%*

    :: Find all of the files in the source directory while excluding folders in the excludeDirs. ::
    for /r %%f in (*.cpp,*.c) do (
        set "check="
        for %%i in (!excludeDirs!) do (
            if "%%~dpf"=="%%i" (
                set "check=1"
                goto :break_loop
            ) else (
                echo %%~dpf | findstr /i /c:"%%i" > nul
                if !errorlevel!==0 (
                    set "check=1"
                    goto :break_loop
                )
            )
        )
        :break_loop
        if not defined check (
            set "fpath=%%~dpf"
            set "fpath=!fpath:%cd%\=!"
            if %buildMode% EQU 2 (
                set result=!result! %%~nxf
            ) else (
                set result=!result! .\!fpath!%%~nxf
            )
        )
    )
    if %buildMode% EQU 2 (
        for /f "tokens=*" %%* in ('
        "powershell -NoProfile -ExecutionPolicy Bypass -Command ""$env:result"".replace('.cpp','.obj').replace('.c','.obj')"
        ') do set result=%%*
    )

    endlocal&set "BuildFiles=%result%"
    if not defined BuildFiles (
        echo Err: No code files found!
        exit /b
    )  

:COMPILE_&_LINK
:: Uncomment to see the full call to cl.exe (Used for debugging). ::
@echo on
if not %buildMode% EQU 2 (
    %compilerpath% && cl.exe /Zi /MDd /EHsc /nologo /I %includepath% /Fo%objectpath%\ /Fd%objectpath%\ /ILK:%objectpath%\ /INCREMENTAL %isRebuild%%BuildFiles% /link /OUT:%objectpath%\%fileBasenameNoExtension%.exe /MANIFEST /NXCOMPAT /DYNAMICBASE "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" %libpath% /SUBSYSTEM:CONSOLE /DEBUG /MACHINE:%MACHINE_TYPE% /LIBPATH:%LIB_VS% /LIBPATH:%LIB_SDK%
    exit /b
) 
else (
    cd %objectpath%
    %compilerpath% && link.exe /OUT:%objectpath%\%fileBasenameNoExtension%.exe /MANIFEST /NXCOMPAT /DYNAMICBASE "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" %libpath% /SUBSYSTEM:CONSOLE /DEBUG /MACHINE:%MACHINE_TYPE% /LIBPATH:%LIB_VS% /LIBPATH:%LIB_SDK% %BuildFiles%
    exit /b
)

