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
set _PROJ_NAME=llvm-hello
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%_CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Debug
rem set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set _TARGET_DIR=%_ROOT_DIR%build
set _TARGET_EXE_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%

set _MAKE_CMD=make.exe
set _MAKE_OPTS=--quiet

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /m /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

set _PELOOK_CMD=pelook.exe
set _PELOOK_OPTS=

set _LLI_CMD=lli.exe
set _LLI_OPTS=

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

set _STDOUT_REDIRECT=1^>NUL
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>^&2

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
if %_TEST%==1 (
    call :test
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
rem output parameter(s): _CLEAN, _COMPILE, _RUN, _DEBUG, _TEST, _TOOLSET, _VERBOSE
:args
set _CLEAN=0
set _COMPILE=0
set _DUMP=0
set _RUN=0
set _DEBUG=0
set _HELP=0
set _TEST=0
set _TOOLSET=0
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
    if /i "%__ARG%"=="-cl" ( set _TOOLSET=0
    ) else if /i "%__ARG%"=="-clang" ( set _TOOLSET=1
    ) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-gcc" ( set _TOOLSET=2
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-msvc" ( set _TOOLSET=0
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo Error: Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    rem subcommand
    set /a __N=!__N!+1
    if /i "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if /i "%__ARG%"=="dump" ( set _COMPILE=1& set _DUMP=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else if /i "%__ARG%"=="test" ( set _COMPILE=1& set _RUN=1& set _TEST=1
    ) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto args_done
    )
)
shift
goto :args_loop
:args_done
if %_TOOLSET%==1 ( set _TOOLSET_NAME=Clang/GNU Make
) else if %_TOOLSET%==2 (  set _TOOLSET_NAME=GCC/GNU Make
) else ( set _TOOLSET_NAME=CL/MSBuild
)
if %_DEBUG%==1 echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _DUMP=%_DUMP% _RUN=%_RUN% _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -cl         use CL/MSBuild toolset (default)
echo     -clang      use Clang/GNU Make toolset instead of CL/MSBuild
echo     -debug      show commands executed by this script
echo     -gcc        use GCC/GNU Make toolset instead of CL/MSBuild
echo     -msvc       use CL/MSBuild toolset ^(alias for option -cl^)
echo     -verbose    display progress messages
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

:compile
setlocal
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
) else if %_VERBOSE%==1 ( echo Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
)
if %_TOOLSET%==1 ( call :compile_clang
) else if %_TOOLSET%==2 ( call :compile_gcc
) else ( call :compile_cl
)
rem save _EXITCODE value into parent environment
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
if %_DEBUG%==1 echo [%_BASENAME%] Current directory is: %CD% 1>&2

if %_DEBUG%==1 ( echo [%_BASENAME%] %__CMAKE_CMD% %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%__CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=v
) else ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=n
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_MAKE_CMD% %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call %_MAKE_CMD% %__MAKE_OPTS% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile_gcc
echo Error: GCC/GNU Make toolset not supported 1>&2
set _EXITCODE=1
goto :eof

:compile_cl
set "__CMAKE_CMD=%MSVS_CMAKE_CMD%"
set __CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated

if %_VERBOSE%==1 echo Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2

set LLVM_TARGET_TRIPLE=
for /f %%i in ('%LLVM_HOME%\bin\clang.exe -print-effective-triple') do set LLVM_TARGET_TRIPLE=%%i
if %_DEBUG%==1 echo [%_BASENAME%] LLVM_TARGET_TRIPLE=%LLVM_TARGET_TRIPLE% 1>&2

pushd "%_TARGET_DIR%"
if %_VERBOSE%==1 echo Current directory: %CD% 1>&2

if %_DEBUG%==1 ( echo [%_BASENAME%] cmake.exe %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%__CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_MSBUILD_CMD% %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
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

:dump
if not %_TOOLSET%==0 ( set __TARGET_DIR=%_TARGET_DIR%
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set __EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe
if not exist "%__EXE_FILE%" (
    echo Error: Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 (
    echo [%_BASENAME%] %_PELOOK_CMD% %_PELOOK_OPTS% !__EXE_FILE:%_ROOT_DIR%=! 1>&2
    call %_PELOOK_CMD% %_PELOOK_OPTS% "%__EXE_FILE%"
) else (
    if %_VERBOSE%==1 echo Dump PE/COFF infos for executable !__EXE_FILE:%_ROOT_DIR%=! 1>&2
    echo executable:           !__EXE_FILE:%_ROOT_DIR%=!
    call %_PELOOK_CMD% %_PELOOK_OPTS% "%__EXE_FILE%" | findstr "signature machine linkver modules"
)
if not %ERRORLEVEL%==0 (
    echo Error: Dump of executable %_PROJ_NAME%.exe failed 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
if not %_TOOLSET%==0 ( set __TARGET_DIR=%_TARGET_DIR%
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set __EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe
if not exist "%__EXE_FILE%" (
    echo Error: Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __LL_FILE=%_TARGET_DIR%\program.ll
pushd "%_TARGET_DIR%"

if %_DEBUG%==1 ( echo [%_BASENAME%] !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else ( echo Generate file !__LL_FILE:%_ROOT_DIR%=!
)
call "%__EXE_FILE%
if not %ERRORLEVEL%==0 (
    popd
    echo Error: Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:test
set __LL_FILE=%_TARGET_DIR%\program.ll
if not exist "%__LL_FILE%" (
    echo Error: File program.ll not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo [%_BASENAME%] %_LLI_CMD% %_LLI_OPTS% %__LL_FILE%! 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__LL_FILE:%_ROOT_DIR%=! with LLVM interpreter 1>&2
)
call %_LLI_CMD% %_LLI_OPTS% %__LL_FILE%
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
