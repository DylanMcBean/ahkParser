BUILD_DIR = build
BUILD_TYPE ?= release

ifeq ($(OS),Windows_NT)
  CXX := $(shell where g++ 2>NUL && echo g++ || echo clang++)
  FLEX = win_flex.exe
  BISON = win_bison.exe
  TARGET = $(BUILD_DIR)/ahkParser.exe
  RM = del /Q
else
  CXX = g++
  FLEX = flex
  BISON = bison
  TARGET = $(BUILD_DIR)/ahkParser
  RM = rm -f
endif

ifeq ($(BUILD_TYPE),debug)
  CXXFLAGS = -std=c++23 -Wall -Wextra -g -DDEBUG_LEXER -DDEBUG_PARSER -I. -Isrc -Isrc/parser -I$(BUILD_DIR)
else
  CXXFLAGS = -std=c++23 -Wall -Wextra -O2 -I. -Isrc -Isrc/parser -I$(BUILD_DIR)
endif

SRC_DIR    = src
PARSER_DIR = $(SRC_DIR)/parser

MAIN_SRC   = $(SRC_DIR)/main.cpp
LEXER_SRC  = $(PARSER_DIR)/ahk_parser.l
PARSER_SRC = $(PARSER_DIR)/ahk_parser.y

LEXER_CPP  = $(BUILD_DIR)/ahk_lexer.cpp
PARSER_CPP = $(BUILD_DIR)/ahk_parser.cpp
PARSER_HPP = $(BUILD_DIR)/ahk_parser.hpp

all: $(TARGET)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(LEXER_CPP): $(LEXER_SRC) | $(BUILD_DIR)
	$(FLEX) -o $@ $<

$(PARSER_CPP) $(PARSER_HPP): $(PARSER_SRC) | $(BUILD_DIR)
	$(BISON) -o $(PARSER_CPP) --defines=$(PARSER_HPP) $<

$(TARGET): $(MAIN_SRC) $(LEXER_CPP) $(PARSER_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -o $@ $(MAIN_SRC) $(LEXER_CPP) $(PARSER_CPP)

clean:
ifeq ($(OS),Windows_NT)
	@if exist $(subst /,\,$(TARGET)) del /Q $(subst /,\,$(TARGET))
	@if exist $(subst /,\,$(LEXER_CPP)) del /Q $(subst /,\,$(LEXER_CPP))
	@if exist $(subst /,\,$(PARSER_CPP)) del /Q $(subst /,\,$(PARSER_CPP))
	@if exist $(subst /,\,$(PARSER_HPP)) del /Q $(subst /,\,$(PARSER_HPP))
else
	$(RM) $(TARGET) $(LEXER_CPP) $(PARSER_CPP) $(PARSER_HPP)
endif
