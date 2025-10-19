cmake_minimum_required(VERSION 3.12)      
cmake_policy(SET CMP0074 NEW)

project(riscv_cpu_yet_again_proj)


set(CXX_INCLUDE_DIRS verilator_sim)
set(CXX_SRCS verilator_sim/main.cpp)

set(VERILATOR_SRCS rtl/soc.v)
set(VERILATOR_TOP_MODULE soc)
set(VERILATOR_INCLUDE_DIRS rtl)
set(VERILATOR_ARGS --timescale 1ns/1ns -Wall -Wno-fatal -DSIM)

add_executable(riscv_cpu_yet_again ${CXX_SRCS})

set_property(TARGET riscv_cpu_yet_again PROPERTY CXX_STANDARD 20)

#find_package(Curses REQUIRED)
#target_link_libraries(riscv_cpu_yet_again PRIVATE ${CURSES_LIBRARIES})
#target_include_directories(riscv_cpu_yet_again PRIVATE ${CURSES_INCLUDE_DIRS})

target_include_directories(riscv_cpu_yet_again PRIVATE ${CXX_INCLUDE_DIRS})

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(riscv_cpu_yet_again PRIVATE -pthread -gdwarf-4 -DLinux -fPIC -Wno-deprecated -pipe -fno-elide-type
                         -fdiagnostics-show-template-tree -Wall -Wextra -Wpedantic -Wvla -Wextra-semi -Wnull-dereference
                         -Wswitch-enum -fvar-tracking-assignments -Wduplicated-cond -Wduplicated-branches -rdynamic
                         -Wsuggest-override -fstack-protector -fsanitize=address,undefined,leak)
endif()


target_link_options(riscv_cpu_yet_again PRIVATE -fsanitize=address,undefined,leak)               

add_custom_target(
        CompileExampleProj
        COMMAND make -C ${CMAKE_SOURCE_DIR}/test
        DEPENDS test/Makefile
)

add_custom_target(
        CopyKernelTxt
        DEPENDS CompileExampleProj
        COMMAND ${CMAKE_COMMAND} -E copy
                ${CMAKE_SOURCE_DIR}/test/build/kernel.txt
                ${CMAKE_CURRENT_BINARY_DIR}/kernel.txt)

add_dependencies(riscv_cpu_yet_again CopyKernelTxt)

add_custom_command(
    TARGET riscv_cpu_yet_again PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/res/reg_file.txt # the values registers are initiilized to
            ${CMAKE_CURRENT_BINARY_DIR}/reg_file.txt)

find_package(verilator)
verilate(riscv_cpu_yet_again SOURCES ${VERILATOR_SRCS} INCLUDE_DIRS ${VERILATOR_INCLUDE_DIRS} TOP_MODULE ${VERILATOR_TOP_MODULE} VERILATOR_ARGS ${VERILATOR_ARGS} TRACE)


