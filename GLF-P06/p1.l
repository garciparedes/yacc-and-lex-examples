%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>



static int nfc ;
static int nft ;
static char **fName ;
static FILE *fd;


/**
 * Struct que modeliza a una persona.
 **/
struct Person {
   char  nif[10];
   float  nota[4];
};


/**
 *
 * Estructura de datos en la cual se almacenarán las notas de las personas.
 *
 **/
static int pSize = 2;
static int pElems = 0;
static struct Person *persons;

/*
*
* Declaracion de las variables donde se aloja temporalmente el valor de cada uno
* de los campos de la linea, es decir, nif, convocatoria y nota.
*
* Notese que tal y como se ha planteado la maquina de estados no es necesario
* almacenar la nota pero se ha preferido hacer así para mantener la consistencia
*
*/
static char tempNif[10];
static int tempConv;
static float tempNota;


/**
 *
 * Definicion de metodos.
 **/
extern void printNotas() ;
extern void addNota(char*, int, float) ;
extern float notaMedia(float *) ;
extern void notMatch(char *, int) ;
extern void processLine();


/**
 *
 * Setters de las variables temporales.
 *
 **/
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



/**
 * notMatch()
 *
 * Funcion encargada de gestionar cuando no se ha llegado a la ocurrencia
 * deseada por el automata de estados.
 *
 **/
void notMatch(char text[], int line){
    printf("ERROR en linea %d: %s", yylineno, yytext);
    BEGIN(NOT_MATCH);
}



/**
 * setTempDNI()
 *
 * Setter de la variable temporal DNI
 *
 **/
void setTempDNI(char text[]){
    text[8] = toupper(text[8]);
    strncpy(tempNif, text, strlen(text));
}



/**
 * setTempConv()
 *
 * Setter de la variable temporal Convocatoria
 *
 **/
void setTempConv(char text[]) {
    tempConv = text[0]-'0';
}



/**
 * setTempNotaI()
 *
 * Setter de la variable temporal nota cuando es un valor entero.
 *
 **/
void setTempNotaI(char text[]) {
    tempNota = atof(text);
}



/**
 * setTempNotaF()
 *
 * Setter de la variable temporal nota cuando es un valor fraccionario.
 *
 **/
void setTempNotaF(char text[]) {
    text[1] = '.';
    setTempNotaI(text);
}



/**
 * processLine()
 *
 * Procedimiento que se encarga de procesar la linea completa.
 *
 **/
void processLine() {
    //printf("NIF: %s\nCONV: %d\nNOTA: %f\n",tempNif, tempConv, tempNota );
    addNota(tempNif, tempConv, tempNota);
}



/**
 * addNota()
 *
 * Funcion encargada de introducir una nueva nota en la estructura de datos.
 *
 **/
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



/**
 * notaMedia()
 *
 * Funcion encargada de calcular la nota media a partir de las 3 convocatorias.
 *
 **/
float notaMedia(float nota[]){
    int i;
    float media = 0;
    for (i = 0; i < 4; i++){
        media += nota[i];
    }
    return media/4;
}



/**
 * printNotas()
 *
 * Funcion encargada de mostrar por salida estandar la relacion entre personas
 * identificadas por NIF y su nota media.
 *
 **/
void printNotas(){
    int i;
    printf("\n");
    for (i = 0; i < pElems ; i++){
        printf("\tNIF: %s\tNota Media: %f\n",
            persons[i].nif, notaMedia(persons[i].nota) );
    }
    printf("\n");
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



/**
 * main()
 *
 * Funcion main de la aplicacion.
 *
 */
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
