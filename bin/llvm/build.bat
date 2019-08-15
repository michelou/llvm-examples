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
set _PROJ_NAME=LLVM
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%_CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set _TARGET_DIR=%_ROOT_DIR%build
set _TARGET_OUTPUT_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%

set _CMAKE_CMD=cmake.exe
set _CMAKE_OPTS=-Thost=%_PROJ_PLATFORM%  -A %_PROJ_PLATFORM% -Wdeprecated

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

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
if %_INSTALL%==1 (
    call :install
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
set _INSTALL=0
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
) else if /i "%__ARG%"=="install" ( set _INSTALL=1
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
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _INSTALL=%_INSTALL% _VERBOSE=%_VERBOSE%
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
echo   install     install files generated in directory !_TARGET_DIR:%_ROOT_DIR%=!
echo   run         run the generated executable
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

:compile
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_VERBOSE%==1 echo Project: %_PROJ_NAME%, Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM%

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo [%_BASENAME%] %_CMAKE_CMD% %_CMAKE_OPTS% ..
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!"
)
call "%_CMAKE_CMD%" %_CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_MSBUILD_CMD% %_MSBUILD_OPTS% "%_PROJ_NAME%.sln"
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe
)
call %_MSBUILD_CMD% %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:run
set __EXE_FILE=%_TARGET_OUTPUT_DIR%\%_PROJ_NAME%.exe
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
    set _EXITCODE=
    goto :eof
)
goto :eof

rem input parameter(s): %1=source directory, %2=target directory, %3=recursive
:xcopy
set __SOURCE_DIR=%~1
set __TARGET_DIR=%~2
set __RECURSIVE=%~3

rem option '/e' copies all subdirectories, even if they are empty.
rem option '/d' allows you to update files that have changed
if defined __RECURSIVE ( set __XCOPY_OPTS=/d /e /y
) else ( set __XCOPY_OPTS=/d /y
)
if not exist "%__SOURCE_DIR%" (
    echo Error: Directory !__SOURCE_DIR:%_ROOT_DIR%=! not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] xcopy %__XCOPY_OPTS% "%__SOURCE_DIR%" "%__TARGET_DIR%\"
) else if %_VERBOSE%==1 ( echo Copy files from directory !__SOURCE_DIR:%_ROOT_DIR%=! to %__TARGET_DIR%\
)
xcopy %__XCOPY_OPTS% "%__SOURCE_DIR%" "%__TARGET_DIR%\" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:install
if not exist "%LLVM_HOME%" (
    echo Error: LLVM installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
call :xcopy "%_TARGET_OUTPUT_DIR%\bin" "%LLVM_HOME%\bin"
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_TARGET_OUTPUT_DIR%\lib" "%LLVM_HOME%\lib"
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_TARGET_DIR%\lib\cmake" "%LLVM_HOME%\lib\cmake" recursive
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_ROOT_DIR%include" "%LLVM_HOME%\include" recursive
if not %_EXITCODE%==0 goto :eof

goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
