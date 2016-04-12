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



extern char *processLine(char *) ;
extern void printNotas() ;
extern void addNota(char*, int, float) ;
extern float notaMedia(float *) ;


%}

%%
^[0-9]{8}[a-zA-Z];[0-3];(10|([0-9](.[0-9]{1,10})?))$	{ processLine(yytext) ; }
.* {puts("error");}
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

char* processLine(char uL[]) {

    char dni[10];
    int conv;
    char nota[12];
    float notaf;
    //printf("%s\n",uL);

    strncpy(dni, uL, 9);
    //printf("%s\n",dni);

    conv = uL[10] - '0';
    //printf("%i\n",conv);

    strncpy(nota, uL+12, strlen(uL)-12);
    notaf = atof(nota);
    //printf("%f\n",notaf);

    addNota(dni, conv, atof(nota));
    return "";
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


    printNotas();
}
