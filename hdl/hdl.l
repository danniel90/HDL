%option noyywrap

%{

#include "hdl_tree.h"	//apuntador en union
#include "tokens.h"
#include <cstdlib>	//strtol()

%}

BINARY_NUMBER \^b[0|1]+

OCTAL_NUMBER \^o[0-7]+

HEXADECIMAL_NUMBER \^[1-9A-F]+

DECIMAL_NUMBER [0-9][0-9]*

IDENTIFIER [a-zA-z_][a-zA-z_0-9]*

%%

"["			{ return LEFT_BRACKET; }
"]"			{ return RIGHT_BRACKET; }
"("			{ return LEFT_PAREN; }
")"			{ return RIGHT_PAREN; }
"{"			{ return LEFT_KEY; }
"}"			{ return RIGHT_KEY; }


"!"			{ return NOT; }
"&"			{ return AND; }
"<<"			{ return SHIFT_LEFT; }
">>"			{ return SHIFT_RIGHT; }
"*"			{ return MULT; }
"/"			{ return DIV; }
"%"			{ return MOD; }
"+"			{ return ADD; }
"-"			{ return SUB; }
"#"			{ return OR; }
":+:"			{ return XOR; }
":*:"			{ return XNOR; }
"=="			{ return EQUAL; }
"!="			{ return NOT_EQUAL; }
"<"			{ return LESS; }
"<="			{ return LESS_EQUAL; }
">"			{ return GREATER; }
">="			{ return GREATER_EQUAL; }

"module"		{ return MODULE; }
"var"			{ return VAR; }
"begin"			{ return BEGIN1; }
"end"			{ return END; }
"input"			{ return INPUT; }
"output"		{ return OUTPUT; }
"temp"			{ return TEMP; }
"when"			{ return WHEN; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"function"		{ return FUNCTION; }
"truth_table"		{ return TRUTH_TABLE; }

{BINARY_NUMBER}		{
			  char *str1 = strdup(yytext);
			  size_t size = strlen(str1) + 1;

			  char *tmp = (char *)malloc(size);
			  memcpy(str1 + 2, tmp, size - 2);

			  yylval.value = strtol(tmp, &tmp, 2);
			  return BIN_NUMBER; 
			}

{OCTAL_NUMBER}		{
			  char *str1 = strdup(yytext);
			  size_t size = strlen(str1) + 1;

			  char *tmp = (char *)malloc(size);
			  memcpy(str1 + 2, tmp, size - 2);

			  yylval.value = strtol(tmp, &tmp, 8);
			  return OCT_NUMBER; 
			}

{HEXADECIMAL_NUMBER}	{
			  char *str1 = strdup(yytext);
			  size_t size = strlen(str1) + 1;

			  char *tmp = (char *)malloc(size);
			  memcpy(str1 + 2, tmp, size - 2);

			  yylval.value = strtol(tmp, &tmp, 16);
			  return HEX_NUMBER;
			}

{DECIMAL_NUMBER}	{
			  yylval.value = atol(yytext);
			  return DEC_NUMBER; 
			}

{IDENTIFIER}		{
			  yylval.lexema = strdup(yytext);
			  return ID;
			}

[ \t\n]+		/* nada */

