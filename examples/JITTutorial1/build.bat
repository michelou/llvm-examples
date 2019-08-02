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
set _TARGET_DEBUG_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%

set _CMAKE_CMD=cmake.exe
set _CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated -DLLVM_INSTALL_DIR="%LLVM_HOME%"

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /m /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"
rem set _MSBUILD_OPTS=-nologo -property:Configuration=%_PROJ_CONFIG%;Platform="%_PROJ_PLATFORM%"

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
) else if /i "%__ARG%"=="run" ( set _COMPILE=1 & set _RUN=1
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
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _VERBOSE=%_VERBOSE%
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo Options:
echo   -debug      show commands executed by this script
echo   -verbose    display progress messages
echo Subcommands:
echo   clean       delete generated files
echo   compile     generate executable
echo   help        display this help message
echo   run         run executable
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

rem input parameter: %1=directory path
:rmdir
set __DIR=%~1
if not exist "!__DIR!\" goto :eof
if %_DEBUG%==1 ( echo [%_BASENAME%] rmdir /s /q "!__DIR!"
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!"
)
rmdir /s /q "!__DIR!"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:config
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_VERBOSE%==1 echo Project: %_PROJ_NAME%, Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM%

pushd "%_TARGET_DIR%"
if %_VERBOSE%==1 echo Current directory: %CD%

if %_DEBUG%==1 ( echo [%_BASENAME%] call %_CMAKE_CMD% %_CMAKE_OPTS% ..
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!"
)
call "%_CMAKE_CMD%" %_CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile
call :config
if not %_EXITCODE%==0 goto :eof

set "__SLN_FILE=%_TARGET_DIR%\%_PROJ_NAME%.sln"
if %_DEBUG%==1 ( echo [%_BASENAME%] call %_MSBUILD_CMD% %_MSBUILD_OPTS% "%__SLN_FILE%"
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe
)
call %_MSBUILD_CMD% %_MSBUILD_OPTS% "%__SLN_FILE%" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
set __EXE_FILE=%_TARGET_DEBUG_DIR%\%_PROJ_NAME%.exe
if not exist "%__EXE_FILE%" (
    echo Error: Executable not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] call !__EXE_FILE:%_ROOT_DIR%=!
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=!
)
call "%__EXE_FILE%
if not %ERRORLEVEL%==0 (
    echo Error: Execution status is %ERRORLEVEL% 1>&2
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
