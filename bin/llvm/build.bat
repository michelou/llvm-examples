@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
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

rem output parameter(s): _PROJ_NAME, _PROJ_CONFIG, _TARGET_DIR, _TARGET_OUTPUT_DIR
rem                      _MSBUILD_CMD, _MSBUILD_OPTS, _DEBUG_LABEL, _ERROR_LABEL
:env
rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set __CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt
if not exist "%__CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto end
)
set _PROJ_NAME=LLVM
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%__CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Debug
rem set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set _TARGET_DIR=%_ROOT_DIR%build
set _TARGET_OUTPUT_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

goto :eof

rem input parameter: %*
rem output parameter(s): _CLEAN, _COMPILE, _RUN, _DEBUG, _VERBOSE
:args
set _CLEAN=0
set _COMPILE=0
set _INSTALL=0
set _RUN=0
set _DEBUG=0
set _HELP=0
set _TIMER=0
set _TOOLSET=msvc
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N+=1
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="run" ( set _COMPILE=1 & set _RUN=1
    ) else if /i "%__ARG%"=="install" ( set _INSTALL=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto :args_loop
:args_done
set _STDOUT_REDIRECT=1^>NUL
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>CON

if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _TOOLSET=%_TOOLSET% _INSTALL=%_INSTALL% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      show commands executed by this script
echo     -timer      print total elapsed time
echo     -verbose    display progress messages
echo.
echo   Subcommands:
echo     clean       delete generated files
echo     compile     generate executable
echo     help        display this help message
echo     install     install files generated in directory !_TARGET_DIR:%_ROOT_DIR%=!
echo     run         run the generated executable
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

rem input parameter: %1=directory path
:rmdir
set __DIR=%~1
if not exist "!__DIR!\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "!__DIR!" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "!__DIR!"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
setlocal
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_TOOLSET%==clang ( set _TOOLSET_NAME=Clang/GNU Make
) else if %_TOOLSET%==gcc (  set _TOOLSET_NAME=GCC/GNU Make
) else ( set _TOOLSET_NAME=MSVC/MSBuild
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
) else if %_VERBOSE%==1 ( echo Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
)
call :compile_msvc

endlocal
goto :eof

:compile_msvc
set __PYTHON_CMD=%PYTHON_HOME%\python.exe
rem set "__CMAKE_CMD=%MSVS_CMAKE_CMD%"
set __CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe
set __CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated -DPYTHON_EXECUTABLE=%__PYTHON_CMD%

if %_VERBOSE%==1 echo Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 echo %_DEBUG_LABEL% Current directory is: %CD%

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %__CMAKE_CMD% %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%__CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MSBUILD_CMD% %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate LLVM executables ^(%_PROJ_NAME%.sln^) 1>&2
)
call %_MSBUILD_CMD% %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of LLVM executables failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:run
set __EXE_FILE=%_TARGET_OUTPUT_DIR%\bin\lli.exe
set __EXE_ARGS=--version
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable not found ^(!__EXE_FILE:%_ROOT_DIR%=!^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__EXE_FILE:%_ROOT_DIR%=! %__EXE_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=! %__EXE_ARGS% 1>&2
)
call "%__EXE_FILE%" %__EXE_ARGS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=
    goto :eof
)
goto :eof

rem input parameter(s): %1=source directory, %2=target directory, %3=exclude file, %4=recursive
:xcopy
set __SOURCE_DIR=%~1
set __TARGET_DIR=%~2
set __EXCLUDE_FILE=%~3
set __RECURSIVE=%~4

rem see https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/xcopy
rem option '/e' copies all subdirectories, even if they are empty.
rem option '/d' allows you to update files that have changed
if defined __RECURSIVE ( set __XCOPY_OPTS=/d /e /y
) else ( set __XCOPY_OPTS=/d /y
)
if exist "%__EXCLUDE_FILE%" set __XCOPY_OPTS=%__XCOPY_OPTS% /exclude:%__EXCLUDE_FILE%

if not exist "%__SOURCE_DIR%" (
    echo %_ERROR_LABEL% Directory !__SOURCE_DIR:%_ROOT_DIR%=! not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% xcopy %__XCOPY_OPTS% "%__SOURCE_DIR%" "%__TARGET_DIR%\" 1>&2
) else if %_VERBOSE%==1 ( echo Copy files from directory !__SOURCE_DIR:%_ROOT_DIR%=! to %__TARGET_DIR%\ 1>&2
)
xcopy %__XCOPY_OPTS% "%__SOURCE_DIR%" "%__TARGET_DIR%\" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:install
if not exist "%LLVM_HOME%" (
    echo %_ERROR_LABEL% LLVM installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
rem .ilk files ==> https://docs.microsoft.com/en-us/cpp/build/reference/dot-ilk-files-as-linker-input?view=vs-2019
set "__EXCLUDE_BIN=%_TARGET_DIR%\exclude_bin.txt"
echo BrainF> %__EXCLUDE_BIN%
echo BuildingAJIT-Ch>> %__EXCLUDE_BIN%
echo Fibonacci>> %__EXCLUDE_BIN%
echo Kaleidoscope-Ch>> %__EXCLUDE_BIN%
echo .ilk\>> %__EXCLUDE_BIN%
set "__EXCLUDE_NONE=%_TARGET_DIR%\exclude_none.txt"

call :xcopy "%_TARGET_OUTPUT_DIR%\bin" "%LLVM_HOME%\bin" "%__EXCLUDE_BIN%"
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_TARGET_OUTPUT_DIR%\lib" "%LLVM_HOME%\lib" "%__EXCLUDE_NONE%"
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_TARGET_DIR%\lib\cmake" "%LLVM_HOME%\lib\cmake" "%__EXCLUDE_NONE%" recursive
if not %_EXITCODE%==0 goto :eof

call :xcopy "%_ROOT_DIR%include" "%LLVM_HOME%\include" "%__EXCLUDE_NONE%" recursive
if not %_EXITCODE%==0 goto :eof

goto :eof

rem input parameter(s): %1=start time, %2=end time
rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
