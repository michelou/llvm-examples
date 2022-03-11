@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

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

@rem output parameters: _PROJ_NAME, _PROJ_CONFIG, _TARGET_DIR
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

set _DEBUG_LABEL=[%_BASENAME%]
set _ERROR_LABEL=Error:

set "_CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt"
if not exist "%_CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set _PROJ_NAME=scalevl
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%_CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set "_TARGET_DIR=%_ROOT_DIR%build"
set "_TARGET_EXE_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"

if not exist "%MSVS_CMAKE_HOME%\bin\cmake.exe" (
    echo %_ERROR_LABEL% Microsoft CMake installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MS_CMAKE_CMD=%MSVS_CMAKE_HOME%\bin\cmake.exe"

set _MSBUILD_CMD=
for /f "delims=" %%f in ('dir /b /s "%MSVS_HOME%\msbuild.exe" 2^>NUL') do set "_MSBUILD_CMD=%%f"
if not exist "%_MSBUILD_CMD%" (
   echo %_ERROR_LABEL% MSBuild installation directory not found 1>&2
   set _EXITCODE=1
   goto :eof
)
if not exist "%LLVM_HOME%\bin\opt.exe" (
    echo %_ERROR_LABEL% LLVM installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_LLVM_OPT_CMD=%LLVM_HOME%\bin\opt.exe"
goto :eof

@rem input parameter: %*
@rem output parameters: _CLEAN, _COMPILE, _RUN, _DEBUG, _VERBOSE
:args
set _CLEAN=0
set _COMPILE=0
set _RUN=0
set _HELP=0
set _TEST=0
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
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if "%__ARG%"=="help" ( set _HELP=1
    ) else if "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else if "%__ARG%"=="test" ( set _COMPILE=1& set _RUN=0& set _TEST=1
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
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>CON

if %_TOOLSET%==clang ( set _TOOLSET_NAME=Clang/CMake
) else if %_TOOLSET%==gcc (  set _TOOLSET_NAME=GCC/CMake
) else ( set _TOOLSET_NAME=MSVC/MSBuild
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% 1>&2
    echo %_DEBUG_LABEL% Variables  : "LLVM_HOME=%LLVM_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "MSVS_CMAKE_HOME=%MSVS_CMAKE_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "MSVS_HOME=%MSVS_HOME%" 1>&2
)
goto :eof

:help
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display progress messages
echo.
echo   Subcommands:
echo     clean       delete generated files
echo     compile     generate executable
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
if not exist "%__DIR%\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
setlocal
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_VERBOSE%==1 echo Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2

call :compile_%_TOOLSET%

endlocal
goto :eof

:compile_msvc
set __MS_CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated

if %_DEBUG%==1 echo %_DEBUG_LABEL% Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2

pushd "%_TARGET_DIR%"
if %_VERBOSE%==1 echo Current directory: "%CD%" 1>&2

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MS_CMAKE_CMD%" %__MS_CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_MS_CMAKE_CMD%" %__MS_CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_OPTS=/nologo /m /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MSBUILD_CMD%" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable "%_PROJ_NAME%.exe" 1>&2
)
call "%_MSBUILD_CMD%" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate executable "%_PROJ_NAME%.exe" 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:run
set "__EXE_FILE=%_TARGET_EXE_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable "%_PROJ_NAME%.exe" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Execute "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
)
goto :eof

:test
set "__EXE_FILE=%_TARGET_EXE_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable "%_PROJ_NAME%.exe" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__LL_FILE=%_TARGET_DIR%\%_PROJ_NAME%.ll"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__EXE_FILE:%_ROOT_DIR%=! ^> "%__LL_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Execute "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%__EXE_FILE%" > "%__LL_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=1
    goto :eof
)
set __LLVM_OPT_OPTS=-analyze -scalar-evolution

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_LLVM_OPT_CMD%" %__LLVM_OPT_OPTS% "%__LL_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Optimize IR code in file "!__LL_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_LLVM_OPT_CMD%" %__LLVM_OPT_OPTS% "%__LL_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to optimize IR code in file "!__LL_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
