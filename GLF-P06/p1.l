%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Person {
   char  nif[10];
   float  nota[4];
};

static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;

static int pSize = 2;
static int pElems = 0;
static struct Person *persons;



extern void processLine(char *) ;
extern void printNotas() ;
extern void addNota(char*, int, float) ;
extern float notaMedia(float *) ;


%}

%%
^[0-9]{8}[a-zA-Z];[0-3];[0-9]{1,2}(.[0-9]{1,10})?$	{ processLine(yytext) ; }
.* { puts("Error");}
%%





void addNota(char nif[], int conv, float nota){
    int  i = 0;

    while ((strcmp(persons[i].nif, nif) != 0) && (i < pElems)){
        i++;
    }
    if (pElems == i){

        if (pSize == i){
            pSize = pSize*2;
            persons = realloc(persons, pSize * sizeof(struct Person));
        }

        strncpy(persons[i].nif,nif, strlen(nif));
        pElems++;
    }
    persons[i].nota[conv] = nota;
}

float notaMedia(float nota[]){
    int i;
    float media = 0;
    for (i = 0; i < 4; i++){
        media += nota[i];
    }
    return media/4;
}

void printNotas(){
    int i;
    for (i = 0; i < pElems ; i++){
        printf("NIF: %s\t Nota Media: %f\n",
            persons[i].nif, notaMedia(persons[i].nota) );
    }
}

void processLine(char uL[]) {

    static char dni[10];
    static int conv;
    static char nota[12];

    strncpy(dni, uL, 9);
    strncpy(nota, uL+12, strlen(uL)-12);

    printf(uL);
    conv = uL[9] - '0';
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

    FILE *infd ;
    if ((infd = fileReg(na, av))) {
        yyin=infd;
        printf("FICHERO: [%s]\n", fName[nfc]);
    }

    persons = malloc(pSize * sizeof(struct Person));

    yylex() ;
    addNota("12435432F", 3, 4.5);
    addNota("12435432F", 0, 4.5);
    addNota("12435432F", 1, 4.5);
    addNota("12435432F", 2, 4.5);

    addNota("12432432F", 3, 5);
    addNota("12432432F", 0, 5);
    addNota("12432432F", 1, 5);
    addNota("12432432F", 2, 5);
    addNota("12432432A", 2, 5);
    addNota("12432432B", 2, 5);


    printNotas();
}
