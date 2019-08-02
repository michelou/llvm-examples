cmake_minimum_required(VERSION 3.14)

project(llvm-hello VERSION 1.0.0 LANGUAGES CXX)

execute_process(
    # COMMAND bash -c "llvm-config --cxxflags --ldflags --system-libs --libs core"
    COMMAND bash -c "llvm-config --cxxflags"
    OUTPUT_VARIABLE LLVM_CONFIG
)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_FLAGS ${LLVM_CONFIG})

find_package(LLVM REQUIRED CONFIG)

include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

message(STATUS "LLVM installation directory: ${LLVM_INSTALL_DIR}")
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
message(STATUS "CXX Flags: ${CMAKE_CXX_FLAGS}")

file(GLOB SOURCE_FILES src/main/cpp/*.cpp src/main/cpp/*.h)

add_executable(llvm-hello ${SOURCE_FILES})

# llvm_map_components_to_libnames(llvm_libs support binaryformat core target analysis ipo)

# link_directories(${llvm_libs})

set(LIBS_PATH "${LLVM_INSTALL_DIR}/lib")
# see https://stackoverflow.com/questions/8286768/sample-cmakelists-txt-file-for-llvm-project
set (LIBS
    ${LIBS_PATH}/LLVMSupport.lib
    ${LIBS_PATH}/LLVMBinaryFormat.lib
    ${LIBS_PATH}/LLVMCore.lib
    ${LIBS_PATH}/LLVMMC.lib
    ${LIBS_PATH}/LLVMTarget.lib
    ${LIBS_PATH}/LLVMAnalysis.lib
    ${LIBS_PATH}/LLVMipo.lib
    ${LIBS_PATH}/LLVMTransformUtils.lib
    ${LIBS_PATH}/LLVMInstCombine.lib
    ${LIBS_PATH}/LLVMScalarOpts.lib
    ${LIBS_PATH}/LLVMCodeGen.lib
    ${LIBS_PATH}/LLVMExecutionEngine.lib
    ${LIBS_PATH}/LLVMMCJIT.lib
    ${LIBS_PATH}/LLVMX86Utils.lib
    ${LIBS_PATH}/LLVMX86Info.lib
    ${LIBS_PATH}/LLVMMCParser.lib
    ${LIBS_PATH}/LLVMX86AsmParser.lib
    ${LIBS_PATH}/LLVMX86AsmPrinter.lib
    ${LIBS_PATH}/LLVMAsmPrinter.lib
    ${LIBS_PATH}/LLVMSelectionDAG.lib
    ${LIBS_PATH}/LLVMX86CodeGen.lib
    ${LIBS_PATH}/LLVMX86Disassembler.lib
    ${LIBS_PATH}/LLVMInterpreter.lib
)
target_link_libraries(llvm-hello ${llvm_libs})
