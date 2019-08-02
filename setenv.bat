@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXICODE%

rem ##########################################################################
rem ## Main

set _LLVM_PATH=
set _MSVC_PATH=
set _CMAKE_PATH=
set _MSBUILD_PATH=
set _GIT_PATH=

call :llvm
if not %_EXITCODE%==0 goto end

call :msvc
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

if "%~1"=="clean" call :clean

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
:args
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1 & goto args_done
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display environment settings
echo   Subcommands:
echo     help        display this help message
goto :eof

:llvm
where /q clang.exe
if %ERRORLEVEL%==0 goto :eof

if defined LLVM_HOME (
    set _LLVM_HOME=%LLVM_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable LLVM_HOME
) else (
    where /q clang.exe
    if !ERRORLEVEL!==0 (
        for /f "delims=" %%i in ('where /f clang.exe') do set _LLVM_BIN_DIR=%%~dpsi
        for %%f in ("!_LLVM_BIN_DIR!..") do set _LLVM_HOME=%%~sf
    ) else (
        set _PATH=C:\Progra~1
        for /f "delims=" %%f in ('dir /ad /b "!_PATH!\LLVM*" 2^>NUL') do set _LLVM_HOME=!_PATH!\%%f
        if not defined _LLVM_HOME (
           set _PATH=C:\opt
           for /f %%f in ('dir /ad /b "!_PATH!\LLVM*" 2^>NUL') do set _LLVM_HOME=!_PATH!\%%f
        )
        if defined _LLVM_HOME (
            if %_DEBUG%==1 echo [%_BASENAME%] Using default LLVM installation directory !_LLVM_HOME!
        )
    )
)
if not exist "%_LLVM_HOME%\bin\clang.exe" (
    echo Error: clang executable not found ^(%_LLVM_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_LLVM_PATH=;%_LLVM_HOME%\bin"
goto :eof

:msvc
where /q cl.exe
if %ERRORLEVEL%==0 goto :eof

if defined MSVC_HOME (
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable MSVC_HOME
    call :msvs_home "%_MSVC_HOME%"
    if not !_EXITCODE!==0 goto :eof
    set "__SEARCH_PATH=%MSVC_HOME%"
) else (
    call :msvs_home
    if not !_EXITCODE!==0 goto :eof
    set "__SEARCH_PATH=!_MSVS_HOME!"
)
if %_DEBUG%==1 echo [%_BASENAME%] __SEARCH_PATH=%__SEARCH_PATH%
set __MSVC_BIN_DIR=
set __MSVC_ARCH=x86\x86
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set __MSVC_ARCH=x64\x64
for /f "delims=" %%f in ('where /r "%__SEARCH_PATH%" cl.exe ^| findstr "%__MSVC_ARCH%"') do (
    for %%i in ("%%f") do set __MSVC_BIN_DIR=%%~dpsi
)
if not exist "%__MSVC_BIN_DIR%" (
    echo Error: Could not find Microsoft C/C++ compiler for architecture %__MSVC_ARCH% 1>&2
    set _EXITCODE=1
    goto :eof
)
for %%f in ("%__MSVC_BIN_DIR%\..\..\..") do set "_MSVC_HOME=%%~sf"
if %_DEBUG%==1 (
    echo [%_BASENAME%] _MSVS_HOME=%_MSVS_HOME%
    echo [%_BASENAME%] _MSVC_HOME=%_MSVC_HOME%
    echo [%_BASENAME%] __MSVC_BIN_DIR=%__MSVC_BIN_DIR%
)
set "__PATH=%_MSVS_HOME%\MSBuild\Current"
for /f "delims=" %%i in ('where /r "!__PATH!" msbuild.exe ^| findstr amd64') do set "__MSBUILD_BIN_DIR=%%~dpi"
set "_MSBUILD_PATH=;!__MSBUILD_BIN_DIR!"

set "__PATH=%_MSVS_HOME%\Common7\IDE\CommonExtensions\Microsoft\CMake"
for /f "delims=" %%i in ('where /r "!__PATH!" cmake.exe') do set "__CMAKE_BIN_DIR=%%~dpi"
set "_CMAKE_PATH=;!__CMAKE_BIN_DIR!"

set "_MSVC_PATH=;%__MSVC_BIN_DIR%"
goto :eof

rem output parameter: _MSVS_HOME
:msvs_home
set _MSVS_HOME=

set __MSVC_HOME=%~1
if defined __MSVC_HOME (
    for %%f in ("%__MSVC_HOME%\..\..\..") do set "_MSVS_HOME=%%~sf"
) else (
    set "__VSWHERE_CMD=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
    if not exist "!__VSWHERE_CMD!" (
        echo Error: Could not find any Microsoft Visual Studio installation 1>&2
        set _EXITCODE=1
        goto :eof
    )
    rem 15.x --> 2017, 16.x --> 2019
    for /f "delims=" %%f in ('"!__VSWHERE_CMD!" -property installationPath -version [16.0^,17.0^)') do set _MSVS_HOME=%%~sf
)
if not exist "%_MSVS_HOME%" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 2019 1>&2
    set _EXITCODE=1
    goto :eof
)
set __DRIVE_NAME=X:
set __SUBST_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    set __SUBST_PATH=%%h
    for %%f in ("%_MSVS_HOME%") do set __PATH=%%~sf
    if not "%%h"=="!__PATH!" (
        echo Warning: Drive %_DRIVE_NAME% already assigned to %%h
        goto :eof
    )
)
if not defined __SUBST_PATH (
    if %_DEBUG%==1 echo [%_BASENAME%] subst "%__DRIVE_NAME%" "%_MSVS_HOME%"
    subst "%__DRIVE_NAME%" "%_MSVS_HOME%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set _MSVS_HOME=%__DRIVE_NAME%
goto :eof

:git
where /q git.exe
if %ERRORLEVEL%==0 goto :eof

if defined GIT_HOME (
    set _GIT_HOME=%GIT_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GIT_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set _GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set _GIT_HOME=!__PATH!\%%f
        if not defined _GIT_HOME (
            set __PATH=C:\Progra~1
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set _GIT_HOME=!__PATH!\%%f
        )
    )
    if defined _GIT_HOME (
        if %_DEBUG%==1 echo [%_BASENAME%] Using default Git installation directory !_GIT_HOME!
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo Git executable not found ^(%_GIT_HOME%^)
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\usr\bin"
goto :eof

:clean
call :rmdir "%_ROOT_DIR%build"
goto :eof

:rmdir
set __DIR=%~1
if not exist "%__DIR%" goto :eof
if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "%__DIR%"
) else if %_VERBOSE%==1 ( echo Delete directory %__DIR%
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:print_env
set __VERBOSE=%1
set __VERSIONS_LINE1=
set __VERSIONS_LINE2=
set __VERSIONS_LINE3=
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
    echo Warning: lli executable not found in directory %_LLVM_HOME% 1>&2
    echo ^(LLVM installation directory needs additional binaries^) 1>&2
)
where /q opt.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('opt.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% opt %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% opt.exe
)
where /q cl.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-5,6,*" %%i in ('cl.exe 2^>^&1 ^| findstr version ^| findstr x64') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cl %%n,"
    set __WHERE_ARGS=%__WHERE_ARGS% cl.exe
)
where /q cmake.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('cmake.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cmake %%k"
    set __WHERE_ARGS=%__WHERE_ARGS% cmake.exe
)
where /q msbuild.exe
if %ERRORLEVEL%==0 (
    for /f %%i in ('msbuild.exe -version ^| findstr /b "[0-9]"') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% msbuild %%i,"
    set __WHERE_ARGS=%__WHERE_ARGS% msbuild.exe
)
where /q nmake.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-7,*" %%i in ('nmake.exe /? 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% nmake %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% nmake.exe
)
where /q git.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1,2,*" %%i in ('git.exe --version') do set __VERSIONS_LINE3=%__VERSIONS_LINE3% git %%k
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
echo Tool versions:
echo    %__VERSIONS_LINE1%
echo    %__VERSIONS_LINE2%
echo    %__VERSIONS_LINE3%
if %__VERBOSE%==1 (
    rem if %_DEBUG%==1 echo [%_BASENAME%] where %__WHERE_ARGS%
    echo Tool paths:
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if not defined LLVM_HOME set LLVM_HOME=%_LLVM_HOME%
    rem if not defined MSVS_HOME set MSVS_HOME=%_MSVS_HOME%
    if not defined MSVC_HOME set MSVC_HOME=%_MSVC_HOME%
    if not defined CMAKE_HOME set CMAKE_HOME=%_CMAKE_HOME%
    set "PATH=%PATH%%_LLVM_PATH%%_MSVC_PATH%%_MSBUILD_PATH%%_CMAKE_PATH%%_GIT_PATH%
    call :print_env %_VERBOSE%
    if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
