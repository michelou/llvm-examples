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
if %_DOC%==1 (
    call :doc
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
set "_ROOT_DIR=%~dp0"

call :env_ansi
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%

set "__CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt"
if not exist "%__CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set _PROJ_NAME=tut2_main
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%__CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_CONFIG=Debug
@rem set _PROJ_CONFIG=Release
set _PROJ_PLATFORM=x64

set "_TARGET_DIR=%_ROOT_DIR%build"
set "_TARGET_DOCS_DIR=%_TARGET_DIR%\docs"
set "_TARGET_EXE_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"

set _MAKE_CMD=make.exe
set _MAKE_OPTS=

set _PELOOK_CMD=pelook.exe
set _PELOOK_OPTS=

set _LLVM_OBJDUMP_CMD=llvm-objdump.exe
set _LLVM_OBJDUMP_OPTS=-f -h

set "_CLANG_CMD=%LLVM_HOME%\bin\clang.exe"
set _CLANG_OPTS=
goto :eof

:env_ansi
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
set _DOC=0
set _DOC_OPEN=0
set _DUMP=0
set _RUN=0
set _TEST=0
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
    if /i "%__ARG%"=="-cl" ( set _TOOLSET=msvc
    ) else if /i "%__ARG%"=="-clang" ( set _TOOLSET=clang
    ) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-gcc" ( set _TOOLSET=gcc
    ) else if /i "%__ARG%"=="-help" ( set _HELP=1
    ) else if /i "%__ARG%"=="-msvc" ( set _TOOLSET=msvc
    ) else if /i "%__ARG%"=="-open" ( set _DOC_OPEN=1
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
    ) else if /i "%__ARG%"=="doc" ( set _DOC=1
    ) else if /i "%__ARG%"=="dump" ( set _COMPILE=1& set _DUMP=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else if /i "%__ARG%"=="test" ( set _COMPILE=1& set _RUN=0& set _TEST=1
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

if %_DOC_OPEN%==1 if %_DOC%==0 (
    echo %_WARNING_LABEL% Ignore option '-open' because subcommand 'doc' is not present 1>&2
    set _DOC_OPEN=0
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _DOC=%_DOC% _DUMP=%_DUMP% _RUN=%_RUN% _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
if %_TIMER%==1 for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
if %_VERBOSE%==1 (
    set __P_BEG=%_STRONG_FG_CYAN%%_UNDERSCORE%
    set __P_END=%_RESET%
    set __O_BEG=%_STRONG_FG_GREEN%
    set __O_END=%_RESET%
) else (
    set __P_BEG=
    set __P_END=
    set __O_BEG=
    set __O_END=
)
echo Usage: %_BASENAME% { ^<option^> ^| ^<subcommand^> }
echo.
echo   %__P_BEG%Options:%__P_END%
echo     %__O_BEG%-cl%__O_END%         use MSVC/MSBuild toolset ^(default^)
echo     %__O_BEG%-clang%__O_END%      use Clang/GNU Make toolset instead of MSVC/MSBuild
echo     %__O_BEG%-debug%__O_END%      show commands executed by this script
echo     %__O_BEG%-gcc%__O_END%        use GCC/GNU Make toolset instead of MSVC/MSBuild
echo     %__O_BEG%-msvc%__O_END%       use MSVC/MSBuild toolset ^(alias for option -cl^)
echo     %__O_BEG%-open%__O_END%       display generated HTML documentation ^(subcommand 'doc'^)
echo     %__O_BEG%-timer%__O_END%      display total elapsed time
echo     %__O_BEG%-verbose%__O_END%    display progress messages
echo.
echo   %__P_BEG%Subcommands:%__P_END%
echo     %__O_BEG%clean%__O_END%       delete generated files
echo     %__O_BEG%compile%__O_END%     generate executable
echo     %__O_BEG%doc%__O_END%         generate HTML documentation with Doxygen
echo     %__O_BEG%dump%__O_END%        dump PE/COFF infos for generated executable
echo     %__O_BEG%help%__O_END%        display this help message
echo     %__O_BEG%run%__O_END%         run generated executable
echo     %__O_BEG%test%__O_END%        test generated IR code
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
if %_DEBUG%==1 ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=v
) else ( set __MAKE_OPTS=%_MAKE_OPTS% --debug=n
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MAKE_CMD%" %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable %_PROJ_NAME%.exe 1>&2
)
call "%_MAKE_CMD%" %__MAKE_OPTS% %_STDOUT_REDIRECT%
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

:doc
@rem must be the same as property OUTPUT_DIRECTORY in file Doxyfile
if not exist "%_TARGET_DOCS_DIR%" (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% mkdir "%_TARGET_DOCS_DIR%" 1>&2
    mkdir "%_TARGET_DOCS_DIR%"
)
set "__DOXYFILE=%_ROOT_DIR%Doxyfile"
if not exist "%__DOXYFILE%" (
    echo %_ERROR_LABEL% Configuration file for Doxygen not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_DOXYGEN_CMD%" %_DOXYGEN_OPTS% "%__DOXYFILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate HTML documentation 1>&2
)
call "%_DOXYGEN_CMD%" %_DOXYGEN_OPTS% "%__DOXYFILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Generation of HTML documentation failed 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__INDEX_FILE=%_TARGET_DOCS_DIR%\html\index.html"
if %_DOC_OPEN%==1 (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% start "%_BASENAME%" "%__INDEX_FILE%" 1>&2
    ) else if %_VERBOSE%==1 ( echo Open HTML documentation in default browser 1>&2
    )
    start "%_BASENAME%" "%_TARGET_DOCS_DIR%\html\index.html"
)
goto :eof

:dump
if not %_TOOLSET%==msvc ( set "__TARGET_DIR=%_TARGET_DIR%"
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% "%_PELOOK_CMD%" %_PELOOK_OPTS% "%__EXE_FILE%" 1>&2
    call "%_PELOOK_CMD%" %_PELOOK_OPTS% "%__EXE_FILE%"
) else (
    if %_VERBOSE%==1 echo Dump PE/COFF infos for executable !__EXE_FILE:%_ROOT_DIR%=! 1>&2
    echo executable:           !__EXE_FILE:%_ROOT_DIR%=!
    call "%_PELOOK_CMD%" %_PELOOK_OPTS% "%__EXE_FILE%" | findstr "signature machine linkver modules"
)
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Dump of executable %_PROJ_NAME%.exe failed ^(PELook^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_LLVM_OBJDUMP_CMD% %_LLVM_OBJDUMP_OPTS% !__EXE_FILE:%_ROOT_DIR%=! 1>&2
) else if %_VERBOSE%==1 ( echo Dump PE/COFF infos for executable !__EXE_FILE:%_ROOT_DIR%=! 1>&2
)
call %_LLVM_OBJDUMP_CMD% %_LLVM_OBJDUMP_OPTS% "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% ObjDump dump of executable %_PROJ_NAME%.exe failed ^(ObjDump^) 1>&2
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
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Execute "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%__EXE_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test
if not %_TOOLSET%==msvc ( set "__TARGET_DIR=%_TARGET_DIR%"
) else ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_PROJ_NAME%.exe"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable %_PROJ_NAME%.exe not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__IR_OUTFILE=%_TARGET_DIR%\tut2.ll"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_FILE%" 1^> "%__IR_OUTFILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate IR code to file "!__IR_OUTFILE:%_ROOT_DIR%=!" 1>&2
)
call "%__EXE_FILE%" 1> %__IR_OUTFILE%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__EXE_OUTFILE=%_TARGET_DIR%\tut2.exe"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_CLANG_CMD%" %_CLANG_OPTS% -o "%__EXE_OUTFILE%" "%__IR_OUTFILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable from file !__IR_OUTFILE:%_ROOT_DIR%=! 1>&2
)
call "%_CLANG_CMD%" %_CLANG_OPTS% -o "%__EXE_OUTFILE%" "%__IR_OUTFILE%"
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_OUTFILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Execute !__EXE_OUTFILE:%_ROOT_DIR%=! 1>&2
)
call "%__EXE_OUTFILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Execution status is %ERRORLEVEL% 1>&2
)
goto :eof

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
