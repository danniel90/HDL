%{

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

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
	bool binary;
	long value;
	Expr *expr;
	vectorExpr *exprs;
	Statement *statement;
	vectorBool *bools;
	vectorId *ids;
	TruthTableElem *TTelem;
	Sentence *sntnce;
	TruthTable *tt;
	Tipo *tipo;
	MetaType *metatype;
	vectorMetaType *metatypes;
	VariableDeclarationList *variables;
	Program *prgm;
} 

%token MODULE VAR END INPUT OUTPUT TEMP WHEN THEN ELSE FUNCTION TRUTH_TABLE BEGIN1
%token LEFT_BRACKET RIGHT_BRACKET LEFT_PAREN RIGHT_PAREN LEFT_KEY RIGHT_KEY DOT COMMA SEMI COLON ARROW
%token NOT AND SHIFT_LEFT SHIFT_RIGHT MULT DIV MOD ADD SUB OR XOR XNOR EQUAL NOT_EQUAL LESS LESS_EQUAL GREATER GREATER_EQUAL ASSIGN

%token<value> BIN_NUMBER OCT_NUMBER DEC_NUMBER HEX_NUMBER NUMBER
%token<lexema> ID
%token<binary> ZERO ONE

%type<expr> expr expr_xnor expr_xor expr_or expr_add expr_mult expr_shift expr_and factor term
%type<exprs> expr_list

%type<statement> statement_list statement assign_statement when_statement opt_else function_body truth_table
%type<ids> id_list

%type<bools> binary_number_list
%type<binary> binary_number

%type<TTelem> truth_table_row
%type<tt> truth_table_list

%type<sntnce> function_declaration function_declaration_list


%type<variables> variable_declaration_list
%type<metatypes> variables_list variable_declaration
%type<metatype> variable
%type<tipo> variable_class

%type<prgm> program
%%

/*==================================================================================
				PROGRAMA
==================================================================================*/

program:	MODULE ID
		VAR variable_declaration_list function_declaration_list
		BEGIN1 statement_list END							{ $$ = new Program($2, $4, $5, $7); }
;

/*===============================================
	DECLARACION DE VARIABLES
=================================================*/

variable_declaration_list:	variable_declaration						{
												  VariableDeclarationList *vars = new VariableDeclarationList();
												  vectorMetaType *mtypes = $1;
												  for (int x = 0; x < mtypes->metatypes->size(); x++){
													MetaType *mt = mtypes->metatypes->at(x);
													vars->tabla->insert(pair<string, MetaType*>(mt->lexeme, mt));
												  }
												  $$ = vars;
												}
				|variable_declaration variable_declaration_list			{
												  VariableDeclarationList *vars = $2;
												  vectorMetaType *mtypes = $1;
												  for (int x = 0; x < mtypes->metatypes->size(); x++){
													MetaType *mt = mtypes->metatypes->at(x);
													vars->tabla->insert(pair<string, MetaType*>(mt->lexeme, mt));
												  }
												  $$ = vars;
												}
;

variable_declaration:		variables_list COLON variable_class SEMI			{
												  vectorMetaType *mtypes = $1;
												  for (int x = 0; x < mtypes->metatypes->size(); x++)
													mtypes->metatypes->at(x)->tipo = $3;
												  $$ = mtypes;
												}
;

variables_list:			variable							{
												  vectorMetaType *vec = new vectorMetaType();
												  vec->metatypes->push_back($1);
												  $$ = vec;
												}
				|variables_list COMMA variable					{
												  vectorMetaType *vec = $1;
												  vec->metatypes->push_back($3);
												  $$ = vec;
												}
;

variable:			ID								{ $$ = new IdMetaType($1, NULL); }
				|ID LEFT_BRACKET DEC_NUMBER DOT DOT DEC_NUMBER RIGHT_BRACKET	{ $$ = new ArrayMetaType($1, NULL, $3, $6); }
;

variable_class:			INPUT								{ $$ = new Input(); }
				|OUTPUT								{ $$ = new Output(); }
				|TEMP								{ $$ = new Temp(); }
;

/*===============================================
	DECLARACION DE FUNCIONES
=================================================*/

function_declaration_list:									{ $$ = NULL; }
				|function_declaration function_declaration_list			{ $$ = new SequenceSntnce($1, $2); }
;

function_declaration:		FUNCTION ID COLON LEFT_BRACKET id_list RIGHT_BRACKET ARROW 
				LEFT_BRACKET id_list RIGHT_BRACKET
				BEGIN1 function_body END					{
												  $$ = new FunctionSntnce($2,$5,$9,$12);
												}
;

id_list:		ID									{
												  vectorId *ids = new vectorId();
												  ids->ids->push_back($1);
												  $$ = ids;
												}
			|id_list COMMA ID							{
												  vectorId *ids = $1;
												  ids->ids->push_back($3);
												  $$ = ids;
												}
;

function_body:		truth_table								{ $$ = $1; }
			|statement_list								{ $$ = $1; }
;

truth_table: 		TRUTH_TABLE LEFT_KEY truth_table_list	RIGHT_KEY			{ $$ = new TruthTableStmnt($3); }
;

truth_table_list:	truth_table_row								{
												  TruthTable *tt = new TruthTable();
												  tt->row->push_back($1);
												  $$ = tt;				
												}
			|truth_table_list truth_table_row					{
												  TruthTable *tt = $1;
												  tt->row->push_back($2);
												  $$ = tt;
												}
;

truth_table_row:	LEFT_BRACKET binary_number_list RIGHT_BRACKET ARROW
			LEFT_BRACKET binary_number_list RIGHT_BRACKET				{ $$ = new TruthTableElem($2, $6); }
;

binary_number_list:	binary_number								{
												  vectorBool *bools = new vectorBool();
												  bools->bools->push_back($1);
												  $$ = bools;
												}
			|binary_number_list COMMA binary_number					{
												  vectorBool *bools = $1;
												  bools->bools->push_back($3);
												  $$ = bools;
												}
;

binary_number:		ZERO									{ $$ = $1; }
			|ONE									{ $$ = $1; }
;

/*===============================================
		STATEMENTS
=================================================*/

statement_list:		statement							{ $$ = $1; }
			|statement statement_list					{ $$ = new StatementSeq($1, $2); }
;

statement:		assign_statement SEMI						{ $$ = $1; }
			|when_statement SEMI						{ $$ = $1; }
;

assign_statement:	expr ASSIGN expr						{ $$ = new AssignStmnt($1, $3); }
;

when_statement:		WHEN expr THEN statement_list opt_else				{ $$ = new WhenStmnt($2, $4, $5); }
;

opt_else:										{ $$ = NULL; }
			|ELSE statement_list						{ $$ = $2; }
;


/*==================================================================================
				EXPRESIONES
==================================================================================*/

/*expr_prog:	expr								{ cout << $1->eval() << endl; }
;*/

expr_list:	expr								{
										  vectorExpr *exprList = new vectorExpr();
										  exprList->exprs->push_back($1);
										  $$ = exprList;
										}
		|expr_list COMMA expr						{
										  vectorExpr *exprList = $1;
										  exprList->exprs->push_back($3);
										  $$ = exprList;
										}
;

expr:		expr LESS 		expr_xnor				{ $$ = new LessExpr($1, $3); }
		|expr LESS_EQUAL 	expr_xnor				{ $$ = new LessEqualExpr($1, $3); }
		|expr GREATER		expr_xnor				{ $$ = new GreaterExpr($1, $3); }
		|expr GREATER_EQUAL	expr_xnor				{ $$ = new GreaterExpr($1, $3); }
		|expr EQUAL		expr_xnor				{ $$ = new EqualExpr($1, $3); }
		|expr NOT_EQUAL		expr_xnor				{ $$ = new NotEqualExpr($1, $3); }
		|expr_xnor							{ $$ = $1; }
;

expr_xnor:	expr_xnor XNOR expr_xor						{ $$ = new XnorExpr($1, $3); }
		|expr_xor							{ $$ = $1; }
;

expr_xor:	expr_xor XOR expr_or						{ $$ = new XorExpr($1, $3); }
		|expr_or							{ $$ = $1; }
;

expr_or:	expr_or OR expr_add						{ $$ = new OrExpr($1, $3); }
		|expr_add							{ $$ = $1; }
;

expr_add:	expr_add ADD expr_mult						{ $$ = new AddExpr($1, $3); }
		|expr_add SUB expr_mult						{ $$ = new SubExpr($1, $3); }
		|expr_mult							{ $$ = $1; }
;

expr_mult:	expr_mult MULT expr_shift					{ $$ = new MultExpr($1, $3); }
		|expr_mult DIV expr_shift					{ $$ = new DivExpr($1, $3); }
		|expr_mult MOD expr_shift					{ $$ = new ModExpr($1, $3); }
		|expr_shift							{ $$ = $1; }
;

expr_shift:	expr_shift SHIFT_LEFT expr_and					{ $$ = new ShiftLeftExpr($1, $3); }
		|expr_shift SHIFT_RIGHT expr_and				{ $$ = new ShiftRightExpr($1, $3); }
		|expr_and							{ $$ = $1; }
;

expr_and:	expr_and AND factor						{ $$ = new AndExpr($1, $3); }
		|factor								{ $$ = $1; }
;

factor:		SUB term							{ $$ = new NegateExpr($2); }
		|NOT term							{ $$ = new NotExpr($2); }
		|term								{ $$ = $1; }
;

term:		LEFT_PAREN expr RIGHT_PAREN					{ $$ = $2; }
		|BIN_NUMBER							{ $$ = new BinNumExpr($1); }
		|OCT_NUMBER							{ $$ = new OctNumExpr($1); }
		|HEX_NUMBER							{ $$ = new HexNumExpr($1); }
		|DEC_NUMBER							{ $$ = new DecNumExpr($1); }
		|NUMBER								{ $$ = new DecNumExpr($1); }
		|ID								{ $$ = new IdExpr($1); }
		|ID LEFT_BRACKET DEC_NUMBER RIGHT_BRACKET			{ $$ = new ArrayIndexExpr($1, $3); }
		|ID LEFT_BRACKET DEC_NUMBER DOT DOT DEC_NUMBER RIGHT_BRACKET	{ $$ = new ArraySubSetExpr($1, $3, $6); }
		|LEFT_BRACKET expr_list RIGHT_BRACKET				{ $$ = new SetExpr($2); }
		|ID LEFT_PAREN expr_list RIGHT_PAREN				{ $$ = new FuncCallExpr($1, $3); }
;


