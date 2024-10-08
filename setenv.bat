@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging
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

set _CMAKE_PATH=
set _MSYS_PATH=
set _GIT_PATH=

call :cmake
if not %_EXITCODE%==0 goto end

call :doxygen
if not %_EXITCODE%==0 goto end

call :python
if not %_EXITCODE%==0 goto end

call :msys
if not %_EXITCODE%==0 goto end

call :llvm
if not %_EXITCODE%==0 goto end

@rem call :msvs_2010
call :msvs
@rem if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :winsdk 10
if not %_EXITCODE%==0 goto end

goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

set _LLVM_PREFIX_DEFAULT=LLVM-16

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:
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
@rem output parameters: _BASH, _HELP, _VERBOSE
:args
set _BASH=0
set _HELP=0
set _LLVM_PREFIX=%_LLVM_PREFIX_DEFAULT%
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-bash" ( set _BASH=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-llvm:8" ( set _LLVM_PREFIX=LLVM-8
    ) else if "%__ARG%"=="-llvm:9" ( set _LLVM_PREFIX=LLVM-9
    ) else if "%__ARG%"=="-llvm:10" ( set _LLVM_PREFIX=LLVM-10
    ) else if "%__ARG%"=="-llvm:11" ( set _LLVM_PREFIX=LLVM-11
    ) else if "%__ARG%"=="-llvm:12" ( set _LLVM_PREFIX=LLVM-12
    ) else if "%__ARG%"=="-llvm:13" ( set _LLVM_PREFIX=LLVM-13
    ) else if "%__ARG%"=="-llvm:14" ( set _LLVM_PREFIX=LLVM-14
    ) else if "%__ARG%"=="-llvm:15" ( set _LLVM_PREFIX=LLVM-15
    ) else if "%__ARG%"=="-llvm:16" ( set _LLVM_PREFIX=LLVM-16
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
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
call :drive_name "%_ROOT_DIR%"
if not %_EXITCODE%==0 goto :eof

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _BASH=%_BASH% _LLVM_PREFIX=%_LLVM_PREFIX% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _HELP=%_HELP% 1>&2
    echo %_DEBUG_LABEL% Variables  : _DRIVE_NAME=%_DRIVE_NAME% 1>&2
)
goto :eof

@rem input parameter: %1: path to be substituted
@rem output parameter: _DRIVE_NAME (2 characters: letter + ':')
:drive_name
set "__GIVEN_PATH=%~1"
@rem remove trailing path separator if present
if "%__GIVEN_PATH:~-1,1%"=="\" set "__GIVEN_PATH=%__GIVEN_PATH:~0,-1%"

@rem https://serverfault.com/questions/62578/how-to-get-a-list-of-drive-letters-on-a-system-through-a-windows-shell-bat-cmd
set __DRIVE_NAMES=F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:
for /f %%i in ('wmic logicaldisk get deviceid ^| findstr :') do (
    set "__DRIVE_NAMES=!__DRIVE_NAMES:%%i=!"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(WMIC^) 1>&2
if not defined __DRIVE_NAMES (
    echo %_ERROR_LABEL% No more free drive name 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "tokens=1,2,*" %%f in ('subst') do (
    set "__SUBST_DRIVE=%%f"
    set "__SUBST_DRIVE=!__SUBST_DRIVE:~0,2!"
    set "__SUBST_PATH=%%h"
    @rem Windows local file systems are not case sensitive (by default)
    if /i "!__SUBST_DRIVE!"=="!__GIVEN_PATH:~0,2!" (
        set _DRIVE_NAME=!__SUBST_DRIVE:~0,2!
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    ) else if "!__SUBST_PATH!"=="!__GIVEN_PATH!" (
        set "_DRIVE_NAME=!__SUBST_DRIVE!"
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    )
)
for /f "tokens=1,2,*" %%i in ('subst') do (
    set __USED=%%i
    call :drive_names "!__USED:~0,2!"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(SUBST^) 1>&2

set "_DRIVE_NAME=!__DRIVE_NAMES:~0,2!"
if /i "%_DRIVE_NAME%"=="%__GIVEN_PATH:~0,2%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% subst "%_DRIVE_NAME%" "%__GIVEN_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo Assign drive %_DRIVE_NAME% to path "!__GIVEN_PATH:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
)
subst "%_DRIVE_NAME%" "%__GIVEN_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to assign drive %_DRIVE_NAME% to path "!__GIVEN_PATH:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: %1=Used drive name
@rem output parameter: __DRIVE_NAMES
:drive_names
set "__USED_NAME=%~1"
set "__DRIVE_NAMES=!__DRIVE_NAMES:%__USED_NAME%=!"
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
echo     %__BEG_O%-bash%__END%          start Git bash shell instead of Windows command prompt
echo     %__BEG_O%-debug%__END%         print commands executed by this script
echo     %__BEG_O%-llvm:^<8..15^>%__END%  select version of LLVM installation ^(default: %__BEG_N%%_LLVM_PREFIX_DEFAULT%%__END%^)
echo     %__BEG_O%-verbose%__END%       print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%           print this help message
goto :eof

@rem output parameters: _CMAKE_HOME, _CMAKE_PATH
:cmake
set _CMAKE_HOME=
set _CMAKE_PATH=

set __CMAKE_CMD=
for /f "delims=" %%f in ('where cmake.exe 2^>NUL') do set "__CMAKE_CMD=%%f"
if defined __CMAKE_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of CMake executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__CMAKE_CMD%") do set "__CMAKE_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__CMAKE_BIN_DIR!") do set "_CMAKE_HOME=%%~dpf"
    @rem keep _CMAKE_PATH undefined since executable already in path
    goto :eof
) else if defined CMAKE_HOME (
    set "_CMAKE_HOME=%CMAKE_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable CMAKE_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    if not defined _CMAKE_HOME (
        set __PATH=C:\opt
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    )
)
if not exist "%_CMAKE_HOME%\bin\cmake.exe" (
    echo %_ERROR_LABEL% cmake executable not found ^(%_CMAKE_HOME%^) 1>&2
    set _CMAKE_HOME=
    set _EXITCODE=1
    goto :eof
)
set "_CMAKE_PATH=;%_CMAKE_HOME%\bin"
goto :eof

@rem output parameter: _DOXYGEN_HOME
:doxygen
set _DOXYGEN_HOME=

set __DOXYGEN_CMD=
for /f %%f in ('where doxygen.exe 2^>NUL') do set "__DOXYGEN_CMD=%%f"
if defined __DOXYGEN_CMD (
    for /f "delims=" %%i in ("%__DOXYGEN_CMD%") do set "_DOXYGEN_HOME=%%~dpi"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Doxygen executable found in PATH 1>&2
) else if defined DOXY_HOME (
    set "_DOXYGEN_HOME=%DOXY_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable DOXY_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\doxygen\" ( set "_DOXYGEN_HOME=!__PATH!\doxygen"
    ) else (
        set __PATH=C:\opt
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\doxygen-*" 2^>NUL') do set "_DOXYGEN_HOME=!__PATH!\%%f"
        if not defined _DOXYGEN_HOME (
            set "__PATH=%ProgramFiles%"
           for /f "delims=" %%f in ('dir /ad /b "!__PATH!\doxygen-*" 2^>NUL') do set "_DOXYGEN_HOME=!__PATH!\%%f"
        )
    )
    if defined _DOXYGEN_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Doxygen installation directory "!_DOXYGEN_HOME!" 1>&2
    )
)
if not exist "%_DOXYGEN_HOME%\doxygen.exe" (
    echo %_ERROR_LABEL% Doxygen executable not found ^("%_DOXYGEN_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameter: _PYTHON_HOME
:python
set _PYTHON_HOME=

set __PYTHON_CMD=
for /f "delims=" %%f in ('where python.exe 2^>NUL') do set "__PYTHON_CMD=%%f"
if defined __PYTHON_CMD if not "!__PYTHON_CMD:WindowsApps=!"=="%__PYTHON_CMD%" (
    echo %_WARNING_LABEL% Ignore Microsoft installed Python in PATH 1>&2
    set __PYTHON_CMD=
)
if defined __PYTHON_CMD (
    for /f "delims=" %%i in ("%__PYTHON_CMD%") do set "_PYTHON_HOME=%%~dpi"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Python executable found in PATH 1>&2
    goto :eof
) else if defined PYTHON_HOME (
    set "_PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable PYTHON_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set "_PYTHON_HOME=!__PATH!\Python"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        if not defined _PYTHON_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "_PYTHON_HOME=!__PATH!\%%f"
        )
    )
    if defined _PYTHON_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Python installation directory "!_PYTHON_HOME!" 1>&2
    )
)
if not exist "%_PYTHON_HOME%\python.exe" (
    echo %_ERROR_LABEL% Python executable not found ^(%_PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%_PYTHON_HOME%\Scripts\pylint.exe" (
    echo %_WARNING_LABEL% Pylint executable not found ^(%_PYTHON_HOME%^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    @rem set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameters: _MSYS_HOME, _MSYS_PATH
:msys
set _MSYS_HOME=
set _MSYS_PATH=

set __MAKE_CMD=
for /f "delims=" %%f in ('where make.exe 2^>NUL') do set "__MAKE_CMD=%%f"
if defined __MAKE_CMD (
    for /f "delims=" %%i in ("%__MAKE_CMD%") do set "__MAKE_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__MAKE_BIN_DIR!\.") do set "_MSYS_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of GNU Make executable found in PATH 1>&2
    @rem keep _MSYS_PATH undefined since executable already in path
    goto :eof
) else if defined MSYS_HOME (
    set "_MSYS_HOME=%MSYS_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MSYS_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    if not defined _MSYS_HOME (
        set __PATH=C:\opt
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MSYS_HOME%\usr\bin\make.exe" (
    echo %_ERROR_LABEL% GNU Make executable not found ^("%_MSYS_HOME%"^) 1>&2
    set _MSYS_HOME=
    set _EXITCODE=1
    goto :eof
)
@rem 1st path -> (make.exe, python.exe), 2nd path -> gcc.exe
set "_MSYS_PATH=;%_MSYS_HOME%\usr\bin;%_MSYS_HOME%\mingw64\bin"
goto :eof

@rem output parameter: _LLVM_HOME
:llvm
set _LLVM_HOME=

set __CLANG_CMD=
for /f "delims=" %%f in ('where clang.exe 2^>NUL') do set "__CLANG_CMD=%%f"
if defined __CLANG_CMD (
    for /f "delims=" %%i in ("%__CLANG_CMD%") do set "__LLVM_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__LLVM_BIN_DIR!\.") do set "_LLVM_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Clang executable found in PATH 1>&2
    goto :eof
) else if defined LLVM_HOME (
    set "_LLVM_HOME=%LLVM_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable LLVM_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%_LLVM_PREFIX%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    if not defined _LLVM_HOME (
        set __PATH=C:\opt
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%_LLVM_PREFIX%*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_LLVM_HOME%\bin\clang.exe" (
    echo %_ERROR_LABEL% clang executable not found ^("%_LLVM_HOME%"^) 1>&2
    set _LLVM_HOME=
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default LLVM installation directory "%_LLVM_HOME%" 1>&2

@rem set "_LLVM_PATH=;%_LLVM_HOME%\bin"
goto :eof

@rem output parameters: _MSVC_HOME, _MSVS_HOME
@rem Visual Studio 10
:msvs_2010
set _MSVC_HOME=
set _MSVS_HOME=

for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio 10.0") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat') do set "__BATCH_FILE=%%f"
if not exist "%__BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
set _MSVC_HOME=%_MSVS_HOME%\VC
@rem set __MSBUILD_HOME=
@rem set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
@rem for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
goto :eof

@rem output parameters: _MSVC_HOME, _MSVS_HOME, _MSVS_CMAKE_HOME
@rem Visual Studio 2017/2019
:msvs
set _MSVC_HOME=
set _MSVS_HOME=
set _MSVS_CMAKE_HOME=

set __MSVS_VERSION=2019
for /f "delims=" %%f in ("%ProgramFiles(x86)%\Microsoft Visual Studio\%__MSVS_VERSION%") do set "_MSVS_HOME=%%f"
if not exist "%_MSVS_HOME%\" (
    echo %_ERROR_LABEL% Could not find installation directory for Microsoft Visual Studio %__MSVS_VERSION% 1>&2
    set _EXITCODE=1
    goto :eof
)
set __BATCH_FILE=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" vcvarsall.bat 2^>NUL') do set "__BATCH_FILE=%%f"
if not defined __BATCH_FILE (
    for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" VsDevCmd.bat 2^>NUL') do set "__BATCH_FILE=%%f"
)
if not exist "%__BATCH_FILE%" (
    echo %_ERROR_LABEL% Could not find file vcvarsall.bat in directory "%_MSVS_HOME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
if "%__BATCH_FILE:Community=%"=="%__BATCH_FILE%" ( set "_MSVC_HOME=%_MSVS_HOME%\BuildTools\VC"
) else ( set "_MSVC_HOME=%_MSVS_HOME%\Community\VC"
)
set __MS_CMAKE_CMD=
for /f "delims=" %%f in ('where /r "%_MSVS_HOME%" cmake.exe 2^>NUL') do set "__MS_CMAKE_CMD=%%f"
if not exist "%__MS_CMAKE_CMD%" (
    echo %_ERROR_LABEL% Could not find Microsoft CMake tool ^("%_MSVS_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "delims=" %%i in ("%__MS_CMAKE_CMD%") do set "__VS_CMAKE_BIN_DIR=%%~dpi"
for %%f in ("!__VS_CMAKE_BIN_DIR!\.") do set "_MSVS_CMAKE_HOME=%%~dpf"
@rem call :subst_path "%_MSVS_HOME%"
@rem if not %_EXITCODE%==0 goto :eof
@rem set "_MSVS_HOME=%_SUBST_PATH%"
goto :eof

@rem input parameter: %1=directory path
@rem output parameter: _SUBST_PATH
:subst_path
for %%f in (%~1) do set "_SUBST_PATH=%%f"

set __DRIVE_NAME=X:
set __ASSIGNED_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    if not "%%h"=="%_SUBST_PATH%" (
        echo %_WARNING_LABEL% Drive %__DRIVE_NAME% already assigned to %%h 1>&2
        goto subst_path_end
    )
    set "__ASSIGNED_PATH=%%h"
)
if not defined __ASSIGNED_PATH (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% subst "%__DRIVE_NAME%" "%_SUBST_PATH%" 1>&2
    subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
:subst_path_end
set "_SUBST_PATH=%__DRIVE_NAME%"
goto :eof

@rem output parameters: _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f "delims=" %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    for /f "delims=" %%i in ("%__GIT_CMD%") do set "__GIT_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GIT_BIN_DIR!\.") do set "_GIT_HOME=%%~dpf"
    @rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for /f "delims=" %%f in ("!_GIT_HOME!\.") do set "_GIT_HOME=%%~dpf"
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    @rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set "_GIT_HOME=!__PATH!\Git"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
    if defined _GIT_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory "!_GIT_HOME!" 1>&2
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^("%_GIT_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

@rem input parameter: %1=SDK version
@rem output parameter: _WINSDK_HOME
:winsdk
set "__VERSION=%~1"

set _WINSDK_HOME=
for /f "delims=" %%f in ('dir /b /s "%ProgramFiles(x86)%\Microsoft SDKs\Windows\v%__VERSION%*"') do set "_WINSDK_HOME=%%f"
if not exist "%_WINSDK_HOME%" (
    echo %_WARNING_LABEL% Could not find installation directory for Microsoft Windows SDK %__VERSION% 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    rem set _EXITCODE=1
    goto :eof
)
goto :eof

:print_env
set __VERBOSE=%1
set __VERSIONS_LINE1=
set __VERSIONS_LINE2=
set __VERSIONS_LINE3=
set __WHERE_ARGS=
where /q "%LLVM_HOME%\bin:clang.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%LLVM_HOME%\bin\clang.exe" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% clang %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%LLVM_HOME%\bin:clang.exe"
)
where /q "%LLVM_HOME%\bin:lli.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%LLVM_HOME%\bin\lli.exe" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% lli %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%LLVM_HOME%\bin:lli.exe"
) else (
    echo %_WARNING_LABEL% lli executable not found in directory "%LLVM_HOME%" 1>&2
    echo ^(LLVM installation directory needs additional binaries^) 1>&2
)
where /q "%LLVM_HOME%\bin:opt.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%LLVM_HOME%\bin\opt.exe" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% opt %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%LLVM_HOME%\bin:opt.exe"
)
where /q "%DOXYGEN_HOME%:doxygen.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%DOXYGEN_HOME%\doxygen.exe" -v 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% doxygen %%i,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%DOXYGEN_HOME%:doxygen.exe"
)
set "__PELOOK_CMD=%ROOT_DIR%bin\pelook.exe"
@rem if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,4,*" %%i in ('"%__PELOOK_CMD%" /? 2^>^&1 ^| findstr /b PE') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% pelook %%l,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%_ROOT_DIR%bin:pelook.exe"
@rem )
set "__CMAKE_CMD=%CMAKE_HOME%\bin\cmake.exe"
@rem if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%__CMAKE_CMD%" --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cmake %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%CMAKE_HOME%\bin:cmake.exe"
@rem )
where  /q "%MSYS_HOME%\mingw64\bin:cppcheck.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%MSYS_HOME%\mingw64\bin\cppcheck.exe" --version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% cppcheck %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSYS_HOME%\mingw64\bin:cppcheck.exe"
)
where /q "%MSYS_HOME%\usr\bin:make.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%MSYS_HOME%\usr\bin\make.exe" --version 2^>^&1 ^| findstr Make') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% make %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSYS_HOME%\usr\bin:make.exe"
)
where /q "%MSYS_HOME%\mingw64\bin:gcc.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-7,*" %%i in ('"%MSYS_HOME%\mingw64\bin\gcc.exe" --version 2^>^&1 ^| findstr gcc') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% gcc %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSYS_HOME%\mingw64\bin:gcc.exe"
)
where /q "%PYTHON%:python.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('"%PYTHON%\python.exe" --version 2^>^&1') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%PYTHON%:python.exe"
)
where /q "%GIT_HOME%\bin:git.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%GIT_HOME%\bin\git.exe" --version') do (
        for /f "delims=. tokens=1,2,3,*" %%a in ("%%k") do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% git %%a.%%b.%%c,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:git.exe"
)
where /q "%GIT_HOME%\usr\bin:diff.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,*" %%i in ('"%GIT_HOME%\usr\bin\diff.exe" --version ^| findstr diff') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% diff %%l,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\usr\bin:diff.exe"
)
where /q "%GIT_HOME%\bin:bash.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do (
        set "__VERSION=%%l"
        setlocal enabledelayedexpansion
        set "__VERSIONS_LINE3=%__VERSIONS_LINE3% bash !__VERSION:-release=!,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:bash.exe"
)
@rem see https://github.com/Microsoft/vswhere/releases
where /q vswhere.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-4,5,*" %%i in ('vswhere -help ^| findstr /R /C:"version [0-9][0-9.+]*"') do (
        for /f "delims=+ tokens=1,*" %%v in ("%%m") do set "__VERSION=%%v"
        setlocal enabledelayedexpansion
        set "__VERSIONS_LINE3=%__VERSIONS_LINE3% vswhere !__VERSION!"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% vswhere.exe
)
echo Tool versions:
echo   %__VERSIONS_LINE1%
echo   %__VERSIONS_LINE2%
echo   %__VERSIONS_LINE3%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    @rem if %_DEBUG%==1 echo %_DEBUG_LABEL% where %__WHERE_ARGS%
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do (
        set "__LINE=%%p"
        setlocal enabledelayedexpansion
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
    echo Environment variables: 1>&2
    if defined CMAKE_HOME echo    "CMAKE_HOME=%CMAKE_HOME%" 1>&2
    if defined DOXYGEN_HOME echo    "DOXYGEN_HOME=%DOXYGEN_HOME%" 1>&2
    if defined GIT_HOME echo    "GIT_HOME=%GIT_HOME%" 1>&2
    if defined LLVM_DIR echo    "LLVM_DIR=%LLVM_DIR%" 1>&2
    if defined LLVM_HOME echo    "LLVM_HOME=%LLVM_HOME%" 1>&2
    if defined MSVC_HOME echo    "MSVC_HOME=%MSVC_HOME%" 1>&2
    if defined MSVS_HOME echo    "MSVS_HOME=%MSVS_HOME%" 1>&2
    if defined MSVS_CMAKE_HOME echo    "MSVS_CMAKE_HOME=%MSVS_CMAKE_HOME%" 1>&2
    if defined MSYS_HOME echo    "MSYS_HOME=%MSYS_HOME%" 1>&2
    if defined PYTHON_HOME echo    "PYTHON_HOME=%PYTHON_HOME%" 1>&2
    if defined WINSDK_HOME echo    "WINSDK_HOME=%WINSDK_HOME%" 1>&2
    echo Path associations: 1>&2
    for /f "delims=" %%i in ('subst') do (
        set "__LINE=%%i"
        setlocal enabledelayedexpansion
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined CMAKE_HOME set "CMAKE_HOME=%_CMAKE_HOME%"
        if not defined DOXYGEN_HOME set "DOXYGEN_HOME=%_DOXYGEN_HOME%"
        if not defined GIT_HOME set "GIT_HOME=%_GIT_HOME%"
        if not defined LLVM_DIR set "LLVM_DIR=%_LLVM_HOME%\lib\cmake\llvm"
        if not defined LLVM_HOME set "LLVM_HOME=%_LLVM_HOME%"
        if not defined MSVS_CMAKE_HOME set "MSVS_CMAKE_HOME=%_MSVS_CMAKE_HOME%"
        if not defined MSVC_HOME set "MSVC_HOME=%_MSVC_HOME%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined MSYS_HOME set "MSYS_HOME=%_MSYS_HOME%"
        if not defined PYTHON_HOME set "PYTHON_HOME=%_PYTHON_HOME%"
        if not defined WINSDK_HOME set "WINSDK_HOME=%_WINSDK_HOME%"
        set "PATH=%PATH%%_CMAKE_PATH%%_MSYS_PATH%%_GIT_PATH%;%_ROOT_DIR%bin"
        call :print_env %_VERBOSE%
        if not "%CD:~0,2%"=="%_DRIVE_NAME%" (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% cd /d %_DRIVE_NAME% 1>&2
            cd /d %_DRIVE_NAME%
        )
        if %_BASH%==1 (
            @rem see https://conemu.github.io/en/GitForWindows.html
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\usr\bin\bash.exe --login 1>&2
            cmd.exe /c "%_GIT_HOME%\usr\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
