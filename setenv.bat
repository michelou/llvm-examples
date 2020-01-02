@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

set _MSYS_PATH=
set _LLVM_PATH=
set _PYTHON_PATH=
set _GIT_PATH=

call :cmake
if not %_EXITCODE%==0 goto end

call :python
if not %_EXITCODE%==0 goto end

call :msys
if not %_EXITCODE%==0 goto end

call :llvm
if not %_EXITCODE%==0 goto end

rem call :msvs_2010
call :msvs
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set _WSWHERE_CMD=%_ROOT_DIR%bin\vswhere.exe
goto :eof

rem input parameter: %*
:args
set _BASH=0
set _HELP=0
set _LLVM_PREFIX=LLVM
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-bash" ( set _BASH=1
    ) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-llvm:8" ( set _LLVM_PREFIX=LLVM-8
    ) else if /i "%__ARG%"=="-llvm:9" ( set _LLVM_PREFIX=LLVM-9
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N+=1
    if /i "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo %_DEBUG_LABEL% _BASH=%_BASH% _HELP=%_HELP% _LLVM_PREFIX=%_LLVM_PREFIX% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -bash        start Git bash shell instead of Windows command prompt
echo     -debug       show commands executed by this script
echo     -llvm:^<8^|9^>  select version of LLVM installation 
echo     -verbose     display progress messages
echo.
echo   Subcommands:
echo     help         display this help message
goto :eof

rem output parameter(s): _CMAKE_HOME
:cmake
set _CMAKE_HOME=
rem set _CMAKE_PATH=

set __CMAKE_CMD=
for /f %%f in ('where cmake.exe 2^>NUL') do set "__CMAKE_CMD=%%f"
if defined __CMAKE_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of CMake executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__CMAKE_CMD%") do set __CMAKE_BIN_DIR=%%~dpi
    for %%f in ("!__CMAKE_BIN_DIR!..") do set _CMAKE_HOME=%%~sf
    rem keep _CMAKE_PATH undefined since executable already in path
    goto :eof
) else if defined CMAKE_HOME (
    set _CMAKE_HOME=%CMAKE_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable CMAKE_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    if not defined _CMAKE_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    )
)
if not exist "%_CMAKE_HOME%\bin\cmake.exe" (
    echo %_ERROR_LABEL% cmake executable not found ^(%_CMAKE_HOME%^) 1>&2
    set _CMAKE_HOME=
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_CMAKE_HOME%") do set _CMAKE_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default CMake installation directory %_CMAKE_HOME% 1>&2

rem set "_CMAKE_PATH=;%_CMAKE_HOME%\bin"
goto :eof

rem output parameter(s): _PYTHON_HOME, _PYTHON_PATH
:python
set _PYTHON_HOME=
set _PYTHON_PATH=

set __PYTHON_EXE=
for /f %%f in ('where python.exe 2^>NUL') do set "__PYTHON_EXE=%%f"
if defined __PYTHON_EXE (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Python executable found in PATH 1>&2
    rem keep _PYTHON_PATH undefined since executable already in path
    goto :eof
) else if defined PYTHON_HOME (
    set "_PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable PYTHON_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set _PYTHON_HOME=!__PATH!\Python
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        if not defined _PYTHON_HOME (
            set "__PATH=%_PROGRAM_FILES%"
            for /f %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_PYTHON_HOME%\python.exe" (
    echo %_ERROR_LABEL% Python executable not found ^(%_PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_PYTHON_HOME%\Scripts\pylint.exe" (
    echo %_ERROR_LABEL% Pylint executable not found ^(%_PYTHON_HOME^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_PYTHON_HOME%") do set _PYTHON_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Python installation directory %_PYTHON_HOME% 1>&2

set "_PYTHON_PATH=;%_PYTHON_HOME%;%_PYTHON_HOME%\Scripts"
goto :eof

rem output parameter(s): _MSYS_HOME, _MSYS_PATH
:msys
set _MSYS_HOME=
set _MSYS_PATH=

set __MAKE_EXE=
for /f %%f in ('where make.exe 2^>NUL') do set "__MAKE_EXE=%%f"
if defined __MAKE_EXE (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of GNU Make executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__MAKE_EXE%") do set __MAKE_BIN_DIR=%%~dpi
    for %%f in ("!__MAKE_BIN_DIR!..\..") do set _MSYS_HOME=%%~sf
    rem keep _MSYS_PATH undefined since executable already in path
    goto :eof
) else if defined MSYS_HOME (
    set _MSYS_HOME=%MSYS_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MSYS_HOME 1>&2
) else (
    set "__PATH=%_PROGRAM_FILES%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    if not defined _MSYS_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MSYS_HOME%\usr\bin\make.exe" (
    echo %_ERROR_LABEL% GNU Make executable not found ^(%_MSYS_HOME%^) 1>&2
    set _MSYS_HOME=
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_MSYS_HOME%") do set _MSYS_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default MSYS installation directory %_MSYS_HOME%

rem 1st path -> (make.exe, python.exe), 2nd path -> gcc.exe
set "_MSYS_PATH=;%_MSYS_HOME%\usr\bin;%_MSYS_HOME%\mingw64\bin"
goto :eof

rem output parameter(s): _LLVM_HOME, _LLVM_PATH
:llvm
set _LLVM_HOME=
set _LLVM_PATH=

set __CLANG_CMD=
for /f %%f in ('where clang.exe 2^>NUL') do set "__CLANG_CMD=%%f"
if defined __CLANG_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Clang executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__CLANG_CMD%") do set __LLVM_BIN_DIR=%%~dpi
    for %%f in ("!__LLVM_BIN_DIR!..") do set _LLVM_HOME=%%~sf
    rem keep _LLVM_PATH undefined since executable already in path
    goto :eof
) else if defined LLVM_HOME (
    set _LLVM_HOME=%LLVM_HOME%
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable LLVM_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%_LLVM_PREFIX%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    if not defined _LLVM_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\%_LLVM_PREFIX%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_LLVM_HOME%\bin\clang.exe" (
    echo %_ERROR_LABEL% clang executable not found ^(%_LLVM_HOME%^) 1>&2
    set _LLVM_HOME=
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default LLVM installation directory "%_LLVM_HOME%" 1>&2

set "_LLVM_PATH=;%_LLVM_HOME%\bin"
goto :eof

rem output paramters: _MSVC_HOME, _MSVS_HOME
rem Visual Studio 10
:msvs_2010
set _MSVC_HOME=
set _MSVS_HOME=

for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio 10.0") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __VC_BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__VC_BATCH_FILE=%%f"
if not exist "%__VC_BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
set _MSVC_HOME=%_MSVS_HOME%\VC
rem set __MSBUILD_HOME=
rem set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
rem for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
goto :eof

rem output parameters: _MSVC_HOME, _MSVC_HOME
rem Visual Studio 2017/2019
:msvs
set _MSVC_HOME=
set _MSVS_HOME=

set __MSVS_VERSION=2019
for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio\%__MSVS_VERSION%") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio %__MSVS_VERSION% 1>&2
    set _EXITCODE=1
    goto :eof
)
set __VC_BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__VC_BATCH_FILE=%%f"
if not exist "%__VC_BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%__VC_BATCH_FILE:Community=%"=="%__VC_BATCH_FILE%" ( set "_MSVC_HOME=%_MSVS_HOME%\BuildTools\VC"
) else ( set "_MSVC_HOME=%_MSVS_HOME%\Community\VC"
)
rem call :subst_path "%_MSVS_HOME%"
rem if not %_EXITCODE%==0 goto :eof
rem set "_MSVS_HOME=%_SUBST_PATH%"
goto :eof

rem input parameter: %1=directory path
rem output parameter: _SUBST_PATH
:subst_path
for %%f in (%~1) do set "_SUBST_PATH=%%f"

set __DRIVE_NAME=X:
set __ASSIGNED_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    if not "%%h"=="%_SUBST_PATH%" (
        echo %_WARNING_LABEL% Drive %__DRIVE_NAME% already assigned to %%h 1>&2
        goto :eof
    )
    set "__ASSIGNED_PATH=%%h"
)
if not defined __ASSIGNED_PATH (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%_SUBST_PATH%" 1>&2
    subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set _SUBST_PATH=%__DRIVE_NAME%
goto :eof

rem output parameter(s): _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for %%i in ("%__GIT_CMD%") do set __GIT_BIN_DIR=%%~dpsi
    for %%f in ("!__GIT_BIN_DIR!..") do set _GIT_HOME=%%~sf
    rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for %%f in ("!_GIT_HOME!\..") do set _GIT_HOME=%%~sf
    )
    rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_GIT_HOME%") do set _GIT_HOME=%%~sf
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory %_GIT_HOME% 1>&2

set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

:print_env
set __VERBOSE=%1
set __GIT_HOME=%~2
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set "__VERSIONS_LINE3=  "
set __WHERE_ARGS=
where /q clang.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('clang.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% clang %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% clang.exe
)
where /q lli.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('lli.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% lli %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% lli.exe
) else (
    echo %_WARNING_LABEL% lli executable not found in directory %_LLVM_HOME% 1>&2
    echo ^(LLVM installation directory needs additional binaries^) 1>&2
)
where /q opt.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('opt.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% opt %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% opt.exe
)
set "__CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe"
rem if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('%__CMAKE_CMD% --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cmake %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%CMAKE_HOME%\bin:cmake.exe"
rem )
where /q make.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('make.exe --version 2^>^&1 ^| findstr Make') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% make %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% make.exe
)
where /q gcc.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-7,*" %%i in ('gcc.exe --version 2^>^&1 ^| findstr gcc') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% gcc %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% gcc.exe
)
where /q python.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('python.exe --version 2^>^&1') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% python.exe
)
where /q diff.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,*" %%i in ('diff.exe --version ^| findstr diff') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% diff %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% diff.exe
)
where /q git.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('git.exe --version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% git %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
where /q "%__GIT_HOME%\bin":bash.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%__GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% bash %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% "%__GIT_HOME%\bin:bash.exe"
)
rem see https://github.com/Microsoft/vswhere/releases
where /q vswhere.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-4,5,*" %%i in ('vswhere -help ^| findstr /R /C:"version [0-9][0-9.+]*"') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% vswhere %%m"
    set __WHERE_ARGS=%__WHERE_ARGS% vswhere.exe
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
echo %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p 1>&2
)
if %__VERBOSE%==1 if defined MSVS_HOME (
    echo Environment variables: 1>&2
    echo    MSVC_HOME="%MSVC_HOME%" 1>&2
    echo    MSVS_HOME="%MSVS_HOME%" 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined CMAKE_HOME set "CMAKE_HOME=%_CMAKE_HOME%"
        if not defined LLVM_HOME set "LLVM_HOME=%_LLVM_HOME%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
        if not defined PYTHON_HOME set "PYTHON_HOME=%_PYTHON_HOME%"
        set "PATH=%PATH%%_PYTHON_PATH%%_MSYS_PATH%%_LLVM_PATH%%_GIT_PATH%"
        call :print_env %_VERBOSE% "%_GIT_HOME%"
        if %_BASH%==1 (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\usr\bin\bash.exe --login 1>&2
            cmd.exe /c "%_GIT_HOME%\usr\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
