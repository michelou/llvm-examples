cmake_minimum_required(VERSION 3.14)

# see https://cmake.org/cmake/help/v3.14/command/project.html
project(hello VERSION 1.0.0 LANGUAGES C)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS "/Wall /O2")

#include_directory(include)

file(GLOB SOURCES src/main/c/*.c src/main/c/*.h)

add_executable(hello ${SOURCES})


############# INTROS / TUTORIALS ############
##
## http://derekmolloy.ie/hello-world-introductions-to-cmake/
## https://www.jetbrains.com/help/clion/quick-cmake-tutorial.html
## https://www.johnlamp.net/cmake-tutorial.html
##
##############################################################################