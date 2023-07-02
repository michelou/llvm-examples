ifeq ($(OS),Windows_NT)
ifndef LLVM_HOME
$(error Variable LLVM_HOME is not set)
endif
ifndef MSVC_HOME
$(error Variable MSVC_HOME is not set)
endif
ifndef MSYS_HOME
$(error Variable MSYS_HOME is not set)
endif

ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
ARCH = x64
else
ARCH = x86
endif

TARGET_EXT  = .exe
PSEP        = ;
CC          = $(subst \,/,$(MSYS_HOME))/mingw64/bin/cc.exe
CL          = $(subst \,/,$(MSVC_HOME))/bin/Host$(ARCH)/$(ARCH)/cl.exe
CLANG       = $(subst \,/,$(LLVM_HOME))/bin/clang.exe
CP          = $(subst \,/,$(MSYS_HOME))/usr/bin/cp.exe
CXX         = $(subst \,/,$(MSYS_HOME))/mingw64/bin/g++.exe
ECHO        = $(subst \,/,$(MSYS_HOME))/usr/bin/echo.exe
FIND        = $(subst \,/,$(MSYS_HOME))/usr/bin/find.exe
LLC         = $(subst \,/,$(LLVM_HOME))/bin/llc.exe
LLVM_CONFIG = $(subst \,/,$(LLVM_HOME))/bin/llvm-config.exe
MKDIR       = $(subst \,/,$(MSYS_HOME))/usr/bin/mkdir.exe
RM          = $(subst \,/,$(MSYS_HOME))/usr/bin/rm.exe
TEST        = $(subst \,/,$(MSYS_HOME))/usr/bin/test.exe
TOUCH       = $(subst \,/,$(MSYS_HOME))/usr/bin/touch.exe
#
MSVC_INCPATH   = $(subst \,/,$(MSVC_HOME))/include
MSVC_LIBPATH   = $(subst \,/,$(MSVC_HOME))/lib/$(ARCH)
WINSDK_INCROOT = $(subst \,/,$(WINSDK_HOME))/include
WINSDK_INCPATH = $(WINSDK_INCROOT)/$(shell cd "$(WINSDK_INCROOT)" && ls -d [0-9]*/ | tail -n 1)
WINSDK_LIBROOT = $(subst \,/,$(WINSDK_HOME))/lib
WINSDK_LIBPATH = $(WINSDK_LIBROOT)/$(shell cd "$(WINSDK_LIBROOT)" && ls -d [0-9]*/ | tail -n 1)
MINGW_XXX      = $(subst \,/,$(MSYS_HOME))/mingw64/include
MINGW_INCPATH  = $(subst \,/,$(MSYS_HOME))/mingw64/x86_64-w64-mingw32/include
MINGW_LIBPATH  = $(subst \,/,$(MSYS_HOME))/mingw64/x86_64-w64-mingw32/lib
else
TARGET_EXT  =
PSEP        = :
CC          = cc
CL          = cl
CLANG       = clang
CP          = cp
CXX         = g++
ECHO        = echo
FIND        = find
LLC         = llc
LLVM_CONFIG = llvm-config
MKDIR       = mkdir
RM          = rm
TEST        = test
TOUCH       = touch
endif
