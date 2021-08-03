ifndef LLVM_HOME
$(error Variable LLVM_HOME is not set)
endif
ifndef MSYS_HOME
$(error Variable MSYS_HOME is not set)
endif

ifeq ($(OS),Windows_NT)
PSEP        = ;
CC          = $(subst \,/,$(MSYS_HOME))/mingw64/bin/cc.exe
CXX         = $(subst \,/,$(MSYS_HOME))/mingw64/bin/g++.exe
ECHO        = $(subst \,/,$(MSYS_HOME))/usr/bin/echo.exe
FIND        = $(subst \,/,$(MSYS_HOME))/usr/bin/find.exe
LLC         = $(subst \,/,$(LLVM_HOME))/bin/llc.exe
LLVM_CONFIG = $(subst \,/,$(LLVM_HOME))/bin/llvm-config.exe
MKDIR       = $(subst \,/,$(MSYS_HOME))/usr/bin/mkdir.exe
RM          = $(subst \,/,$(MSYS_HOME))/usr/bin/rm.exe
TOUCH       = $(subst \,/,$(MSYS_HOME))/usr/bin/touch.exe
else
PSEP        = :
CC          = cc
CXX         = g++
ECHO        = echo
FIND        = find
LLC         = llc
LLVM_CONFIG = llvm-config
MKDIR       = mkdir
RM          = rm
TOUCH       = touch
endif
