@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

for %%f in ("%ProgramFiles%") do set _PROGRAM_FILES=%%~sf
for %%f in ("%ProgramFiles(x86)%") do set _PROGRAM_FILES_X86=%%~sf

set _WSWHERE_CMD=%_ROOT_DIR%bin\vswhere.exe

call :args %*
if not %_EXITCODE%==0 goto end
if %_HELP%==1 call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

set _CMAKE_PATH=
set _MSYS_PATH=
set _LLVM_PATH=
set _MSVS_PATH=
set _PYTHON_PATH=
set _GIT_PATH=

call :cmake
if not %_EXITCODE%==0 goto end

call :msys
if not %_EXITCODE%==0 goto end

call :llvm
if not %_EXITCODE%==0 goto end

rem call :msvs
call :msvs_2019
if not %_EXITCODE%==0 goto end

call :python
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
:args
set _HELP=0
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="help" ( set _HELP=1 & goto args_done
) else if /i "%__ARG%"=="-debug" ( set _DEBUG=1
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -debug      show commands executed by this script
echo     -verbose    display progress messages
echo   Subcommands:
echo     help        display this help message
goto :eof

rem output parameter(s): _CMAKE_HOME, _CMAKE_PATH
:cmake
set _CMAKE_HOME=
set _CMAKE_PATH=

set __CMAKE_EXE=
for /f %%f in ('where cmake.exe 2^>NUL') do set __CMAKE_EXE=%%f
if defined __CMAKE_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of CMake executable found in PATH
    for /f "delims=" %%i in ("%__CMAKE_EXE%") do set __CMAKE_BIN_DIR=%%~dpi
    for %%f in ("!__CMAKE_BIN_DIR!..") do set _CMAKE_HOME=%%~sf
    rem keep _CMAKE_PATH undefined since executable already in path
    goto :eof
) else if defined CMAKE_HOME (
    set _CMAKE_HOME=%CMAKE_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable CMAKE_HOME
) else (
    set "__PATH=%_PROGRAM_FILES%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    if not defined _CMAKE_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\cmake*" 2^>NUL') do set "_CMAKE_HOME=!__PATH!\%%f"
    )
)
if not exist "%_CMAKE_HOME%\bin\cmake.exe" (
    echo Error: cmake executable not found ^(%_CMAKE_HOME%^) 1>&2
    set _CMAKE_HOME=
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_CMAKE_HOME%") do set _CMAKE_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default CMake installation directory %_CMAKE_HOME%

set "_CMAKE_PATH=;%_CMAKE_HOME%\bin"
goto :eof

rem output parameter(s): _MSYS_HOME, _MSYS_PATH
:msys
set _MSYS_HOME=
set _MSYS_PATH=

set __MAKE_EXE=
for /f %%f in ('where make.exe 2^>NUL') do set __MAKE_EXE=%%f
if defined __MAKE_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of GNU Make executable found in PATH
    for /f "delims=" %%i in ("%__MAKE_EXE%") do set __MAKE_BIN_DIR=%%~dpi
    for %%f in ("!__MAKE_BIN_DIR!..\..") do set _MSYS_HOME=%%~sf
    rem keep _MSYS_PATH undefined since executable already in path
    goto :eof
) else if defined MSYS_HOME (
    set _MSYS_HOME=%MSYS_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable MSYS_HOME
) else (
    set "__PATH=%_PROGRAM_FILES%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    if not defined _MSYS_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MSYS_HOME%\usr\bin\make.exe" (
    echo Error: GNU Make executable not found ^(%_MSYS_HOME%^) 1>&2
    set _MSYS_HOME=
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_MSYS_HOME%") do set _MSYS_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default MSYS installation directory %_MSYS_HOME%

set "_MSYS_PATH=;%_MSYS_HOME%\usr\bin"
goto :eof

rem output parameter(s): _LLVM_HOME, _LLVM_PATH
:llvm
set _LLVM_HOME=
set _LLVM_PATH=

set __CLANG_EXE=
for /f %%f in ('where clang.exe 2^>NUL') do set __CLANG_EXE=%%f
if defined __CLANG_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of Clang executable found in PATH
    for /f "delims=" %%i in ("%__CLANG_EXE%") do set __LLVM_BIN_DIR=%%~dpi
    for %%f in ("!__LLVM_BIN_DIR!..") do set _LLVM_HOME=%%~sf
    rem keep _LLVM_PATH undefined since executable already in path
    goto :eof
) else if defined LLVM_HOME (
    set _LLVM_HOME=%LLVM_HOME%
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable LLVM_HOME
) else (
    set "__PATH=%_PROGRAM_FILES%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\LLVM*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    if not defined _LLVM_HOME (
        set __PATH=C:\opt
        for /f %%f in ('dir /ad /b "!__PATH!\LLVM*" 2^>NUL') do set "_LLVM_HOME=!__PATH!\%%f"
    )
)
if not exist "%_LLVM_HOME%\bin\clang.exe" (
    echo Error: clang executable not found ^(%_LLVM_HOME%^) 1>&2
    set _LLVM_HOME=
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%_LLVM_HOME%") do set _LLVM_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default LLVM installation directory %_LLVM_HOME%

set "_LLVM_PATH=;%_LLVM_HOME%\bin"
goto :eof

rem output paramter(s): _MSVC_HOME, _MSVS_PATH, _MSVS_HOME
rem Visual Studio 10
:msvs
set _MSVC_HOME=
set _MSVS_PATH=
set _MSVS_HOME=

for /f "delims=" %%f in ("%_PROGRAM_FILES_X86%\Microsoft Visual Studio 10.0") do set _MSVS_HOME=%%~sf
if not exist "%_MSVS_HOME%" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem From now on use short name of MSVS installation path
for %%f in ("%_MSVS_HOME%") do set _MSVS_HOME=%%~sf

set _MSVC_HOME=%_MSVS_HOME%\VC
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __MSVC_ARCH=\amd64
) else ( set __MSVC_ARCH=
)
if not exist "%_MSVC_HOME%\bin%__MSVC_ARCH%\" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 10 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __MSBUILD_HOME=
set "__FRAMEWORK_DIR=%SystemRoot%\Microsoft.NET\Framework"
for /f %%f in ('dir /ad /b "%__FRAMEWORK_DIR%\*" 2^>NUL') do set "__MSBUILD_HOME=%__FRAMEWORK_DIR%\%%f"
if not exist "%__MSBUILD_HOME%\MSBuild.exe" (
    echo Error: Could not find Microsoft builder 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%;%__MSBUILD_HOME%"
goto :eof

rem output parameter(s): _MSBUILD_HOME, _MSBUILD_PATH, _MSVC_HOME, _MSVC_PATH, _MSVS_HOME
rem Visual Studio 2019
:msvs_2019
set _MSVC_HOME=
set _MSVS_HOME=
set _MSVS_PATH=

set __WSWHERE_CMD=%_ROOT_DIR%bin\vswhere.exe
for /f "delims=" %%f in ('%__WSWHERE_CMD% -property installationPath 2^>NUL') do set _MSVS_HOME=%%~sf
if not exist "%_MSVS_HOME%\" (
    echo Error: Could not find installation directory for Microsoft Visual Studio 2019 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
call :subst_path "%_MSVS_HOME%"
if not %_EXITCODE%==0 goto :eof
set "_MSVS_HOME=%_SUBST_PATH%"

set "__PATH=%_MSVS_HOME%\VC\Tools\MSVC"
for /f %%f in ('dir /ad /b "%__PATH%" 2^>NUL') do set _MSVC_HOME=%__PATH%\%%f
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" ( set __MSVC_ARCH=\Hostx64\x64
) else ( set __MSVC_ARCH=\Hostx86\x86
)
if not exist "%_MSVC_HOME%\bin%__MSVC_ARCH%\" (
    echo Error: Could not find installation directory for Microsoft C/C++ compiler 1>&2
    echo        ^(see https://github.com/oracle/graal/blob/master/compiler/README.md^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "__PATH=%_MSVS_HOME%\MSBuild\Current"
for /f "delims=" %%i in ('where /r "!__PATH!" msbuild.exe ^| findstr amd64') do set "__MSBUILD_BIN_DIR=%%~dpi"
if not exist "%__MSBUILD_BIN_DIR%\MSBuild.exe" (
    echo Error: Could not find Microsoft builder 1>&2
    set _MSBUILD_HOME=
    set _EXITCODE=1
    goto :eof
)
set "_MSVS_PATH=;%_MSVC_HOME%\bin%__MSVC_ARCH%;%__MSBUILD_BIN_DIR%"
goto :eof

rem input parameter: %1=directory path
rem output parameter: _SUBST_PATH
:subst_path
for %%f in (%~1) do set "_SUBST_PATH=%%f"

set __DRIVE_NAME=X:
set __ASSIGNED_PATH=
for /f "tokens=1,2,*" %%f in ('subst ^| findstr /b "%__DRIVE_NAME%" 2^>NUL') do (
    if not "%%h"=="%_SUBST_PATH%" (
        echo Warning: Drive %__DRIVE_NAME% already assigned to %%h
        goto :eof
    )
    set "__ASSIGNED_PATH=%%h"
)
if not defined __ASSIGNED_PATH (
    if %_DEBUG%==1 echo [%_BASENAME%] subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    subst "%__DRIVE_NAME%" "%_SUBST_PATH%"
    if not !ERRORLEVEL!==0 (
        set _EXITCODE=1
        goto :eof
    )
)
set _SUBST_PATH=%__DRIVE_NAME%
goto :eof

rem output parameter(s): _PYTHON_PATH
:python
set _PYTHON_PATH=

set __PYTHON_HOME=
set __PYTHON_EXE=
for /f %%f in ('where python.exe 2^>NUL') do set __PYTHON_EXE=%%f
if defined __PYTHON_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of Python executable found in PATH
    rem keep _PYTHON_PATH undefined since executable already in path
    goto :eof
) else if defined PYTHON_HOME (
    set "__PYTHON_HOME=%PYTHON_HOME%"
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable PYTHON_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Python\" ( set __PYTHON_HOME=!__PATH!\Python
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        if not defined __PYTHON_HOME (
            set "__PATH=%_PROGRAM_FILES%"
            for /f %%f in ('dir /ad /b "!__PATH!\Python-3*" 2^>NUL') do set "__PYTHON_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%__PYTHON_HOME%\python.exe" (
    echo Error: Python executable not found ^(%__PYTHON_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
if not exist "%__PYTHON_HOME%\Scripts\pylint.exe" (
    echo Error: Pylint executable not found ^(%__PYTHON_HOME^) 1>&2
    echo ^(execute command: python -m pip install pylint^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%__PYTHON_HOME%") do set __PYTHON_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default Python installation directory %__PYTHON_HOME%

set "_PYTHON_PATH=;%__PYTHON_HOME%;%__PYTHON_HOME%\Scripts"
goto :eof

rem output parameter(s): _GIT_PATH
:git
set _GIT_PATH=

set __GIT_HOME=
set __GIT_EXE=
for /f %%f in ('where git.exe 2^>NUL') do set __GIT_EXE=%%f
if defined __GIT_EXE (
    if %_DEBUG%==1 echo [%_BASENAME%] Using path of Git executable found in PATH
    rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "__GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo [%_BASENAME%] Using environment variable GIT_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set __GIT_HOME=!__PATH!\Git
    ) else (
        for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "__GIT_HOME=!__PATH!\%%f"
        if not defined __GIT_HOME (
            set "__PATH=%_PROGRAM_FILES%"
            for /f %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "__GIT_HOME=!__PATH!\%%f"
        )
    )
)
if not exist "%__GIT_HOME%\bin\git.exe" (
    echo Error: Git executable not found ^(%__GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
rem path name of installation directory may contain spaces
for /f "delims=" %%f in ("%__GIT_HOME%") do set __GIT_HOME=%%~sf
if %_DEBUG%==1 echo [%_BASENAME%] Using default Git installation directory %__GIT_HOME%

set "_GIT_PATH=;%__GIT_HOME%\bin;%__GIT_HOME%\usr\bin;%__GIT_HOME%\mingw64\bin;%~dp0bin"
goto :eof

:print_env
set __VERBOSE=%1
set "__VERSIONS_LINE1=  "
set "__VERSIONS_LINE2=  "
set "__VERSIONS_LINE3=  "
set "__VERSIONS_LINE4=  "
set "__VERSIONS_LINE5=  "
set __WHERE_ARGS=
where /q clang.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('clang.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% clang %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% clang.exe
)
where /q lli.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('lli.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% lli %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% lli.exe
) else (
    echo Warning: lli executable not found in directory %_LLVM_HOME% 1>&2
    echo ^(LLVM installation directory needs additional binaries^) 1>&2
)
where /q opt.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('opt.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% opt %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% opt.exe
)
where /q cl.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-5,6,*" %%i in ('cl.exe 2^>^&1 ^| findstr version ^| findstr x64') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% cl %%n"
    set __WHERE_ARGS=%__WHERE_ARGS% cl.exe
)
where /q dumpbin.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-5,*" %%i in ('dumpbin.exe 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% dumpbin %%n,"
    set __WHERE_ARGS=%__WHERE_ARGS% dumpbin.exe
)
where /q msbuild.exe
if %ERRORLEVEL%==0 (
    for /f %%i in ('msbuild.exe -version ^| findstr /b "[0-9]"') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% msbuild %%i"
    set __WHERE_ARGS=%__WHERE_ARGS% msbuild.exe
)
where /q cmake.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('cmake.exe --version 2^>^&1 ^| findstr version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% cmake %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% cmake.exe
)
where /q nmake.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-7,*" %%i in ('nmake.exe /? 2^>^&1 ^| findstr Version') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% nmake %%o,"
    set __WHERE_ARGS=%__WHERE_ARGS% nmake.exe
)
where /q make.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('make.exe --version 2^>^&1 ^| findstr Make') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% make %%k"
    set __WHERE_ARGS=%__WHERE_ARGS% make.exe
)
where /q python.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,*" %%i in ('python.exe --version 2^>^&1') do set "__VERSIONS_LINE4=%__VERSIONS_LINE4% python %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% python.exe
)
where /q git.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('git.exe --version') do set "__VERSIONS_LINE4=%__VERSIONS_LINE4% git %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% git.exe
)
where /q diff.exe
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,*" %%i in ('diff.exe --version ^| findstr diff') do set "__VERSIONS_LINE4=%__VERSIONS_LINE4% diff %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% diff.exe
)
rem see https://github.com/Microsoft/vswhere/releases
where /q vswhere.exe
if %ERRORLEVEL%==0 (
    for /f "tokens=1-4,5,*" %%i in ('vswhere -help ^| findstr /R /C:"version [0-9][0-9.+]*"') do set "__VERSIONS_LINE5=%__VERSIONS_LINE5% vswhere %%m"
    set __WHERE_ARGS=%__WHERE_ARGS% vswhere.exe
)
echo Tool versions:
echo %__VERSIONS_LINE1%
echo %__VERSIONS_LINE2%
echo %__VERSIONS_LINE3%
echo %__VERSIONS_LINE4%
echo %__VERSIONS_LINE5%
if %__VERBOSE%==1 if defined __WHERE_ARGS (
    rem if %_DEBUG%==1 echo [%_BASENAME%] where %__WHERE_ARGS%
    echo Tool paths:
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do echo    %%p
    rem echo Environment variables:
    rem echo    LLVM_HOME=%LLVM_HOME%
    rem echo    MSVC_HOME=%MSVC_HOME%
    rem echo    CMAKE_HOME=%CMAKE_HOME%
)
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
endlocal & (
    if not defined CMAKE_HOME set CMAKE_HOME=%_CMAKE_HOME%
    if not defined LLVM_HOME set LLVM_HOME=%_LLVM_HOME%
    rem if not defined MSVS_HOME set MSVS_HOME=%_MSVS_HOME%
    if not defined MSVC_HOME set MSVC_HOME=%_MSVC_HOME%
    set "PATH=%PATH%%_CMAKE_PATH%%_MSYS_PATH%%_LLVM_PATH%%_MSVS_PATH%%_PYTHON_PATH%%_GIT_PATH%"
    call :print_env %_VERBOSE%
    if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
