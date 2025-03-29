#pragma once

typedef struct YYLTYPE
{
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

extern YYLTYPE yylloc;

enum yytokentype
{
    DOUBLE_COLON,
    COLON,
    LBRACE,
    RBRACE,
    HOTKEY_MOD,
    FUNCTION_KEY,
    NUMPAD_KEY,
    MOUSE_BUTTON,
    WHEEL_KEY,
    ARROW_KEY,
    NAMED_KEY,
    JOY_BUTTON,
    SCANCODE,
    VIRTUAL_KEY,
    KEY_UP,
    KEY_DOWN,
    KEYWORD,
    STRING,
    NUMBER,
    IDENTIFIER,
    INVALID
};
