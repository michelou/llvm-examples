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
CC          = $(MSYS_PATH)/mingw64/bin/cc.exe
CL          = $(MSYS_PATH)/bin/Host$(ARCH)/$(ARCH)/cl.exe
CLANG       = $(LLVM_PATH)/bin/clang.exe
CP          = $(MSYS_PATH)/usr/bin/cp.exe
CXX         = $(MSYS_PATH)/mingw64/bin/g++.exe
ECHO        = $(MSYS_PATH)/usr/bin/echo.exe
FIND        = $(MSYS_PATH)/usr/bin/find.exe
LLC         = $(LLVM_PATH))/bin/llc.exe
LLVM_CONFIG = $(LLVM_PATH))/bin/llvm-config.exe
MKDIR       = $(MSYS_PATH)/usr/bin/mkdir.exe
RM          = $(MSYS_PATH)/usr/bin/rm.exe
TEST        = $(MSYS_PATH)/usr/bin/test.exe
TOUCH       = $(MSYS_PATH)/usr/bin/touch.exe
#
MSVC_INCPATH   = $(MSYS_PATH)/include
MSVC_LIBPATH   = $(MSYS_PATH)/lib/$(ARCH)
WINSDK_INCROOT = $(subst \,/,$(WINSDK_HOME))/include
WINSDK_INCPATH = $(WINSDK_INCROOT)/$(shell cd "$(WINSDK_INCROOT)" && ls -d [0-9]*/ | tail -n 1)
WINSDK_LIBROOT = $(subst \,/,$(WINSDK_HOME))/lib
WINSDK_LIBPATH = $(WINSDK_LIBROOT)/$(shell cd "$(WINSDK_LIBROOT)" && ls -d [0-9]*/ | tail -n 1)
MINGW_XXX      = $(MSYS_PATH)/mingw64/include
MINGW_INCPATH  = $(MSYS_PATH)/mingw64/x86_64-w64-mingw32/include
MINGW_LIBPATH  = $(MSYS_PATH)/mingw64/x86_64-w64-mingw32/lib
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
