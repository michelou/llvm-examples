@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0
set "_ROOT_DIR=%~dp0"

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)
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
if %_TEST%==1 (
    call :test
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _PROJ_NAME, _PROJ_CONFIG, _PROJ_PLATFORM
:env
set _BASENAME=%~n0

@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:

set "__CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt"
if not exist "%__CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set _PROJ_NAME=llvm-hello
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%__CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Debug
@rem set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set "_TARGET_DIR=%_ROOT_DIR%build"
set "_TARGET_EXE_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"

set _MAKE_CMD=make.exe
set _MAKE_OPTS=--quiet

set _PELOOK_CMD=pelook.exe
set _PELOOK_OPTS=

set _LLI_CMD=lli.exe
set _LLI_OPTS=
goto :eof

@rem input parameter: %*
@rem output parameter(s): _CLEAN, _COMPILE, _RUN, _DEBUG, _TEST, _TOOLSET, _VERBOSE
:args
set _CLEAN=0
set _COMPILE=0
set _DUMP=0
set _RUN=0
set _HELP=0
set _TEST=0
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
    @rem option
    if /i "%__ARG%"=="-cl" ( set _TOOLSET=msvc
    ) else if /i "%__ARG%"=="-clang" ( set _TOOLSET=clang
    ) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-gcc" ( set _TOOLSET=gcc
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-msvc" ( set _TOOLSET=msvc
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if /i "%__ARG%"=="dump" ( set _COMPILE=1& set _DUMP=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else if /i "%__ARG%"=="test" ( set _COMPILE=1& set _RUN=1& set _TEST=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto :args_loop
:args_done
set _STDOUT_REDIRECT=1^>NUL
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>^&2

if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _DUMP=%_DUMP% _RUN=%_RUN% _TEST=%_TEST% _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -cl         use MSVC/MSBuild toolset ^(default^)
echo     -clang      use Clang/GNU Make toolset instead of MSVC/MSBuild
echo     -debug      show commands executed by this script
echo     -gcc        use GCC/GNU Make toolset instead of MSVC/MSBuild
echo     -msvc       use MSVC/MSBuild toolset ^(alias for option -cl^)
echo     -timer      display total elapsed time
echo     -verbose    display progress messages
echo.
echo   Subcommands:
echo     clean       delete generated files
echo     compile     generate executable
echo     dump        dump PE/COFF infos for generated executable
echo     help        display this help message
echo     run         run generated executable
echo     test        test generated executable
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

@rem input parameter: %1=directory path
:rmdir
set "__DIR=%~1"
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
call :compile_%_TOOLSET%

@rem save _EXITCODE value into parent environment
endlocal & set _EXITCODE=%_EXITCODE%
goto :eof

:compile_clang
set CC=clang.exe
set CXX=clang++.exe
set MAKE=make.exe
set RC=windres.exe

set "__CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe"
set __CMAKE_OPTS=-G "Unix Makefiles"

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is: %CD% 1>&2
) else if %_VERBOSE%==1 ( echo Current directory is: %CD% 1>&2
)
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
if %_DEBUG%==1 ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=v
) else ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=n
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MAKE_CMD% %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call %_MAKE_CMD% %__MAKE_OPTS% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile_gcc
echo %_ERROR_LABEL% GCC/GNU Make toolset not supported 1>&2
set _EXITCODE=1
goto :eof

set CC=gcc.exe
set CXX=g++.exe
set MAKE=make.exe
set RC=windres.exe
set "__CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe"
set __CMAKE_OPTS=-G "Unix Makefiles"

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is: %CD% 1>&2
) else if %_VERBOSE%==1 ( echo Current directory is: %CD% 1>&2
)
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
if %_DEBUG%==1 ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=v
) else ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=n
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MAKE_CMD% %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call %_MAKE_CMD% %__MAKE_OPTS% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:init_msvc
set _CMAKE_CMD=
for /f "delims=" %%f in ('where /r "%MSVS_HOME%" cmake.exe') do set "_CMAKE_CMD=%%f"
if not defined _CMAKE_CMD (
    echo %_ERROR_LABEL% Microsoft CMake tool not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set _MSBUILD_CMD=
for /f "delims=" %%f in ('where /r "%MSVS_HOME%" MSBuild.exe ^| findstr amd64') do set "_MSBUILD_CMD=%%f"
if not defined _MSBUILD_CMD (
    echo %_ERROR_LABEL% Microsoft MSBuild tool not found 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile_msvc
call :init_msvc
if not %_EXITCODE%==0 goto :eof

set __CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2
) else if %_VERBOSE%==1 ( echo Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2
)
set LLVM_TARGET_TRIPLE=
for /f %%i in ('%LLVM_HOME%\bin\clang.exe -print-effective-triple') do set LLVM_TARGET_TRIPLE=%%i
if %_DEBUG%==1 echo %_DEBUG_LABEL% LLVM_TARGET_TRIPLE=%LLVM_TARGET_TRIPLE% 1>&2

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 echo %_DEBUG_LABEL% Current directory is: %CD% 1>&2

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "!_CMAKE_CMD:%MSVS_HOME%\=!" %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_OPTS=/nologo /m /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "!_MSBUILD_CMD:%MSVS_HOME%\=!" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call "%_MSBUILD_CMD%" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:dump
if not %_TOOLSET%==msvc ( set __TARGET_DIR=%_TARGET_DIR%
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% %_PELOOK_CMD% %_PELOOK_OPTS% !__EXE_FILE:%_ROOT_DIR%=! 1>&2
    call %_PELOOK_CMD% %_PELOOK_OPTS% "%__EXE_FILE%"
) else (
    if %_VERBOSE%==1 echo Dump PE/COFF infos for executable !__EXE_FILE:%_ROOT_DIR%=! 1>&2
    echo executable:           !__EXE_FILE:%_ROOT_DIR%=!
    call %_PELOOK_CMD% %_PELOOK_OPTS% "%__EXE_FILE%" | findstr "signature machine linkver modules"
)
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Dump of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
if not %_TOOLSET%==msvc ( set "__TARGET_DIR=%_TARGET_DIR%"
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__LL_FILE=%_TARGET_DIR%\program.ll"
pushd "%_TARGET_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else ( echo Generate file !__LL_FILE:%_ROOT_DIR%=!
)
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:test
set "__LL_FILE=%_TARGET_DIR%\program.ll"
if not exist "%__LL_FILE%" (
    echo %_ERROR_LABEL% File program.ll not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_LLI_CMD% %_LLI_OPTS% %__LL_FILE%! 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__LL_FILE:%_ROOT_DIR%=! with LLVM interpreter 1>&2
)
call %_LLI_CMD% %_LLI_OPTS% %__LL_FILE%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

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
