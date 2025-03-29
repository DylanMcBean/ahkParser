#include "ahk_parser.hpp"
#include <cstdio>
#include <cstdlib>

extern FILE *yyin;
extern int yyparse();
extern int yydebug;

int main(int argc, char **argv)
{
#ifdef DEBUG_PARSER
    yydebug = 1;
#endif
    if (argc < 2)
    {
        fprintf(stderr, "Usage: %s <script.ahk>\n", argv[0]);
        return EXIT_FAILURE;
    }

    FILE *file = nullptr;
    errno_t err = fopen_s(&file, argv[1], "r");
    if (err != 0 || !file)
    {
        perror("Failed to open script");
        return EXIT_FAILURE;
    }

    yyin = file;
    int parse_result = yyparse();

    fclose(file);

    if (parse_result == 0)
    {
        printf("Parsing completed successfully.\n");
        return EXIT_SUCCESS;
    }
    else
    {
        fprintf(stderr, "Parsing failed with errors.\n");
        return EXIT_FAILURE;
    }
}