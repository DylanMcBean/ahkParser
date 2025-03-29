%{
#include "ahk_parser.hpp"
#include <string.h>
#include <stdio.h>

static const char* token_to_string(int token) {
    switch (token) {
        case DOUBLE_COLON:   return "DOUBLE_COLON";
        case COLON:          return "COLON";
        case LBRACE:         return "LBRACE";
        case RBRACE:         return "RBRACE";
        case HOTKEY_MOD:     return "HOTKEY_MOD";
        case FUNCTION_KEY:   return "FUNCTION_KEY";
        case NUMPAD_KEY:     return "NUMPAD_KEY";
        case MOUSE_BUTTON:   return "MOUSE_BUTTON";
        case WHEEL_KEY:      return "WHEEL_KEY";
        case ARROW_KEY:      return "ARROW_KEY";
        case NAMED_KEY:      return "NAMED_KEY";
        case JOY_BUTTON:     return "JOY_BUTTON";
        case SCANCODE:       return "SCANCODE";
        case VIRTUAL_KEY:    return "VIRTUAL_KEY";
        case KEY_UP:         return "KEY_UP";
        case KEY_DOWN:       return "KEY_DOWN";
        case KEYWORD:        return "KEYWORD";
        case STRING:         return "STRING";
        case IDENTIFIER:     return "IDENTIFIER";
        case NUMBER:         return "NUMBER";
        case INVALID:        return "INVALID";
        default:             return "UNKNOWN";
    }
}

#ifdef DEBUG_LEXER
    #define TRACE(token) printf("[LEXER] %-15s : '%s'\n", token_to_string(token), yytext); fflush(stdout)
#else
    #define TRACE(token)
#endif

static int print_token(int token) {
    TRACE(token);
    return token;
}

static void update_location() {
    int num_newlines = 0;
    for (char *c = yytext; *c; ++c) {
        if (*c == '\n') ++num_newlines;
    }
    yylloc.first_line = yylineno - num_newlines;
    yylloc.last_line = yylineno;
    yylloc.first_column = 0;
    yylloc.last_column = 0;
}
%}

%option noyywrap nounistd never-interactive yylineno

whitespace      [ \t\r\n]+
identifier      [a-zA-Z_][a-zA-Z_0-9]*
number          [0-9]+
string          \"([^\\\n]|(\\.))*?\"
double_colon    "::"
colon           ":"
scancode        SC[0-9A-Fa-f]{3}
virtual_key     VK[0-9A-Fa-f]{2}
function_key    F([1-9]|1[0-9]|2[0-4])
numpad_key      Numpad(0|1|2|3|4|5|6|7|8|9|Div|Mult|Add|Sub|Dot|Enter)
mouse_button    LButton|RButton|MButton|XButton1|XButton2
wheel_key       WheelUp|WheelDown|WheelLeft|WheelRight
arrow_key       Up|Down|Left|Right
named_key       Esc|Escape|Tab|Enter|Backspace|BS|Space|Delete|Del|Insert|Ins|Home|End|PgUp|PgDn|CapsLock|ScrollLock|PrintScreen|AppsKey|Pause|CtrlBreak|Sleep|Help
joy_button      Joy[1-9][0-9]?
keyword         return|Run|Send|MsgBox
modifier        (<|>)?([!+\^&\$~#])+(<|>)?

%%
{double_colon}      { update_location(); return print_token(DOUBLE_COLON); }
{colon}             { update_location(); return print_token(COLON); }

"{"                 { update_location(); return print_token(LBRACE); }
"}"                 { update_location(); return print_token(RBRACE); }

{modifier}          { update_location(); return print_token(HOTKEY_MOD); }
{function_key}      { update_location(); return print_token(FUNCTION_KEY); }
{numpad_key}        { update_location(); return print_token(NUMPAD_KEY); }
{mouse_button}      { update_location(); return print_token(MOUSE_BUTTON); }
{wheel_key}         { update_location(); return print_token(WHEEL_KEY); }
{arrow_key}         { update_location(); return print_token(ARROW_KEY); }
{named_key}         { update_location(); return print_token(NAMED_KEY); }
{joy_button}        { update_location(); return print_token(JOY_BUTTON); }
{scancode}          { update_location(); return print_token(SCANCODE); }
{virtual_key}       { update_location(); return print_token(VIRTUAL_KEY); }

"Up"                { update_location(); return print_token(KEY_UP); }
"Down"              { update_location(); return print_token(KEY_DOWN); }

{keyword}           { update_location(); return print_token(KEYWORD); }
{string}            { update_location(); yylval.str = _strdup(yytext); return print_token(STRING); }

{number}            { update_location(); return print_token(NUMBER); }
{identifier}        { update_location(); return print_token(IDENTIFIER); }

{whitespace}        { /* skip */ }
.                   { update_location(); return print_token(INVALID); }
%%
