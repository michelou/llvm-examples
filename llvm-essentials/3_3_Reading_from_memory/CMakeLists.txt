cmake_minimum_required(VERSION 3.14)

project(toy VERSION 1.0.0 LANGUAGES CXX)

find_package(LLVM REQUIRED CONFIG)

list(APPEND CMAKE_MODULE_PATH "${LLVM_DIR}")
#message(STATUS "[DEBUG] CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")

# macro "add_llvm_example"
include(AddLLVM)

add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

if(MSVC)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_FLAGS "/O2 /wd4141 /wd4146 /wd4244 /wd4267 /wd4624 /wd4996")
else()
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_FLAGS "-O2 -Wall")
endif()

set(LLVM_LINK_COMPONENTS Core)

file(GLOB SOURCE_FILES src/*.cpp src/*.h)

add_llvm_example(toy ${SOURCE_FILES})
