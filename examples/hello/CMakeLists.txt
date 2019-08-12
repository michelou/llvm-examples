cmake_minimum_required(VERSION 3.14)

project(hello VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_STANDARD 14)
set(CMAKE_C_FLAGS "-Wall -O2")

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "-Wall -O2")

#include_directory(include)

file(GLOB SOURCES src/main/c/*.c src/main/c/*.h)
file(GLOB CPP_SOURCES src/main/cpp/*.cpp src/main/cpp/*.h)

add_executable(hello ${SOURCES})
add_executable(hello2 ${CPP_SOURCES})
