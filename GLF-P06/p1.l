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

static char tempNif[10];
static int tempConv;
static float tempNota;


extern char *processLine(char *) ;
extern void printNotas() ;
extern void addNota(char*, int, float) ;
extern float notaMedia(float *) ;


%}

%x NIF
%x FIRST_SLASH
%x CONV
%x SECOND_SLASH
%x NOTA
%x ERROR

%%
<INITIAL>{
    [ ]*\n          {yylineno++; printf("%d\n",yylineno );}
    ^[ ]*	{ printf("%s\n",yytext); BEGIN(NIF);}
    ^[0-9]{8}[a-zA-Z]	{ printf("NIF: %s\n",yytext); BEGIN(FIRST_SLASH);}
    .                   {BEGIN(ERROR);}
}


<NIF>{
    [0-9]{8}[a-zA-Z]	{ printf("NIF: **%s**\n",yytext); BEGIN(FIRST_SLASH);}
    .                   {BEGIN(ERROR);}
}


<FIRST_SLASH>{
    [ ]*;[ ]*	{ printf("FIRST_SLASH: %s\n",yytext); BEGIN(CONV);}
    .                   {BEGIN(ERROR);}
}

<CONV>{
    [0-3]	{ printf("CONV: **%s**\n",yytext); BEGIN(SECOND_SLASH);}
    .                   {BEGIN(ERROR);}
}

<SECOND_SLASH>{
    [ ]*;[ ]*	{ printf("SECOND_SLASH: %s\n",yytext); BEGIN(NOTA);}
    .                   {BEGIN(ERROR);}
}

<NOTA>{
    (10|([0-9](,[0-9]+)?))	{ printf("NOTA: **%s**\n\n",yytext); BEGIN(INITIAL);}
    .                   {BEGIN(ERROR);}
}

<ERROR>{
    .*                   {printf("ERROR en linea %d: %s\n", yylineno, yytext); BEGIN(INITIAL);}
}

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

char* processLine(char line[]) {

    char nif[10];
    int conv;
    char nota[12];
    float notaf;

    strncpy(nif, line, 9);

    conv = line[10] - '0';
    strncpy(nota, line+12, strlen(line)-12);

    int i = 0;

    for (i = 0; i< strlen(nota); i++){
        if (nota[i] == ','){
            nota[i] = '.';
            break;
        }
    }


    notaf = atof(nota);

    addNota(nif, conv, notaf);
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
