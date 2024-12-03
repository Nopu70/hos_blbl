# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(myNpmLib)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(BROTLI_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include/brotli)

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

file(GLOB_RECURSE BROTLI_COMMON_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} common/*.c)
add_library(brotlicommon ${BROTLI_COMMON_SOURCES})

file(GLOB_RECURSE BROTLI_DEC_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} dec/*.c)
add_library(brotlidec ${BROTLI_DEC_SOURCES})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include
                    ${BROTLI_INCLUDE_DIRS})

add_library(brotli SHARED napi_init.cpp)
target_link_libraries(brotli PUBLIC libace_napi.z.so libhilog_ndk.z.so brotlicommon brotlidec)