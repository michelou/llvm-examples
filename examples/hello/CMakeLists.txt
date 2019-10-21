cmake_minimum_required(VERSION 3.14)

project(hello VERSION 1.0.0 LANGUAGES C CXX)

if(MSVC)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_FLAGS "/O2 /EHsc /wd4141 /wd4146 /wd4244 /wd4267 /wd4624 /wd4996")
else()
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_FLAGS "-O2 -Wall")
endif()

file(GLOB C_SOURCES src/main/c/*.c src/main/c/*.h)
file(GLOB CPP_SOURCES src/main/cpp/*.cpp src/main/cpp/*.h)

add_executable(hello ${C_SOURCES})
add_executable(hello2 ${CPP_SOURCES})
