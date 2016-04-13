%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;




%}

%%
([\t\n]|.)                      ;
((class[ ]+)[a-zA-Z]+)          {printf("\tC: %s\n", yytext);}
([a-zA-Z]+[ ]+[a-zA-Z]+;)       {printf("\t\tA: %s\n", yytext);}
([a-zA-Z]+[ ]+[a-zA-Z]+\(.*\))  {printf("\t\tF: %s\n", yytext);}
(\/\*[.\n\t]*\/\*)              ;
(\/\/)                          ;


%%

void addclass(char className[]){
}


void addMethod(char className[], char methodName[]){

}

void addAttr(char className[], char attrName[]){

}



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
  if ((yyin = fileReg(0, (char **)0))) {
     printf("FICHERO: [%s]\n", fName[nfc]);
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
        printf("FICHERO: [%s]\n", fName[nfc]);
    }
    yylex() ;
}
