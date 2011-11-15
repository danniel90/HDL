#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>

using namespace std;


extern FILE *yyin;


int yyparse();

int main(int argc, char *argv[])
{
	if (argc > 0) {
		++argv, --argc; /* El primer argumento es el nombre del programa */
		yyin = fopen(argv[0], "r");

		if (yyin == NULL) {
			cerr << "No se pudo abrir el archivo " << argv[0] << endl << endl;
			return 0;
		}
	}
	else {
		cerr << "Uso: " << argv[0] << " <archivo>" << endl << endl;
		return 0;
	}

	yyparse();

	return 0;
}
