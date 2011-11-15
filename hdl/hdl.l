%option noyywrap

%{

#include <cstdlib>	//strtol()
#include "hdl_tree.h"	//apuntador en union
#include "tokens.h"

%}

IDENTIFIER		[a-zA-Z_][a-zA-Z_0-9]*

NUM_SIZE		"^"[0-9]

BIN_NUM			"^b"[01]+
BIN_NUM2		"b"[01]+

OCT_NUM			"^o"[0-7]+
OCT_NUM2		"o"[0-7]+

DEC_NUM			"^d"[0-9]+
DEC_NUM2		"d"[0-9]+

HEX_NUM			"^h"[0-9A-Z]+
HEX_NUM2		"h"[0-9A-Z]+

NUM			[0-9]+

%%

"["			{ return LEFT_BRACKET; }
"]"			{ return RIGHT_BRACKET; }
"("			{ return LEFT_PAREN; }
")"			{ return RIGHT_PAREN; }
"{"			{ return LEFT_KEY; }
"}"			{ return RIGHT_KEY; }
"."			{ return DOT; }
","			{ return COMMA; }
";"			{ return SEMI; }
":"			{ return COLON; }
"->"			{ return ARROW; }

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
"="			{ return ASSIGN; }

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

{NUM_SIZE}		{
			  char *tmp = yytext;
			  yylval.size = atoi(tmp + 1);
//			  printf("SIZE : %i\n", yylval.size);
			  return SIZE;
			}

{BIN_NUM}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 2, &tmp, 2);
//			  printf("BIN : %li\n", yylval.value);			  
			  return NUMBER;
			}

{BIN_NUM2}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 1, &tmp, 2);
//			  printf("BIN2 : %li\n", yylval.value);
			  
			  return NUMBER;
			}

{OCT_NUM}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 2, &tmp, 8);
//			  printf("OCT : %li\n", yylval.value);
			  return NUMBER;
			}

{OCT_NUM2}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 1, &tmp, 8);
//			  printf("OCT2 : %li\n", yylval.value);
			  return NUMBER;
			}

{DEC_NUM}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 2, &tmp, 10);
//			  printf("DEC : %li\n", yylval.value);
			  return NUMBER;
			}

{DEC_NUM2}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 1, &tmp, 10);
//			  printf("DEC2 : %li\n", yylval.value);
			  return NUMBER;
			}

{HEX_NUM}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 2, &tmp, 16);
//			  printf("HEX : %li\n", yylval.value);
			  return NUMBER;
			}

{HEX_NUM2}		{
			  char *tmp = yytext;
			  yylval.value = strtol(tmp + 1, &tmp, 16);
//			  printf("HEX2 : %li\n", yylval.value);
			  return NUMBER;
			}

{NUM}			{
			  yylval.value = atoi(yytext);
//			  printf("DEC : %li\n", yylval.value);
			  return NUMBER;
			}

{IDENTIFIER}		{ 
			  yylval.lexema = strdup(yytext);
//			  printf("ID : %s\n",yylval.lexema);
			  return ID;
			}

[ \t\n]+		{ /* nada */ }

.			{ printf("\n\nERROR!!!\n\n"); }

