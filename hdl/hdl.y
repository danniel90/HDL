%{

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>

#include "hdl_tree.h"

#include "tokens.h"

using namespace std;

#define YYERROR_VERBOSE 1

int yylex();

void yyerror(const char *message)
{
    cerr << message << "\n";
    exit(1);
}

%}

%union{
	char *lexema;
	long value;
} 

%token MODULE VAR END INPUT OUTPUT TEMP WHEN THEN ELSE FUNCTION TRUTH_TABLE BEGIN1
%token LEFT_BRACKET RIGHT_BRACKET LEFT_PAREN RIGHT_PAREN LEFT_KEY RIGHT_KEY DOT COMMA SEMI COLON ARROW 
%token NOT AND SHIFT_LEFT SHIFT_RIGHT MULT DIV MOD ADD SUB OR XOR XNOR EQUAL NOT_EQUAL LESS LESS_EQUAL GREATER GREATER_EQUAL ASSIGN

%token<value> BIN_NUMBER OCT_NUMBER DEC_NUMBER HEX_NUMBER
%token<lexema> ID

%type<value> expr expr_xnor expr_xor expr_or expr_add expr_mult expr_shift expr_and factor term

%%

/*==================================================================================
				EXPRESIONES
==================================================================================*/

expr:	expr LESS 		expr_xnor		{ $$ = $1 < $3; }
	|expr LESS_EQUAL 	expr_xnor		{ $$ = $1 <= $3; }
	|expr GREATER		expr_xnor		{ $$ = $1 > $3; }
	|expr GREATER_EQUAL	expr_xnor		{ $$ = $1 >= $3; }
	|expr EQUAL		expr_xnor		{ $$ = $1 == $3; }
	|expr NOT_EQUAL		expr_xnor		{ $$ = $1 != $3; }
	|expr_xnor					{ $$ = $1; }
;

expr_xnor:	expr_xnor XNOR expr_xor			{ $$ = !($1 ^ $3); }
		|expr_xor				{ $$ = $1; }
;

expr_xor:	expr_xor XOR expr_or			{ $$ = $1 ^ $3; }
		|expr_or				{ $$ = $1; }
;

expr_or:	expr_or OR expr_add			{ $$ = $1 | $3; }
		|expr_add				{ $$ = $1; }
;

expr_add:	expr_add ADD expr_mult			{ $$ = $1 + $3; }
		|expr_add SUB expr_mult			{ $$ = $1 - $3; }
		|expr_mult				{ $$ = $1; }
;

expr_mult:	expr_mult MULT expr_shift		{ $$ = $1 * $3; }
		|expr_mult DIV expr_shift		{ $$ = $1 / $3; }
		|expr_mult MOD expr_shift		{ $$ = $1 % $3; }
		|expr_shift				{ $$ = $1; }
;

expr_shift:	expr_shift SHIFT_LEFT expr_and		{ $$ = $1 << $3; }
		|expr_shift SHIFT_RIGHT expr_and	{ $$ = $1 >> $3; }
		|expr_and				{ $$ = $1; }
;

expr_and:	expr_and AND factor			{ $$ = $1 & $3; }
		|factor					{ $$ = $1; }
;

factor:		SUB term				{ $$ = -$2; }
		|NOT term				{ $$ = ~$2; }
		|term					{ $$ = $1; }
;

term:		LEFT_PAREN expr RIGHT_PAREN		{ $$ = $2; }
		|ID					{ $$ = 1; }
		|BIN_NUMBER				{ $$ = $1; }
		|OCT_NUMBER				{ $$ = $1; }
		|HEX_NUMBER				{ $$ = $1; }
		|DEC_NUMBER				{ $$ = $1; }
;
