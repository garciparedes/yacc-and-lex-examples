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


extern void printNotas() ;
extern void addNota(char*, int, float) ;
extern float notaMedia(float *) ;
extern void notMatch(char *, int) ;
extern void processLine();
extern void setTempDNI(char *);
extern void setTempConv(char *);
extern void setTempNotaI(char *);
extern void setTempNotaF(char *);


%}

%x NIF
%x FIRST_SLASH
%x CONV
%x SECOND_SLASH
%x NOTA
%x NOT_MATCH

%%
<INITIAL>{
    [ ]*\n              { processLine(); yylineno++; }

    ^[ ]*	            { BEGIN(NIF); }

    ^[0-9]{8}[a-zA-Z]   { setTempDNI(yytext); BEGIN(FIRST_SLASH); }

    .                   { notMatch(yytext, yylineno); }
}


<NIF>{
    [0-9]{8}[a-zA-Z]    { setTempDNI(yytext); BEGIN(FIRST_SLASH); }

    .                   { notMatch(yytext, yylineno); }
}


<FIRST_SLASH>{
    [ ]*;[ ]*	        { BEGIN(CONV); }

    .                   { notMatch(yytext, yylineno); }
}

<CONV>{
    [0-3]               { setTempConv(yytext); BEGIN(SECOND_SLASH);}

    .                   { notMatch(yytext, yylineno); }
}

<SECOND_SLASH>{
    [ ]*;[ ]*	        { BEGIN(NOTA); }

    .                   { notMatch(yytext, yylineno); }
}

<NOTA>{
    10|[0-9]            { setTempNotaI(yytext); BEGIN(INITIAL); }

    [0-9](,[0-9]+)	    { setTempNotaF(yytext); BEGIN(INITIAL); }

    .                   { notMatch(yytext, yylineno); }
}

<NOT_MATCH>{
    .*                  { printf("%s\n",yytext);BEGIN(INITIAL); }
}

%%

void notMatch(char text[], int line){
    printf("ERROR en linea %d: %s", yylineno, yytext);
    BEGIN(NOT_MATCH);
}

void setTempDNI(char text[]){
    strncpy(tempNif, text, strlen(text));
}

void setTempConv(char text[]) {
    tempConv = text[0]-'0';
}

void setTempNotaI(char text[]) {
    tempNota = atof(text);
}

void setTempNotaF(char text[]) {
    text[1] = '.';
    setTempNotaI(text);
}

void processLine() {
    //printf("NIF: %s\nCONV: %d\nNOTA: %f\n",tempNif, tempConv, tempNota );
    addNota(tempNif, tempConv, tempNota);
}
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
