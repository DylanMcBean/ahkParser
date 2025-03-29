%{
#include <stdio.h>
#include <stdlib.h>
#include "ahk_parser.hpp"

extern int yylex(void);
extern YYLTYPE yylloc;
void yyerror(const char* s);

#ifdef DEBUG_PARSER
    #define TRACE_NODE(msg) printf("[PARSER] %s at line %d\n", msg, yylloc.first_line); fflush(stdout)
    #define TRACE_NODEF(fmt, ...) printf("[PARSER] " fmt " at line %d\n", __VA_ARGS__, yylloc.first_line); fflush(stdout)
#else
    #define TRACE_NODE(msg)
    #define TRACE_NODEF(fmt, ...)
#endif
%}

%locations
%defines
%define parse.error verbose
%debug

%union {
    int   num;
    char* str;
}

%token <str> STRING IDENTIFIER KEYWORD
%token <num> NUMBER
%token COLON DOUBLE_COLON HOTKEY_MOD
%token LBRACE RBRACE INVALID
%token FUNCTION_KEY NUMPAD_KEY MOUSE_BUTTON WHEEL_KEY ARROW_KEY NAMED_KEY JOY_BUTTON SCANCODE VIRTUAL_KEY
%token KEY_UP KEY_DOWN
%token SPECIAL_KEY

%%

program:
      /* empty */                    { TRACE_NODE("program (empty)"); }
    | program hotkey_statement       { TRACE_NODE("program (append hotkey_statement)"); }
    ;

hotkey_statement:
    hotkey_prefix DOUBLE_COLON hotkey_body { TRACE_NODE("hotkey_statement"); }
    ;

hotkey_prefix:
      modifiers key_name             { TRACE_NODE("hotkey_prefix (modifiers + key_name)"); }
    | key_name                       { TRACE_NODE("hotkey_prefix (key_name)"); }
    ;

modifiers:
      /* empty */                    { TRACE_NODE("modifiers (empty)"); }
    | modifiers HOTKEY_MOD           { TRACE_NODE("modifiers (add HOTKEY_MOD)"); }
    ;

key_name:
      IDENTIFIER                     { TRACE_NODEF("key_name IDENTIFIER='%s'", $1); }
    | NUMBER                         { TRACE_NODEF("key_name NUMBER=%d", $1); }
    | SPECIAL_KEY                    { TRACE_NODE("key_name SPECIAL_KEY"); }
    | FUNCTION_KEY                   { TRACE_NODE("key_name FUNCTION_KEY"); }
    | NUMPAD_KEY                     { TRACE_NODE("key_name NUMPAD_KEY"); }
    | MOUSE_BUTTON                   { TRACE_NODE("key_name MOUSE_BUTTON"); }
    | WHEEL_KEY                      { TRACE_NODE("key_name WHEEL_KEY"); }
    | ARROW_KEY                      { TRACE_NODE("key_name ARROW_KEY"); }
    | NAMED_KEY                      { TRACE_NODE("key_name NAMED_KEY"); }
    | JOY_BUTTON                     { TRACE_NODE("key_name JOY_BUTTON"); }
    | SCANCODE                       { TRACE_NODE("key_name SCANCODE"); }
    | VIRTUAL_KEY                    { TRACE_NODE("key_name VIRTUAL_KEY"); }
    ;

hotkey_body:
      LBRACE RBRACE                  { TRACE_NODE("hotkey_body (empty block)"); }
    | LBRACE statements RBRACE       { TRACE_NODE("hotkey_body (statements block)"); }
    | expression                     { TRACE_NODE("hotkey_body (expression)"); }
    ;

statements:
      statement                      { TRACE_NODE("statements (single)"); }
    | statements statement           { TRACE_NODE("statements (append)"); }
    ;

statement:
    expression ';'                   { TRACE_NODE("statement"); }
    ;

expression:
      IDENTIFIER                     { TRACE_NODEF("expression IDENTIFIER='%s'", $1); }
    | NUMBER                         { TRACE_NODEF("expression NUMBER=%d", $1); }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error at line %d: %s\n", yylloc.first_line, s);
}