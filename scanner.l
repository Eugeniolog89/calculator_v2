%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;

int yylex();

void report_error(const char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
}

#define TABLE_LIMIT 100

typedef struct {
    char *identifier;
    double val;
    int category; // 0 = int, 1 = float
} entry;

entry table[TABLE_LIMIT];
int table_count = 0;

void register_entry(char *id, int category) {
    if (table_count >= TABLE_LIMIT) {
        fprintf(stderr, "Symbol table full\n");
        exit(1);
    }
    table[table_count].identifier = strdup(id);
    table[table_count].val = 0.0;
    table[table_count].category = category;
    table_count++;
}

void set_value(char *id, double val) {
    for (int i = 0; i < table_count; ++i) {
        if (strcmp(table[i].identifier, id) == 0) {
            table[i].val = val;
            return;
        }
    }
    fprintf(stderr, "Variable not declared: %s\n", id);
}

double get_value(char *id) {
    for (int i = 0; i < table_count; ++i) {
        if (strcmp(table[i].identifier, id) == 0) {
            return table[i].val;
        }
    }
    fprintf(stderr, "Variable not declared: %s\n", id);
    return 0.0;
}
%}

%union {
    double dval;
    char *sval;
}

%token <sval> IDENT
%token DEC_FLOAT DEC_INT SHOW
%token <dval> NUMBER

%type <dval> expr term factor

%%

program:
        | program line
        ;

line:
        declaration
      | assignment
      | print_cmd
      ;

declaration:
        DEC_FLOAT IDENT   { register_entry($2, 1); free($2); }
      | DEC_INT IDENT     { register_entry($2, 0); free($2); }
      ;

assignment:
        IDENT '=' expr    { set_value($1, $3); free($1); }
      ;

print_cmd:
        SHOW IDENT        { double result = get_value($2); printf("%f\n", result); free($2); }
      ;

expr:
        expr '+' term     { $$ = $1 + $3; }
      | expr '-' term     { $$ = $1 - $3; }
      | term              { $$ = $1; }
      ;

term:
        term '*' factor   { $$ = $1 * $3; }
      | term '/' factor   { 
                            if ($3 == 0) {
                                report_error("divide by zero");
                                $$ = 0.0;
                            } else {
                                $$ = $1 / $3;
                            }
                          }
      | factor            { $$ = $1; }
      ;

factor:
        '(' expr ')'      { $$ = $2; }
      | NUMBER            { $$ = $1; }
      | IDENT             { $$ = get_value($1); free($1); }
      ;

%%

int main(int argc, char *argv[]) {
    FILE *input = NULL;

    if (argc > 1) {
        input = fopen(argv[1], "r");
        if (!input) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
        yyin = input;
    }

    int status = yyparse();

    if (input) fclose(input);
    return status;
}
