##
## Copyright (c) 2018-2024 Stéphane Micheloud
##
## Licensed under the MIT License.
##
##############################################################################

TOOLSET ?= gcc
CXXSTD ?= c++20

include ../Makefile.inc

##############################################################################
## main rules

TARGET_DIR = build

ifeq ($(TOOLSET),gcc)
CXXFLAGS = --std=$(CXXSTD) -O2 -Wall -Wno-unused-variable
CXXLINK =
else
$(error Variable TOOLSET is invalid)
endif
CXXDEBUG =
CXXVARS =

SOURCE_FILES = $(wildcard src/main/cpp/*.cpp)

PROGRAM_NAME = hello

all: build

build: $(SOURCE_FILES)
	"$(CXX)" $(CXXDEBUG) $(CXXFLAGS) $(CXXVARS) -o main $^ $(CXXLINK)

executable: build
	./main
	"$(LLC)" -filetype=obj $(PROGRAM_NAME).ll -o $(PROGRAM_NAME).o
	"$(CXX)" $(PROGRAM_NAME).o -o $(PROGRAM_NAME)
	@$(ECHO) "'$(PROGRAM_NAME)' created!"

run: executable
	./$(PROGRAM_NAME)

clean:
	"$(RM)" -rf "$(TARGET_DIR)"

help:
	@$(ECHO) "Usage: make all|build|clean|executable|help|run"
	@$(ECHO) ""
	@$(ECHO) "  Subcommands:"
	@$(ECHO) "    all    alias for build"
	@$(ECHO) "    build  compile C++ source files"
	@$(ECHO) "    clean  delete generated files"
	@$(ECHO) "    help   print this help message"
	@$(ECHO) "    run    execute main program \"$(PROGRAM_NAME)\""

##############################################################################
## phony

.PHONY: all build clean executable help run

.SUFFIXES:
.SUFFIXES: .c .cpp .o .obj .exe
