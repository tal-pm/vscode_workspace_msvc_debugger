@echo off
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)$'}).fullname) -join ' '"') do set includepath=%%i
for %%a in (dir /x "%includepath%") do set "includepath=%%~sa"
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)$'}).fullname) -join ' '"') do set objectpath=%%i
for %%a in (dir /x "%objectpath%") do set "objectpath=%%~sa"
for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((Get-ChildItem -Path ..\ -Directory | where {$_.name -match '^((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)$'}).fullname) -join ' '"') do set libpath=%%i
if defined libpath (
    for %%a in (dir /x "%libpath%") do set "libpath=%%~sa\*.lib"
)

set buildMode=%1
if not defined buildMode (
    @echo on
    echo "Err: No build mode specified: (options: 0-Build, 1-Rebuild, 2-LinkOnly)"
    exit /b
)
set "isRebuild="
if %buildMode%==0 set "isRebuild=/Gm"

set buildType=%2
if not defined buildType (
    @echo on
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


:: Convert the args for the exclude dirs to a comma separated string. ::
:GET_CONFIGS
    for /f "delims=" %%i in ('C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "'%includepath%' -replace '\\((?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)(?!.*(?:[Ss]ource(?:s)?|[Ss]rc(?:s)?)).*)|((?:[Bb]uild(?:s)?|[Bb]in(?:s)?)(?!.*(?:[Bb]uild(?:s)?|[Bb]in(?:s)?)).*)|((?:[Ii]nclude(?:s)?)(?!.*(?:[Ii]nclude(?:s)?)).*)|((?:[Rr]esource(?:s)?|[Rr]es)(?!.*(?:[Rr]esource(?:s)?|[Rr]es)).*)|((?:[Ll]ibraries|[Ll]ib(?:rary|s)?)(?!.*(?:[Ll]ibraries|[Ll]ib(?:rary|s)?)).*)', ''"') do set project_path=%%i
    set "jsonFile=%project_path%config.json"
    set "jq=%~dp0jq.exe"

    :GET_PROJECT_NAME
        for %%I in ("%project_path%") do set "folder=%%~nxI"
        
        for /f "delims=" %%i in ('%jq% -r ".ProjectName" "%jsonFile%"') do SET "fileBasenameNoExtension="%%i""
        if not defined fileBasenameNoExtension (
            set fileBasenameNoExtension="%folder%"
            @echo on
            echo "Project name is not defined: setting to default - %fileBasenameNoExtension:"=%"
            @echo off 
        )
            
        set fileBasenameNoExtension=%fileBasenameNoExtension:"=%

    :GET_DEBUG_MODE
        set "isDebug=/MD"
        set "linkDebug="

        for /f "delims=" %%i in ('%jq% -r ".DebugMode" "%jsonFile%"') do SET "DebugMode="%%i""
        if not defined DebugMode (
            set DebugMode="true"
            @echo on
            echo "Debug mode is not defined: setting to default - true"
            @echo off 
        )
        if %DebugMode%=="null" (
            set DebugMode="true"
            @echo on
            echo "Debug mode is not defined: setting to default - true"
            @echo off 
        )
        
        if %DebugMode%=="true" (
            set "isDebug=/MDd"
            set "linkDebug=/DEBUG"
        )

    :COMMAND_LINE_FLAGS
        setlocal enabledelayedexpansion
        set "cmd_flags="

        for /f "delims=" %%i in ('%jq% -r ".CommandLineFlags[]" "%jsonFile%"') do (
            if defined cmd_flags (
                set "cmd_flags=!cmd_flags! %%i"
            ) else (
                set "cmd_flags=%%i"
            )
        )

        if not defined cmd_flags (
            @echo on
            echo "Cmd flags is not defined: setting to default - []"
            @echo off 
        )
        endlocal&set "cmd_flags=%cmd_flags%"

    :GET_ADDITIONAL_INCLUDES
        setlocal enabledelayedexpansion
        set "additional_includes="

        for /f "delims=" %%i in ('%jq% -r ".AdditionalIncludes[]" "%jsonFile%"') do (
            if defined additional_includes (
                set "additional_includes=!additional_includes! -I "%%i""
            ) else (
                set "additional_includes=-I "%%i""
            )
        )

        if not defined additional_includes (
            @echo on
            echo "Additional includes is not defined: setting to default - []"
            @echo off 
        )
        endlocal&set "additional_includes=%additional_includes%"

    :GET_ADDITIONAL_LIBS
        setlocal enabledelayedexpansion
        set "additional_libs="

        for /f "delims=" %%i in ('%jq% -r ".AdditionalLibraries[]" "%jsonFile%"') do (
            if defined additional_libs (
                set "additional_libs=!additional_libs! /libpath:"%%i""
            ) else (
                set "additional_libs=/libpath:"%%i""
            )
        )

        if not defined additional_libs (
            @echo on
            echo "Additional libraries is not defined: setting to default - []"
            @echo off 
        )
        endlocal&set "additional_libs=%additional_libs%"

    :GET_ADDITIONAL_DEPENDENCIES
        setlocal enabledelayedexpansion
        set "additional_dependencies="

        for /f "delims=" %%i in ('%jq% -r ".AdditionalDependencies[]" "%jsonFile%"') do (
            if defined additional_dependencies (
                set "additional_dependencies=!additional_dependencies! "%%i""
            ) else (
                set "additional_dependencies="%%i""
            )
        )

        if not defined additional_dependencies (
            @echo on
            echo "Additional dependencies is not defined: setting to default - []"
            @echo off 
        )
        endlocal&set "additional_dependencies=%additional_dependencies%"

    :GET_EXCLUDE_FOLDERS
        setlocal enabledelayedexpansion
        set "excludeDirs="
        if not exist %jsonFile% (
            set "excludeDirs=\b"
        )

        for /f "delims=" %%i in ('%jq% -r ".ExcludeFolders[]" "%jsonFile%"') do (
            if defined excludeDirs (
                set "excludeDirs=!excludeDirs!,"%%i""
            ) else (
                set "excludeDirs="%%i""
            )
        )

        if not defined excludeDirs (
            set "excludeDirs=\b"
            @echo on
            echo "Exclude folders is not defined: setting to default - []"
            @echo off 
        )

:: Find all of the files in the source directory while excluding files in the excludeDirs. ::
:GET_FILES
    :: Remove wildcard characters from the excludeDirs as its problematic. ::
    for /f "tokens=*" %%* in ('
    "powershell -NoProfile -ExecutionPolicy Bypass -Command ""$env:excludeDirs"".replace('**','').replace('*','')"
    ') do set excludeDirs=%%*

    :: Find all of the files in the source directory while excluding folders in the excludeDirs. ::
    for /r %%f in ("*.cpp","*.c") do (
        set "check="
        for %%i in (!excludeDirs!) do (
            if "%%~dpf"==%%i (
                set "check=1"
                goto :break_loop
            ) else (
                echo "%%~dpf" | findstr /i /c:%%i > nul
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
                set result=!result! "%%~nxf"
            ) else (
                set result=!result! ".\!fpath!%%~nxf"
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
        @echo on
        echo Err: No code files found!
        exit /b
    )  
    
:COMPILE_&_LINK
:: Uncomment to see the full call to cl.exe (Used for debugging). ::
:: @echo on
if not %buildMode% EQU 2 (
    %compilerpath% && cl.exe /Zi %isDebug% /EHsc /nologo /I %includepath% %additional_includes% /Fo%objectpath%\ /Fd%objectpath%\ /ILK:%objectpath%\ /INCREMENTAL %isRebuild%%BuildFiles% %cmd_flags% /link /OUT:"%objectpath%\%fileBasenameNoExtension%.exe" /MANIFEST /NXCOMPAT /DYNAMICBASE "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" %libpath% /SUBSYSTEM:CONSOLE %linkDebug% /MACHINE:%MACHINE_TYPE% /LIBPATH:%LIB_VS% /LIBPATH:%LIB_SDK% %additional_libs% %additional_dependencies%
    exit /b
) else (
    cd %objectpath%
    %compilerpath% && link.exe /OUT:"%objectpath%\%fileBasenameNoExtension%.exe" /MANIFEST /NXCOMPAT /DYNAMICBASE "kernel32.lib" "user32.lib" "gdi32.lib" "winspool.lib" "comdlg32.lib" "advapi32.lib" "shell32.lib" "ole32.lib" "oleaut32.lib" "uuid.lib" "odbc32.lib" "odbccp32.lib" %libpath% /SUBSYSTEM:CONSOLE %linkDebug% /MACHINE:%MACHINE_TYPE% /LIBPATH:%LIB_VS% /LIBPATH:%LIB_SDK% %additional_libs% %additional_dependencies% %BuildFiles%
    exit /b
)

