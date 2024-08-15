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

for %%i in (%_COMMANDS%) do (
    call :%%i
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _PROJ_NAME, _PROJ_PLATFORM
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"
set _TIMER=0

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "__CMAKE_LIST_FILE=%_ROOT_DIR%CMakeLists.txt"
if not exist "%__CMAKE_LIST_FILE%" (
    echo %_ERROR_LABEL% File CMakeLists.txt not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set _PROJ_NAME=main
for /f "tokens=1,2,* delims=( " %%f in ('findstr /b project "%__CMAKE_LIST_FILE%" 2^>NUL') do set "_PROJ_NAME=%%g"
set _PROJ_PLATFORM=x64
set "_EXE_NAME=%_PROJ_NAME%.exe"

set "_SOURCE_DIR=%_ROOT_DIR%src"
set "_TARGET_DIR=%_ROOT_DIR%build"
set "_TARGET_DOCS_DIR=%_TARGET_DIR%\docs"

set _CMAKE_CMD=
if exist "%CMAKE_HOME%\bin\cmake.exe" (
    set "_CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe"
)
set _MSVS_CMAKE_CMD=
if exist "%MSVS_CMAKE_HOME%\bin\cmake.exe" (
    set "_MSVS_CMAKE_CMD=%MSVS_CMAKE_HOME%\bin\cmake.exe"
)
set _CPPCHECK_CMD=
if exist "%CPPCHECK_HOME%\cppcheck.exe" (
    set "_CPPCHECK_CMD=%CPPCHECK_HOME%\cppcheck.exe"
)
if not exist "%DOXYGEN_HOME%\doxygen.exe" (
    echo %_ERROR_LABEL% Doxygen installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_DOXYGEN_CMD=%DOXYGEN_HOME%\doxygen.exe"

if not exist "%MSYS_HOME%\usr\bin\make.exe" (
    echo %_ERROR_LABEL% MSYS installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MAKE_CMD=%MSYS_HOME%\usr\bin\make.exe"
set "_WINDRES_CMD=%MSYS_HOME%\mingw64\bin\windres.exe"

if not exist "%LLVM_HOME%\bin\clang.exe" (
    echo %_ERROR_LABEL% LLVM installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_CLANG_CMD=%LLVM_HOME%\bin\clang.exe"
set "_CLANGXX_CMD=%LLVM_HOME%\bin\clang++.exe"

if not exist "%MSVS_HOME%\Community\MSBuild\Current\Bin\amd64\MSBuild.exe" (
    echo %_ERROR_LABEL% MSBuild installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSBUILD_CMD=%MSVS_HOME%\Community\MSBuild\Current\Bin\amd64\MSBuild.exe"

set "_PELOOK_CMD=%_ROOT_DIR%bin\pelook.exe"

@rem we use the newer PowerShell version if available
where /q pwsh.exe
if %ERRORLEVEL%==0 ( set _PWSH_CMD=pwsh.exe
) else ( set _PWSH_CMD=powershell.exe
)
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd

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

@rem we define _RESET in last position to avoid crazy console output with type command
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m
set _RESET=[0m
goto :eof

@rem input parameter: %*
@rem output parameters: _COMMANDS, _DEBUG, _TOOLSET, _VERBOSE
:args
set _COMMANDS=
set _CPP_STD=c++14
set _DOC_OPEN=0
set _PROJ_CONFIG=Release
set _TOOLSET=msvc
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _COMMANDS=help
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-cl" ( set _TOOLSET=msvc
    ) else if "%__ARG%"=="-clang" ( set _TOOLSET=clang
    ) else if "%__ARG%"=="-config:D" ( set _PROJ_CONFIG=Debug
    ) else if "%__ARG%"=="-config:R" ( set _PROJ_CONFIG=Release
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-gcc" ( set _TOOLSET=gcc
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-msvc" ( set _TOOLSET=msvc
    ) else if "%__ARG%"=="-open" ( set _DOC_OPEN=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _COMMANDS=!_COMMANDS! clean
    ) else if "%__ARG%"=="compile" ( set _COMMANDS=!_COMMANDS! compile
    ) else if "%__ARG%"=="doc" ( set _COMMANDS=!_COMMANDS! doc
    ) else if "%__ARG%"=="dump" ( set _COMMANDS=!_COMMANDS! compile dump
    ) else if "%__ARG%"=="help" ( set _COMMANDS=help
    ) else if "%__ARG%"=="lint" ( set _COMMANDS=!_COMMANDS! lint
    ) else if "%__ARG%"=="run" ( set _COMMANDS=!_COMMANDS! compile run
    ) else if "%__ARG%"=="test" ( set _COMMANDS=!_COMMANDS! compile run test
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
set _STDOUT_REDIRECT=1^>NUL
if %_DEBUG%==1 set _STDOUT_REDIRECT=1^>^&2

if not "%_COMMANDS:lint=%"=="%_COMMANDS%" if not defined _CPPCHECK_CMD (
    echo %_WARNING_LABEL% Cppcheck installation not found 1>&2
    set _COMMANDS=%_COMMANDS:lint=%
)
if %_DOC_OPEN%==1 if "%_COMMANDS:doc=%"=="%_COMMANDS%" (
    echo %_WARNING_LABEL% Ignore option '-open' because subcommand 'doc' is not present 1>&2
    set _DOC_OPEN=0
)
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _CPP_STD=%_CPP_STD% _TOOLSET=%_TOOLSET% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: %_COMMANDS% 1>&2
    echo %_DEBUG_LABEL% Variables  : "DOXYGEN_HOME=%DOXYGEN_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "LLVM_HOME=%LLVM_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "MSVS_HOME=%MSVS_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "MSYS_HOME=%MSYS_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : _PROJ_CONFIG=%_PROJ_CONFIG% 1>&2
)
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%
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
echo     %__BEG_O%-cl%__END%            use MSVC/MSBuild toolset ^(default^)
echo     %__BEG_O%-clang%__END%         use Clang/GNU Make toolset instead of MSVC/MSBuild
echo     %__BEG_O%-config:^(D^|R^)%__END%  use %__BEG_O%D%__END%^)ebug or %__BEG_O%R%__END%^)elease ^(default^) configuration
echo     %__BEG_O%-debug%__END%         print commands executed by this script
echo     %__BEG_O%-gcc%__END%           use GCC/GNU Make toolset instead of MSVC/MSBuild
echo     %__BEG_O%-msvc%__END%          use MSVC/MSBuild toolset ^(alias for option %__BEG_O%-cl%__END%^)
echo     %__BEG_O%-open%__END%          display generated HTML documentation ^(subcommand %__BEG_O%doc%__END%^)
echo     %__BEG_O%-verbose%__END%       print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%          delete generated files
echo     %__BEG_O%compile%__END%        generate executable ^(default config: %__BEG_O%Release%__END%^)
echo     %__BEG_O%doc%__END%            generate HTML documentation with %__BEG_N%Doxygen%__END%
echo     %__BEG_O%dump%__END%           dump PE/COFF infos for generated executable
echo     %__BEG_O%help%__END%           print this help message
echo     %__BEG_O%lint%__END%           analyze C++ source files with %__BEG_N%Cppcheck%__END%
echo     %__BEG_O%run%__END%            run generated executable "%__BEG_O%%_EXE_NAME%%__END%"
goto :eof

:clean
if exist "%_ROOT_DIR%CMakeCache.txt" del "%_ROOT_DIR%CMakeCache.txt"
call :rmdir "%_ROOT_DIR%CMakeFiles"
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
    echo %_ERROR_LABEL% Failed to delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:lint
if %_TOOLSET%==gcc ( set __CPPCHECK_OPTS=--template=gcc --std=%_CPP_STD%
) else if %_TOOLSET%==msvc ( set __CPPCHECK_OPTS=--template=vs --std=%_CPP_STD%
) else ( set __CPPCHECK_OPTS=--std=%_CPP_STD%
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_CPPCHECK_CMD%" %__CPPCHECK_OPTS% "%_SOURCE_DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Analyze C++ source files in directory "!_SOURCE_DIR=%_ROOT_DIR%=!" 1>&2
)
call "%_CPPCHECK_CMD%" %__CPPCHECK_OPTS% "%_SOURCE_DIR%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Found errors while analyzing C++ source files in directory "!_SOURCE_DIR=%_ROOT_DIR%=!" 1>&2
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
set "LLVM_DIR=%LLVM_HOME%\lib\cmake\llvm"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
) else if %_VERBOSE%==1 ( echo Toolset: %_TOOLSET_NAME%, Project: %_PROJ_NAME% 1>&2
)
call :compile_%_TOOLSET%

@rem save _EXITCODE value into parent environment
endlocal & set _EXITCODE=%_EXITCODE%
goto :eof

:compile_clang
set "CC=%_CLANG_CMD%"
set "CXX=%_CLANGXX_CMD%"
set "MAKE=%_MAKE_CMD%"
set "RC=%_WINDRES_CMD%"

set __CMAKE_OPTS=-G "Unix Makefiles"

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is: "%CD%" 1>&2
) else if %_VERBOSE%==1 ( echo Current directory is: "%CD%" 1>&2
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_CMAKE_CMD%" %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( set __MAKE_OPTS=--debug=v
) else ( set __MAKE_OPTS=--debug=n
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MAKE_CMD%" %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable "%_EXE_NAME%" 1>&2
)
call "%_MAKE_CMD%" %__MAKE_OPTS% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate executable "%_EXE_NAME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile_gcc
set "CC=%MSYS_HOME%\mingw64\bin\gcc.exe"
set "CXX=%MSYS_HOME%\mingw64\bin\g++.exe"
set "MAKE=%_MAKE_CMD%"
set "RC=%_WINDRES_CMD%"

set __CMAKE_OPTS=-G "Unix Makefiles"

pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is: "%CD%" 1>&2
) else if %_VERBOSE%==1 ( echo Current directory is: "%CD%" 1>&2
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_CMAKE_CMD%" %__CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_CMAKE_CMD%" %__CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( set __MAKE_OPTS=--debug=v
) else ( set __MAKE_OPTS=--debug=n
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_MAKE_CMD%" %__MAKE_OPTS% 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable "%_EXE_NAME%" 1>&2
)
call "%_MAKE_CMD%" %__MAKE_OPTS% %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate executable "%_EXE_NAME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile_msvc
set __MSVS_CMAKE_OPTS="-Thost=%_PROJ_PLATFORM%" -A %_PROJ_PLATFORM% -Wdeprecated

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2
) else if %_VERBOSE%==1 ( echo Configuration: %_PROJ_CONFIG%, Platform: %_PROJ_PLATFORM% 1>&2
)
pushd "%_TARGET_DIR%"
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Current directory is: "%CD%" 1>&2
) else if %_VERBOSE%==1 ( echo Current directory is: "%CD%" 1>&2
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "!_MSVS_CMAKE_CMD:%MSVS_HOME%=%%MSVS_HOME%%!" %__MSVS_CMAKE_OPTS% .. 1>&2
) else if %_VERBOSE%==1 ( echo Generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_MSVS_CMAKE_CMD%" %__MSVS_CMAKE_OPTS% .. %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate configuration files into directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_OPTS=-nologo -m -property:"Configuration=%_PROJ_CONFIG%" -property:"Platform=%_PROJ_PLATFORM%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "!_MSBUILD_CMD:%MSVS_HOME%=%%MSVS_HOME%%!" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" 1>&2
) else if %_VERBOSE%==1 ( echo Generate executable "%_EXE_NAME%" 1>&2
)
call "%_MSBUILD_CMD%" %__MSBUILD_OPTS% "%_PROJ_NAME%.sln" %_STDOUT_REDIRECT%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to generate executable "%_EXE_NAME%" 1>&2
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
set __DOXYGEN_OPTS=-s

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_DOXYGEN_CMD%" %__DOXYGEN_OPTS% "%__DOXYFILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Generate HTML documentation into directory "!_TARGET_DOCS_DIR:%_ROOT_DIR%=!" 1>&2
)
call "%_DOXYGEN_CMD%" %__DOXYGEN_OPTS% "%__DOXYFILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to generate HTML documentation into directory "!_TARGET_DOCS_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__INDEX_FILE=%_TARGET_DOCS_DIR%\html\index.html"
if %_DOC_OPEN%==1 (
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% start "%_BASENAME%" "%__INDEX_FILE%" 1>&2
    ) else if %_VERBOSE%==1 ( echo Open HTML documentation in default browser 1>&2
    )
    start "%_BASENAME%" "%__INDEX_FILE%"
)
goto :eof

:dump
if %_TOOLSET%==msvc ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
) else ( set "__TARGET_DIR=%_TARGET_DIR%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_EXE_NAME%"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable "%_EXE_NAME%" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __PELOOK_OPTS=

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% "%_PELOOK_CMD%" %__PELOOK_OPTS% "%__EXE_FILE%" 1>&2
    call "%_PELOOK_CMD%" %__PELOOK_OPTS% "%__EXE_FILE%"
) else (
    if %_VERBOSE%==1 echo Dump PE/COFF infos for executable "!__EXE_FILE:%_ROOT_DIR%=!" 1>&2
    echo executable:           !__EXE_FILE:%_ROOT_DIR%=!
    call "%_PELOOK_CMD%" %__PELOOK_OPTS% "%__EXE_FILE%" | findstr "signature machine linkver modules"
)
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to dump executable "%_EXE_NAME%" ^(PELook^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run
if %_TOOLSET%==msvc ( set "__TARGET_DIR=%_TARGET_DIR%\%_PROJ_CONFIG%"
) else ( set "__TARGET_DIR=%_TARGET_DIR%"
)
set "__EXE_FILE=%__TARGET_DIR%\%_EXE_NAME%"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable "%_EXE_NAME%" not found 1>&2
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
echo nyi
goto :eof

@rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('call "%_PWSH_CMD%" -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('call "%_PWSH_CMD%" -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total execution time: !_DURATION! 1>&2
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
