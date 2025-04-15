%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap

%%
[0-9]+\.[0-9]*       { yylval.dval = atof(yytext); return NUMBER; }
[0-9]+               { yylval.dval = atof(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]* {
                        if (strcmp(yytext, "f") == 0) return DEC_FLOAT;
                        else if (strcmp(yytext, "i") == 0) return DEC_INT;
                        else if (strcmp(yytext, "p") == 0) return SHOW;
                        else {
                            yylval.sval = strdup(yytext);
                            return IDENT;
                        }
                    }
[ \t\r\n]+           ;
"//".*               ;
.                    { return yytext[0]; }
%%
