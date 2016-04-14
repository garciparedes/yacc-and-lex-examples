%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;

static int nested = 0;


%}

%x CLASS
%x IN_COMMENT
%x METHOD


%%

<INITIAL>{
   ([\t\n]|.)                     ;
   ((public|private|protected|static|final|abstract|strictfp|class)[ ]+)+[a-zA-Z]+              {printf("\tClass:\t%s\n", yytext);
                                    BEGIN(CLASS);}
}

<CLASS>{
    ((public|private|protected|static|final)[ ]+)*([a-zA-Z<>]+[ ]+[a-zA-Z0-9_]+)/([ ]*(=.*)?;)       {printf("\t\tAttr:\t%s\n", yytext);}

    ((public|private|protected|static|final|abstract|strictfp|synchronized|native)[ ]+)*([a-zA-Z<>]+[ ]+)?[a-zA-Z]+[ ]*\([^\)]*\)  {printf("\t\tFunc:\t%s\n", yytext);
                                    BEGIN(METHOD);}
    (\/\/)                          ;
    [\t\n]|[^\}]                     ;
    "/*"                BEGIN(IN_COMMENT);
    "}"                 BEGIN(INITIAL);
}

<IN_COMMENT>{
    "*/"      BEGIN(CLASS);
    [^*\n]+   // eat comment in chunks
    "*"       // eat the lone star
    \n        yylineno++;
}

<METHOD>{
    "}"       {nested--; if (nested == 0 )BEGIN(CLASS);}
    [^\{\}\n]+   // eat comment in chunks
    "{"       {nested++;}
    \n        yylineno++;
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
    printf("\n");

    if ((yyin = fileReg(0, (char **)0))) {
        //printf("FICHERO: [%s]\n", fName[nfc]);
        return 0;
    }
  return 1 ;
}

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
