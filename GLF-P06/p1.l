%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Person {
   char  nif[50];
   double  nota[4];
};

static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;
static int pSize = 100;
static struct Person *persons;


extern char rotaUpp(char, char) ;
extern char rotaLow(char, char) ;
extern char rotaEsp(char *, char, char) ;
extern char *proof(char *) ;


%}

%%
^[0-9]{8}[a-zA-Z];[0-3];[0-9]{1,2}(.[0-9]{1,10})?$	{ printf(proof(yytext)) ; }
.* { puts("Error");}
%%





void addNota(char nif[], int conv, double nota){
    int  i = 0;

    while (persons[i].nif != nif){
        i++;
    }
}

char *proof(char uL[]) {

    static char dni[10];
    static int conv;
    static char nota[12];

    strncpy(dni, uL, 9);
    strncpy(nota, uL+12, strlen(uL)-12);


    conv = uL[9] - '0';

    return nota;

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
  if (yyin = fileReg(0, (char **)0)) {
     printf("FICHERO: [%s]\n", fName[nfc]);
     return 0;
  }
  return 1 ;
}

int main (int na, char *av[]) {

  FILE *infd ;
  if (infd = fileReg(na, av)) {
     yyin=infd;
     printf("FICHERO: [%s]\n", fName[nfc]);
  }
  persons = malloc(pSize * sizeof(struct Person));
  yylex() ;

}
