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
if %_INSTALL%==1 (
    call :install
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _PROJ_NAME, _PROJ_CONFIG, _TARGET_DIR, _TARGET_OUTPUT_DIR
@rem                    _MSBUILD_CMD, _MSBUILD_OPTS, _DEBUG_LABEL, _ERROR_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

for /f "delims=" %%f in ('where /r "%MSVS_HOME%" vcvarsall.bat') do set "_VCVARSALL_FILE=%%f"
if not exist "%_VCVARSALL_FILE%" (
    echo %_ERROR_LABEL% Internal error ^(vcvarsall.bat not found^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt"
if not exist "%__CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto end
)
set _PROJ_NAME=LLVM
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%__CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
@rem set _PROJ_CONFIG=Debug
set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set "_TARGET_DIR=%_ROOT_DIR%build"
set "_TARGET_OUTPUT_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"

set _MSBUILD_CMD=msbuild.exe
set _MSBUILD_OPTS=/nologo /p:Configuration=%_PROJ_CONFIG% /p:Platform="%_PROJ_PLATFORM%"
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _RESET=[0m
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m
goto :eof

@rem input parameter: %*
@rem output parameter(s): _CLEAN, _COMPILE, _RUN, _DEBUG, _VERBOSE
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
    @rem option
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-timer" ( set _TIMER=1
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
    ) else if "%__ARG%"=="run" ( set _COMPILE=1 & set _RUN=1
    ) else if "%__ARG%"=="install" ( set _INSTALL=1
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

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _TIMER=%_TIMER% _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN% _INSTALL=%_INSTALL% 1>&2
    echo %_DEBUG_LABEL% Variables  : LLVM_HOME="%LLVM_HOME%" MSYS_HOME="%MSYS_HOME%" 1>&2
)
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%%_UNDERSCORE%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-debug%__END%      show commands executed by this script
echo     %__BEG_O%-timer%__END%      print total elapsed time
echo     %__BEG_O%-verbose%__END%    display progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%       delete generated files
echo     %__BEG_O%compile%__END%     generate executable
echo     %__BEG_O%help%__END%        display this help message
echo     %__BEG_O%install%__END%     install files generated in directory "%__BEG_O%!_TARGET_DIR:%_ROOT_DIR%=!%__END%"
echo     %__BEG_O%run%__END%         run the generated executable
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
call :compile_msvc

endlocal
goto :eof

:init_msvc
call "%_VCVARSALL_FILE%" amd64
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
set /a __SHOW_ALL=_DEBUG+_VERBOSE
if not %__SHOW_ALL%==0 (
    echo INCLUDE="%INCLUDE%" 1>&2
    echo LIB="%LIB%" 1>&2
)
goto :eof

:compile_msvc
call :init_msvc
if not %_EXITCODE%==0 goto :eof

set __PYTHON_CMD=%PYTHON_HOME%\python.exe
set __CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe
set __CMAKE_OPTS=-Thost=%_PROJ_PLATFORM% -A %_PROJ_PLATFORM% -Wdeprecated -DPYTHON_EXECUTABLE=%__PYTHON_CMD%
@rem see http://lists.llvm.org/pipermail/llvm-dev/2017-February/110590.html
set __CMAKE_OPTS=%__CMAKE_OPTS% -G "Visual Studio 16 2019"

if %_VERBOSE%==1 echo Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 echo %_DEBUG_LABEL% Current directory is: %CD%

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__CMAKE_CMD%" %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%__CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of build configuration failed 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MSBUILD_CMD%" %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate LLVM executables ^(%_PROJ_NAME%.sln^) 1>&2
)
call "%_MSBUILD_CMD%" %_MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Generation of LLVM executables failed 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:run
set "__EXE_FILE=%_TARGET_OUTPUT_DIR%\bin\lli.exe"
set __EXE_ARGS=--version
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable not found ^(!__EXE_FILE:%_ROOT_DIR%=!^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_FILE%" %__EXE_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_FILE:%_ROOT_DIR%=! %__EXE_ARGS% 1>&2
)
call "%__EXE_FILE%" %__EXE_ARGS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=
    goto :eof
)
goto :eof

@rem input parameter(s): %1=source directory, %2=target directory, %3=exclude file, %4=recursive
:xcopy
set __SOURCE_DIR=%~1
set __TARGET_DIR=%~2
set __EXCLUDE_FILE=%~3
set __RECURSIVE=%~4

@rem see https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/xcopy
@rem option '/e' copies all subdirectories, even if they are empty.
@rem option '/d' allows you to update files that have changed
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
set /p __INSTALL_ANSWER="Do really want to copy files from '%_ROOT_DIR%' to '%LLVM_HOME%\' (Y/N)? "
if not "%__INSTALL_ANSWER%"=="y" (
    echo Copy operation aborted
    goto :eof
)
@rem .ilk files ==> https://docs.microsoft.com/en-us/cpp/build/reference/dot-ilk-files-as-linker-input?view=vs-2019
set "__EXCLUDE_BIN=%_TARGET_DIR%\exclude_bin.txt"
(
    echo BrainF
    echo BuildingAJIT-Ch
    echo Fibonacci
    echo Kaleidoscope-Ch
    echo .ilk\
) > "%__EXCLUDE_BIN%"
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

@rem input parameter(s): %1=start time, %2=end time
@rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elapsed time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
