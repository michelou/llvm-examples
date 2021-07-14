#!/usr/bin/env bash
#
# Copyright (c) 2018-2021 Stéphane Micheloud
#
# Licensed under the MIT License.
#

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [ -h "$source" ] ; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

debug() {
    local DEBUG_LABEL="[46m[DEBUG][0m"
    $DEBUG && echo "$DEBUG_LABEL $1" 1>&2
}

warning() {
    local WARNING_LABEL="[46m[WARNING][0m"
    echo "$WARNING_LABEL $1" 1>&2
}

error() {
    local ERROR_LABEL="[91mError:[0m"
    echo "$ERROR_LABEL $1" 1>&2
}

# use variables EXITCODE, TIMER_START
cleanup() {
    [[ $1 =~ ^[0-1]$ ]] && EXITCODE=$1

    if $TIMER; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total elapsed time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=true && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
		-clang)       TOOLSET=clang ;;
        -debug)       DEBUG=true ;;
		-gcc)         TOOLSET=gcc ;;
        -help)        HELP=true ;;
		-msvc)        TOOLSET=msvc ;;
        -timer)       TIMER=true ;;
        -verbose)     VERBOSE=true ;;
        -*)
            error "Unknown option $arg"
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   CLEAN=true ;;
        compile) COMPILE=true ;;
        help)    HELP=true ;;
        run)     COMPILE=true && RUN=true ;;
        *)
            error "Unknown subcommand $arg"
            EXITCODE=1 && return 0
            ;;
        esac
    done
    debug "Options    : TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: CLEAN=$CLEAN COMPILE=$COMPILE HELP=$HELP RUN=$RUN"
	debug "Variables  : DOXYGEN_HOME=$DOXYGEN_HOME"
    debug "Variables  : LLVM_HOME=$LLVM_HOME"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    $TIMER && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -debug       show commands executed by this script
    -timer       display total elapsed time
    -verbose     display progress messages

  Subcommands:
    clean        delete generated files
    compile      compile C++ source files
    help         display this help message
    run          execute main class
EOS
}

clean() {
    if [ -d "$TARGET_DIR" ]; then
        if $DEBUG; then
            debug "Delete directory $TARGET_DIR"
        elif $VERBOSE; then
            echo "Delete directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$TARGET_DIR"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

action_required() {
    local timestamp_file=$1
    local search_path=$2
    local search_pattern=$3
    local latest=
    for f in $(find $search_path -name $search_pattern 2>/dev/null); do
        [[ $f -nt $latest ]] && latest=$f
    done
    if [ -z "$latest" ]; then
        ## Do not compile if no source file
        echo 0
    elif [ ! -f "$timestamp_file" ]; then
        ## Do compile if timestamp file doesn't exist
        echo 1
    else
        ## Do compile if timestamp file is older than most recent source file
        local timestamp=$(stat -c %Y $timestamp_file)
        [[ $timestamp_file -nt $latest ]] && echo 1 || echo 0
    fi
}

compile() {
    [[ -d "$TARGET_DIR" ]] || mkdir -p "$TARGET_DIR"

    if [[ $TOOLSET == "clang" ]]; then set TOOLSET_NAME="Clang/GNU Make"
    elif [[ $TOOLSET == "gcc" ]]; then set TOOLSET_NAME="GCC/GNU Make"
    else set TOOLSET_NAME="MSVC/MSBuild"
    fi
    set LLVM_DIR="$LLVM_HOME/lib/cmake/llvm"
	
	compile_$TOOLSET
}

compile_clang() {
    export CC="$LLVM_HOME/bin/clang"
    export CXX="$LLVM_HOME/bin/clang++"
    export MAKE="$MAKE_CMD"
    export RC="$WINDRES_CMD"

    local CMAKE_CMD="$CMAKE_HOME/bin/cmake"
    local CMAKE_OPTS=-"G \"Unix Makefiles\""

    pushd "$TARGET_DIR"
    if $DEBUG; then debug "Current directory is: $(pwd)"
    elif $VERBOSE; then echo "Current directory is: $(pwd)" 1>&2
    fi
    if $DEBUG; then debug "$CMAKE_CMD $CMAKE_OPTS .."
    elif $VERBOSE; then echo "Generate configuration files into directory ${TARGET_DIR//$ROOT_DIR//}" 1>&2
    fi
    eval "$CMAKE_CMD" $CMAKE_OPTS ..
    if [[ $? -ne 0 ]]; then
        popd
        error "Generation of build configuration failed"
        EXITCODE=1
        return 0
    fi
    if $DEBUG; then MAKE_OPTS="--debug=v"
    else MAKE_OPTS="--debug=n"
    fi
    if $DEBUG; then debug "$MAKE_CMD $MAKE_OPTS"
    elif $VERBOSE; then echo "Generate executable $PROJ_NAME.exe" 1>&2
    fi
	eval "$MAKE_CMD" $MAKE_OPTS
	if [[ $? -ne 0 ]]; then
		popd
		error "Generation of executable %_PROJ_NAME%.exe failed"
		set _EXITCODE=1
		return 0
	fi
	popd
}

compile_gcc() {
    echo "gcc"
}

compile_msvc() {
    echo "msvc"
}

run() {
    echo "run"
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR=$ROOT_DIR/src/main/cpp
TARGET_DIR=$ROOT_DIR/build

CLEAN=false
COMPILE=false
DEBUG=false
HELP=false
RUN=false
TIMER=false
TOOLSET=msvc
VERBOSE=false

COLOR_START="[32m"
COLOR_END="[0m"

if [ ! -x "$LLVM_HOME/bin/clang" ]; then
    error "LLVM installation not found"
    cleanup 1
fi
CLANG_CMD="$LLVM_HOME/bin/clang"

if [ ! -x "$CMAKE_HOME/bin/cmake" ]; then
    error "CMake installation not found"
    cleanup 1
fi
CMAKE_CMD="$CMAKE_HOME/bin/cmake"

PROJECT_NAME="$(basename $ROOT_DIR)"
PROJECT_URL="github.com/$USER/llvm-examples"
PROJECT_VERSION="1.0-SNAPSHOT"

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

$HELP && help && cleanup

if $CLEAN; then
    clean || cleanup 1
fi
if $COMPILE; then
    compile || cleanup 1
fi
if $RUN; then
    run || cleanup 1
fi
cleanup
