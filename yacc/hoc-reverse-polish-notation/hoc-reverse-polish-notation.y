/**
 * AUTHOR:
 *    Sergio García Prado
 * GIT HISTORY:
 *    https://github.com/garciparedes/yacc-and-lex-examples/commits/master/yacc/hoc-reverse-polish-notation
 *
 * DESCRIPCIÓN:
 *    Se pide diseñar una gramática para una calculadora aritmética en Notación
 * Polaca Inversa y construir el analizador sintáctico en YACC que reconozca y
 * evalúe las expresiones correctas en dicha notación. Al menos deberá soportar
 * suma, resta, producto, división, potencia y cambio de signo. Debe entregar un
 * breve informe (readme.txt o readme.doc) acompañando el código, en el que
 * describa la gramática y comente la estructura del código construído para
 * implementarla en YACC.
 */


%{
#define	YYSTYPE	double 	/* data type of yacc stack */
#include <math.h>       /* pow */
#include <stdio.h>
#include <ctype.h>
%}
%token	NUMBER
%%

list:	  /* nothing */
	| list '\n'
	| list expr '\n'	{ printf("\t%.8g\n", $2); }
	;
expr:	  NUMBER	{ $$ = $1; }
	| expr expr	'+' { $$ = $1 + $2; }
	| expr expr '-' { $$ = $1 - $2; }
	| expr expr '*'	{ $$ = $1 * $2; }
	| expr expr '/'	{ $$ = $1 / $2; }
	| expr expr '^'	{ $$ = pow($1,$2); }
	|      expr 'm' { $$ = -$1; } /* new */
	;
%%
	/* end of grammar */

char	*progname;	/* for error messages */
int	lineno = 1;

main(argc, argv)
	char *argv[];
{
	progname = argv[0];
	yyparse();
}

yylex()
{
	int c;

	while ((c=getchar()) == ' ' || c == '\t')
		;
	if (c == EOF)
		return 0;
	if (c == '.' || isdigit(c)) {	/* number */
		ungetc(c, stdin);
		scanf("%lf", &yylval);
		return NUMBER;
	}
	if (c == '\n')
		lineno++;
	return c;
}

yyerror(s)
	char *s;
{
	warning(s, (char *)0);
}

warning(s, t)
	char *s, *t;
{
	fprintf(stderr, "%s: %s", progname, s);
	if (t && *t)
		fprintf(stderr, " %s", t);
	fprintf(stderr, " near line %d\n", lineno);
}
