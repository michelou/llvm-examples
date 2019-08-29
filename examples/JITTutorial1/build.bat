@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt
if not exist "%_CMAKE_LIST_FILE%" (
    echo Error: File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto end
)
set _PROJ_NAME=tut1
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%_CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set _TARGET_DIR=%_ROOT_DIR%build
set _TARGET_EXE_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%

set _CMAKE_CMD=%MSVS_CMAKE_CMD%
set _CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /m /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

set _PELOOK_CMD=pelook.exe
set _PELOOK_OPTS=

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

set _STDOUT_REDIRECT=1^>NUL
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>CON

rem ##########################################################################
rem ## Main

if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_COMPILE%==1 (
    call :compile
    if not !_EXITCODE!==0 goto end
)
if %_DUMP%==1 (
    call :dump
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output parameter(s): _CLEAN, _COMPILE, _RUN, _DEBUG, _VERBOSE
:args
set _CLEAN=0
set _COMPILE=0
set _DUMP=0
set _RUN=0
set _DEBUG=0
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1
) else if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
) else if /i "%__ARG%"=="dump" ( set _COMPILE=1& set _DUMP=1
) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-help" ( set _HELP=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _DUMP=%_DUMP% _RUN=%_RUN% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo Options:
echo   -debug      show commands executed by this script
echo   -verbose    display progress messages
echo Subcommands:
echo   clean       delete generated files
echo   compile     generate executable
echo   dump        dump PE/COFF infos for generated executable
echo   help        display this help message
echo   run         run generated executable
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

rem input parameter: %1=directory path
:rmdir
set __DIR=%~1
if not exist "!__DIR!\" goto :eof
if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "!__DIR!" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "!__DIR!"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:config
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_VERBOSE%==1 echo Project: %_PROJ_NAME%, Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2

pushd "%_TARGET_DIR%"
if %_VERBOSE%==1 echo Current directory: %CD% 1>&2

if %_DEBUG%==1 ( echo [%_BASENAME%] cmake.exe %_CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_CMAKE_CMD%" %_CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile
call :config
if not %_EXITCODE%==0 goto :eof

set "__SLN_FILE=%_TARGET_DIR%\%_PROJ_NAME%.sln"
if %_DEBUG%==1 ( echo [%_BASENAME%] %_MSBUILD_CMD% %_MSBUILD_OPTS% "%__SLN_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call %_MSBUILD_CMD% %_MSBUILD_OPTS% "%__SLN_FILE%" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    echo Error: Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:dump
set __EXE_FILE=%_TARGET_EXE_DIR%\%_PROJ_NAME%.exe
if not exist "%__EXE_FILE%" (
    echo Error: Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_PELOOK_CMD% %_PELOOK_OPTS% !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Dump PE/COFF infos for executable !__EXE_FILE:%_ROOT_DIR%=! 1>&2
)
echo executable:           !__EXE_FILE:%_ROOT_DIR%=!
call %_PELOOK_CMD% %_PELOOK_OPTS% "%__EXE_FILE%" | findstr "signature machine linkver modules"
if not %ERRORLEVEL%==0 (
    echo Error: Dump of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
set __EXE_FILE=%_TARGET_EXE_DIR%\%_PROJ_NAME%.exe
if not exist "%__EXE_FILE%" (
    echo Error: Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=! 1>&2
)
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    echo Error: Execution status is %ERRORLEVEL% 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
