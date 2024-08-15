ifeq ($(OS),Windows_NT)
ifndef LLVM_HOME
$(error Variable LLVM_HOME is not set)
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
MSYS_PATH   = $(subst \,/,$(MSYS_HOME))
LLVM_PATH   = $(subst \,/,$(LLVM_HOME))
#
CLANG       = $(LLVM_PATH)/bin/clang.exe
LLC         = $(LLVM_PATH))/bin/llc.exe
LLVM_CONFIG = $(LLVM_PATH))/bin/llvm-config.exe
CL          = $(MSVC_HOME)/bin/Host$(ARCH)/$(ARCH)/cl.exe
## $(MSYS_HOME)\usr\bin\{cp.exe, make.exe, wget.exe}
CC          = /mingw64/bin/cc.exe
CP          = /usr/bin/cp.exe
CXX         = /mingw64/bin/g++.exe
ECHO        = /usr/bin/echo.exe
FIND        = /usr/bin/find.exe
MKDIR       = /usr/bin/mkdir.exe
RM          = /usr/bin/rm.exe
TEST        = /usr/bin/test.exe
TOUCH       = /usr/bin/touch.exe
#
MSVC_INCPATH   = /include
MSVC_LIBPATH   = /lib/$(ARCH)
MINGW_XXX      = /mingw64/include
MINGW_INCPATH  = /mingw64/x86_64-w64-mingw32/include
MINGW_LIBPATH  = /mingw64/x86_64-w64-mingw32/lib
#
WINSDK_INCROOT = $(subst \,/,$(WINSDK_HOME))/include
WINSDK_INCPATH = $(WINSDK_INCROOT)/$(shell cd "$(WINSDK_INCROOT)" && ls -d [0-9]*/ | tail -n 1)
WINSDK_LIBROOT = $(subst \,/,$(WINSDK_HOME))/lib
WINSDK_LIBPATH = $(WINSDK_LIBROOT)/$(shell cd "$(WINSDK_LIBROOT)" && ls -d [0-9]*/ | tail -n 1)
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
