@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

@rem files README.md, RESOURCES.md, etc.
set _LAST_MODIFIED_OLD=michelou/)/July 2024
set _LAST_MODIFIED_NEW=michelou/)/August 2024

set _LAST_DOWNLOAD_OLD=(\*July 2024\*)
set _LAST_DOWNLOAD_NEW=(*August 2024*)

@rem to be transformed into -not -path "./<dirname>/*"
set _EXCLUDE_TOPDIRS=bin docs llvm-15.0.6.src llvm-15.0.7.src llvm-16.0.6.src
set _EXCLUDE_SUBDIRS=_LOCAL

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
if %_RUN%==1 (
    call :run
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
for /f "delims=" %%f in ("%~dp0\.") do set "_ROOT_DIR=%%~dpf"
@rem remove trailing backslash for virtual drives
if "%_ROOT_DIR:~-2%"==":\" set "_ROOT_DIR=%_ROOT_DIR:~0,-1%"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

if not exist "%GIT_HOME%\usr\bin\grep.exe" (
    echo %_ERROR_LABEL% Grep command not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_CYGPATH_CMD=%GIT_HOME%\usr\bin\cygpath.exe"
set "_FIND_CMD=%GIT_HOME%\usr\bin\find.exe"
set "_GREP_CMD=%GIT_HOME%\usr\bin\grep.exe"
set "_SED_CMD=%GIT_HOME%\usr\bin\sed.exe"
set "_UNIX2DOS_CMD=%GIT_HOME%\usr\bin\unix2dos.exe"
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
:args
set _HELP=0
set _RUN=1
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
    ) else if "%__ARG%"=="run" ( set _RUN=1
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
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _HELP=%_HELP% _RUN=%_RUN%  1>&2
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
echo     %__BEG_O%-debug%__END%       print commands executed by this script
echo     %__BEG_O%-verbose%__END%     print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%         print this help message
echo     %__BEG_O%run%__END%          replace old patterns with new ones
goto :eof

:run
for /f "delims=" %%f in ('"%_CYGPATH_CMD%" %_ROOT_DIR%\') do set "__ROOT_DIR=%%~f"

set __FIND_EXCLUDES=
for %%i in (%_EXCLUDE_TOPDIRS%) do (
    set __FIND_EXCLUDES=!__FIND_EXCLUDES! -not -path "%__ROOT_DIR%%%i/*"
)
for %%i in (%_EXCLUDE_SUBDIRS%) do (
    set __FIND_EXCLUDES=!__FIND_EXCLUDES! -not -path "*/*%%i*/*"
)
set __N_MD=0
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_FIND_CMD%" "%__ROOT_DIR%" -type f -name "*.md" %__FIND_EXCLUDES% 1>&2
for /f "delims=" %%f in ('%_FIND_CMD% "%__ROOT_DIR%" -type f -name "*.md" %__FIND_EXCLUDES%') do (
    set "__INPUT_FILE=%%f"
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GREP_CMD%" -q "%_LAST_MODIFIED_OLD%" "!__INPUT_FILE!" 1>&2
    ) else if %_VERBOSE%==1 ( echo Check file "!__INPUT_FILE!" 1>&2
    )
    call "%_GREP_CMD%" -q "%_LAST_MODIFIED_OLD%" "!__INPUT_FILE!"
    if !ERRORLEVEL!==0 (
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_SED_CMD%" -i "s@%_LAST_MODIFIED_OLD%@%_LAST_MODIFIED_NEW%@g" "!__INPUT_FILE!" 1>&2
        ) else if %_VERBOSE%==1 ( echo    Replace pattern "%_LAST_MODIFIED_OLD%" by "%_LAST_MODIFIED_NEW%" 1>&2
        )
        call "%_SED_CMD%" -i "s@%_LAST_MODIFIED_OLD%@%_LAST_MODIFIED_NEW%@g" "!__INPUT_FILE!"
        call "%_UNIX2DOS_CMD%" -q "!__INPUT_FILE!"
        set /a __N_MD+=1
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_GREP_CMD%" -q "%_LAST_DOWNLOAD_OLD%" "!__INPUT_FILE!" 1>&2
    call "%_GREP_CMD%" -q "%_LAST_DOWNLOAD_OLD%" "!__INPUT_FILE!"
    if !ERRORLEVEL!==0 (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_SED_CMD%" -i "s@%_LAST_DOWNLOAD_OLD%@%_LAST_DOWNLOAD_NEW%@g" "!__INPUT_FILE!" 1>&2
        call "%_SED_CMD%" -i "s@%_LAST_DOWNLOAD_OLD%@%_LAST_DOWNLOAD_NEW%@g" "!__INPUT_FILE!"
        call "%_UNIX2DOS_CMD%" -q "!__INPUT_FILE!"
        if !__N_MD!==0 set /a __N_MD+=1
    )
)
call :message %__N_MD% "Markdown"
goto :eof

@rem input parameters: %1=nr of updates, %2=file name
:message
set __N=%~1
set __FILE_NAME=%~2
if %__N% gtr 1 ( set __STR=files ) else ( set __STR=file )
echo    Updated %__N% %__FILE_NAME% %__STR%
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
