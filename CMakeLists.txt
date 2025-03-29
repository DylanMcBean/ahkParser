cmake_minimum_required(VERSION 3.10.0)
project(ahkParser VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 23)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)

flex_target(ahkLexer ${SRC_DIR}/parser/ahk_parser.l ${CMAKE_CURRENT_BINARY_DIR}/ahk_lexer.cpp)
bison_target(ahkParser
    ${SRC_DIR}/parser/ahk_parser.y
    ${CMAKE_CURRENT_BINARY_DIR}/ahk_parser.cpp
    DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/ahk_parser.hpp
)

add_flex_bison_dependency(ahkLexer ahkParser)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${SRC_DIR}
    ${SRC_DIR}/parser
)

add_executable(ahkParser
    ${SRC_DIR}/main.cpp
    ${BISON_ahkParser_OUTPUTS}
    ${FLEX_ahkLexer_OUTPUTS}
)

# Automatically enable lexer/parser debug in Debug builds
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    message(STATUS "Debug build: enabling DEBUG_LEXER and DEBUG_PARSER")
    target_compile_definitions(ahkParser PRIVATE DEBUG_LEXER DEBUG_PARSER)
endif()

