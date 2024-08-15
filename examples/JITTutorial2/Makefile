##
## Copyright (c) 2018-2024 Stéphane Micheloud
##
## Licensed under the MIT License.
##
##############################################################################

include ../Makefile.inc

##############################################################################
## main rules

SOURCE_FILES = $(wildcard src/main/cpp/*.cpp)

PROGRAM_NAME = JITTutorial1

CONFIG = $(shell $(LLVM_CONFIG) --cxxflags --ldflags --system-libs --libs core)

all: build

build: $(SOURCE_FILES)
	"$(CXX)" -g -O3 $(CONFIG) -o main $<

executable: build
	./main
	"$(LLC)" -filetype=obj $(PROGRAM_NAME).ll -o $(PROGRAM_NAME).o
	"$(CXX)" $(PROGRAM_NAME).o -o $(PROGRAM_NAME)
	@$(ECHO) "'$(PROGRAM_NAME)' created!"

run: executable
	./$(PROGRAM_NAME)

clean:
	[ -f "main" ] && $(RM) -f main
	[ -d "main.dSYM" ] && $(RM) -rf main.dSYM
	[ -f "$(PROGRAM_NAME).ll" ] && $(RM) -f $(PROGRAM_NAME).ll
	[ -f "$(PROGRAM_NAME).o" ] && $(RM) -f $(PROGRAM_NAME).o
	[ -f "$(PROGRAM_NAME)" ] && $(RM) -f $(PROGRAM_NAME)

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
