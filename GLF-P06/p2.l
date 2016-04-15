/**
 * AUTOR:
 *    Sergio García Prado
 * GIT HISTORY:
 *    https://github.com/garciparedes/Lex-Examples/commits/master/GLF-P06/p2.l
 *
 * DESCRIPCIÓN:
 *    Programa LeX que tome como argumentos de línea de órdenes una lista de
 * nombres de ficheros (extensión .java, si no los ignorará). Si no se
 * especifica ningún fichero en la línea de órdenes, se usará la entrada
 * estándar. El programa debe mostrar, para cada fichero, la relación de clases
 * que se definen en el mismo, indicando el nombre de cada una. Para cada clase,
 * la relación de métodos y propiedades, por separado, indicando el nombre de
 * cada una. Deberán procesarse sólo las declaraciones que aparezcan fuera de
 * comentarios de bloque.
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;


extern void setCachedVisibility(char);

static int nested = 0;
static char cachedVisibility;

%}

%x CLASS
%x CLASS_NAME
%x IN_COMMENT
%x METHOD
%x VISIBILITY


%%

<INITIAL>{
   ([\t\n]|.)               { ; }
   (class[ ]+)              { BEGIN(CLASS_NAME);}
}


<CLASS_NAME>{
   ([\t\n]|.)               { BEGIN(INITIAL);}
   [a-zA-Z]+                { printf("\tClass:\t%s\n", yytext); BEGIN(CLASS);}
}


<CLASS>{

    (public)?               { cachedVisibility = '+'; BEGIN(VISIBILITY); }
    (private)?              { cachedVisibility = '-'; BEGIN(VISIBILITY); }
    (protected)?            { cachedVisibility = '*'; BEGIN(VISIBILITY); }
    (\/\/)                  { ; }
    [\t\n]|[^\}]            { ; }
    "/*"                    {BEGIN(IN_COMMENT);}
    "}"                     {BEGIN(INITIAL);}
}


<IN_COMMENT>{
    "*/"                    BEGIN(CLASS);
    [^*\n]+                 // eat comment in chunks
    "*"                     // eat the lone star
    \n                      yylineno++;
}


<METHOD>{
    "}"                     {nested--; if (nested == 0 )BEGIN(CLASS);}
    [^\{\}\n]+               // eat comment in chunks
    "{"                     {nested++;}
    \n                      yylineno++;
}


<VISIBILITY>{

    ([a-zA-Z<>]+[ ]+[a-zA-Z0-9_]+)/([ ]*(=.*)?;)    {printf("\t\tAttr:\t%c %s\n", cachedVisibility,yytext); BEGIN(CLASS);}

    ([a-zA-Z<>]+[ ]+)?[a-zA-Z]+[ ]*\([^\)]*\)       {printf("\t\tFunc:\t%c %s\n",cachedVisibility, yytext); BEGIN(METHOD);}
    "/*"                                            { BEGIN(IN_COMMENT); }
    [\t\n]|[^\}]                                    { ; }

}
%%



/*
 * Registra la lista de ficheros proporcionada en los argumentos
 */
FILE *fileReg(int na, char *av[]) {

    int	i;

    if (na) {
        nfc = 0 ;
        nft = na - 1 ;
        if (fName) {
            for (i=0 ; fName[i] ; i++) free(fName[i]) ;
                free(fName) ;
        }
        fName = malloc(na*sizeof(char *));
        for (i=1 ; i<na ; i++) {
            fName[i-1] = strdup(av[i]) ;
        }
        fName[na-1] = 0 ;
    } else {
        if (fd) fclose(fd) ;
        nfc++;
        if (nfc>=nft) {
            if (fName) {
                for (i=0 ; fName[i] ; i++) free(fName[i]) ;
                    free(fName) ;
            }
            return (FILE *) 0 ;
        }
    }
    return fd = fopen(fName[nfc], "r") ;
}



/*
 * Si hay más ficheros, cambia de fichero y sigue
 * Si no, indica a yylex que hay que terminar
 */
int yywrap() {
    printf("\n\n");

    if ((yyin = fileReg(0, (char **)0))) {
        //printf("FICHERO: [%s]\n", fName[nfc]);
        return 0;
    }
  return 1 ;
}


/**
 * main()
 *
 * Funcion que inicia el funcionamiento de la aplicacion.
 *
 **/
int main (int na, char *av[]) {
    char extension[6];
    int i;
    for (i=1 ; i<na ; ) {
        strncpy(extension,av[i]+strlen(av[i])-5, 5);

        if (strcmp(".java", extension)!=0){
            av[i] = av[na-1];
            na--;
        } else {
            i++;
        }
    }

    FILE *infd ;
    if ((infd = fileReg(na, av))) {
        yyin=infd;
        //printf("FICHERO: [%s]\n", fName[nfc]);
    }
    yylex() ;
}
