%{
/******** INCLUDES **********/
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
#include "inc\primitivas_pila_dinamica.c"
#include "y.tab.h"
/****************************/

/********* DEFINES Y VARS GLOBALES ************/
int yystopparser=0;
FILE *yyin;
void exportarTablas();
/**********************************************/

/****** ELEMENTOS DE LAS PILAS  *********/
t_pila pilaPos;
t_pila pilaRepeat;
t_pila pilaFiltro;
/**********************************/

/************* ELEMENTOS NECESARIOS PARA TERCERTOS ********/
typedef struct
{
   int indice;      //INDICE DE TERCETO
   char dato1[40];  //OPERACION
   char dato2[40];  //OPERADOR1
   char dato3[40];  //OPERADOR2
} regTerceto;

regTerceto terceto;
regTerceto tablaTerceto[2048];

int numeroTerceto = 0;
char valorConstante[50];
char aux1[31], aux2[31], opSalto[6];

int indice_constante;
int indice_termino;
int indice_factor;
int indice_expresion;

int indice_condicion;
int indice_condicionI;
int indice_condicionD;

int indice_comparacion;
int indice_comparacionD;
int indice_comparacionI;

int indice_repeat;
int indice_filtro;

int indice_out;
int indice_in;

int indice_if;

int crearTerceto(char *operador, char *operando1, char *operando2);
void mostrarTerceto();
void modificarTerceto(int posicion, int inc);
char* negarSalto(char* operadorSalto);
/**********************************************************************/

/****************** ELEMENTOS NECESARIOS PARA IDS *********************/
#define MAX_IDS 20
typedef struct
{
   char nombre[31];
   char tipo[31];
   char valor[31];
   char longitud[5];
} regId;

regId tablaId[2048];
int numeroId = 0;

char cadAux[50];
char ids[MAX_IDS][32];
char tipoid[MAX_IDS][32];
int cantIds = 0;
int canttipos = 0;

int idAsig1;
int idAsig2;

void insertarIDs();
void mostrarID();
int existeID(char* id);
void insertarConstante(char* nombre, char* tipo, char* valor);
/***********************************************************************/

/*                   ELEMENTOS NECESARIOS PARA ASSEMBLER               */

regTerceto tercetoArchivo;
typedef struct {
  char aux[20];
  int indice;
}tipoTercetoAsm;

int indiceTerceto = 0;
char underscore[50];
char aux[10];
char cteAux[50];
tipoTercetoAsm tercetoLeido[2048];

void generarAssembler(void);
void crearTercetoAsm(int ind, char *varAux);
void crearFloat(char *); /* funcion para cambiar los puntos de una variable
int tipoElemento(char *); // funcion para obtener el tipo del elemento
                           float a un _ para poder llamarla como cte sin nombre */
void crearInstruccion(FILE *,char *,char *,char *, char *);
/* Condensa la funcion fprintf con un formato ""%s\t%s\t%s\t%s\n" */
void leerTerceto(char*);
/* Recibe una linea del archivo de tercetos, y lo pasa a la estructura de tercetos */
void generarAssembler();
void imprimirVariablesASM(FILE *);
void imprimirCabeceraASM(FILE *);
void imprimirCabeceraCodeASM(FILE *);
void crearValor(FILE *);
void recorrerTercetos(FILE *);
void crearFADD(FILE *);
void crearFSUB(FILE *);
void crearFMUL(FILE *);
void crearFDIV(FILE *);
void crearASIG(FILE *);
void crearCMP(FILE *);
void crearINPUT(FILE *);
void crearOUTPUT(FILE *);
char *sacarComillas(char *val, char *cadena);
int vec[2048];
int vecRep[2048];

int esSalto(char *);
void crearSalto(FILE *);
void reemplazo(char *v, char c1, char c2);
int buscarPorValor(char *id);
/***********************************************************************/


%}


%union {
	int intval;
	double val;
	char *str_val;
}
%start start
%token <str_val>ID <int>CTE_E <double>CTE_R <str_val>CTE_S
%token C_REPEAT_A C_REPEAT_C C_IF_A C_IF_E
%token C_FILTER C_FILTER_REFENTEROS
%token PRINT READ
%token VAR ENDVAR CONST INTEGER FLOAT STRING
%token OP_ASIG OP_SUMA OP_RESTA OP_MUL OP_DIV
%token PARENTESIS_A PARENTESIS_C LLAVE_A LLAVE_C CORCHETE_A CORCHETE_C COMA PYC DOSPUNTOS
%token OP_IGUAL OP_DISTINTO OP_MENOR OP_MENORIGUAL OP_MAYOR OP_MAYORIGUAL OP_LOGICO_AND OP_LOGICO_OR OP_NEGACION


%%

start: archivo ; /* SIMBOLO INICIAL */

/* DECLARACION GENERAL DE PROGRAMA
	- DECLARACIONES Y CUERPO DE PROGRAMA
	- CUERPO DE PROGRAMA
*/
archivo:
		VAR bloqdeclaracion ENDVAR bloqprograma {exportarTablas(); generarAssembler();} ;

/* REGLAS BLOQUE DE DECLARACIONES */
bloqdeclaracion:
	bloqdeclaracion declaracion ;

bloqdeclaracion:
	declaracion ;

declaracion:
	CORCHETE_A listatipos CORCHETE_C DOSPUNTOS CORCHETE_A listavariables CORCHETE_C PYC {insertarIDs();};

listatipos:
	listatipos COMA listadato	|listadato;

listadato:
	INTEGER {sprintf(tipoid[canttipos++], "%s", "INTEGER"); }	|
	FLOAT	{sprintf(tipoid[canttipos++], "%s", "FLOAT"); }		;

listavariables:		
	listavariables COMA ID {strcpy(cadAux,yylval.str_val); strcpy(ids[cantIds], strtok(cadAux," ,:"));cantIds++;}	|
	ID{strcpy(cadAux,yylval.str_val); strcpy(ids[cantIds], strtok(cadAux," ,:"));cantIds++;}						;
/* FIN REGLAS BLOQUE DE DECLARACIONES */

/* REGLAS BLOQUE DE CUERPO DE PROGRAMA */

bloqprograma:
	bloqprograma sentencia ;
bloqprograma:
	sentencia ;

sentencia:		constante	|
				asignacion 	|
				decision	|
				bucle		|
				leer		|
				imprimir	|
				filtro		; /*SACAR*/

tiposoloid:
	ID {strcpy(aux1, yylval.str_val);};

constante:
	CONST tiposoloid OP_ASIG CTE_E
	{	/*itoa(yylval.intval, valorConstante, 10);*/
     sprintf(valorConstante, "%.2f", (double)yylval.intval);
    } PYC
	{	indice_constante = crearTerceto("=", aux1, valorConstante);
		insertarConstante(aux1, "CONST_INTEGER", valorConstante);
	}		|
	CONST tiposoloid OP_ASIG CTE_R
	{	gcvt(yylval.val, 10, valorConstante);} PYC
	{	indice_constante = crearTerceto("=", aux1, valorConstante);
		insertarConstante(aux1, "CONST_FLOAT", valorConstante);
	}		|
	CONST tiposoloid OP_ASIG CTE_S
	{	strcpy(valorConstante, yylval.str_val);} PYC
	{	indice_constante = crearTerceto("=", aux1, valorConstante);
		insertarConstante(aux1, "CONST_STRING", valorConstante);
	}		;

asignacion:	
	ID {if((idAsig1 = existeID(yylval.str_val)) != -1)
		strcpy(aux1, yylval.str_val);
	else
		yyerror(" SINTAX : ID no declarado anteriormente" );}	
		OP_ASIG tipoasig PYC {crearTerceto("=", aux1, valorConstante);};

tipoasig:		
	varconstante
	{ 	if(strcmp(tablaId[idAsig1].tipo, aux2) != 0)
			yyerror("SINTAX : Asignacion de dos tipos disntitos");
	}
	|
	ID
	{	if((idAsig2 = existeID(yylval.str_val)) != -1) {
			if(strcmp(tablaId[idAsig1].tipo, tablaId[idAsig2].tipo) != 0)
				yyerror("SINTAX : Asignacion de dos tipos disntitos");
			else
				strcpy(valorConstante, yylval.str_val);
		}
		else
			yyerror("SINTAX : ID no declarado anteriormente");
	}		;

varconstante:	CTE_E
  {
    sprintf(valorConstante, "%0.2f", (double) yylval.intval);
    strcpy(aux2, "INTEGER");
    strcpy(cadAux, "_");
    crearFloat(strcat(cadAux, valorConstante));
    insertarConstante(cadAux, "CONST_INTEGER", valorConstante);
    /*toa(yylval.intval, valorConstante, 10); strcpy(aux2, "INTEGER");*/
  }	|
	CTE_R
  {
    sprintf(valorConstante, "%0.2f", (double) yylval.val);
    strcpy(aux2,"FLOAT");
    strcpy(cadAux, "_");
    crearFloat(strcat(cadAux, valorConstante));
    insertarConstante(cadAux, "CONST_FLOAT", valorConstante);
    /*gcvt(yylval.val, 10, valorConstante); strcpy(aux2, "FLOAT");*/
  };

decision:		
	C_IF_A PARENTESIS_A condicion PARENTESIS_C LLAVE_A bloqprograma LLAVE_C
	{	modificarTerceto(desapilar(&pilaPos), 0);
	}	|
	C_IF_A PARENTESIS_A condicion PARENTESIS_C LLAVE_A bloqprograma LLAVE_C
	{	modificarTerceto(desapilar(&pilaPos), 1);
		indice_if = crearTerceto("JMP", "", "");
		apilar(&pilaPos, indice_if);
	}
	C_IF_E LLAVE_A bloqprograma LLAVE_C	{modificarTerceto(desapilar(&pilaPos), 0);}	;

bucle:		
	C_REPEAT_A
	{	indice_repeat = crearTerceto("ETQ_REPEAT", "", "");
		apilar(&pilaRepeat, indice_repeat);
	}
	bloqprograma C_REPEAT_C PARENTESIS_A condicion PARENTESIS_C PYC
	{
		modificarTerceto(numeroTerceto-1, (-1)*(numeroTerceto - desapilar(&pilaRepeat) ));
	};

condicion:
	comparacion
	{	sprintf(aux1, "[ %d ]", indice_comparacion);
		indice_condicion = crearTerceto(opSalto, aux1, "--");
		apilar(&pilaPos, indice_condicion);
	}	|
	OP_NEGACION PARENTESIS_A comparacion PARENTESIS_C
	{	sprintf(aux1, "[ %d ]", indice_comparacion);
		indice_condicion = crearTerceto(negarSalto(opSalto), aux1, "");
		apilar(&pilaPos, indice_condicion);
	}	|
	comparacion_i OP_LOGICO_AND comparacion_d
	{	sprintf(aux1, "[ %d ]", indice_comparacionI);
		sprintf(aux2, "[ %d ]", indice_comparacionD);
		indice_condicion = crearTerceto("AND", aux1, aux2);
		sprintf(aux1, "[ %d ]", numeroTerceto);
		indice_condicion = crearTerceto("JZ", aux1, "");
		apilar(&pilaPos, indice_condicion);
	}	|
	comparacion_i OP_LOGICO_OR comparacion_d
	{	sprintf(aux1, "[ %d ]", indice_comparacionI);
		sprintf(aux2, "[ %d ]", indice_comparacionD);
		indice_condicion = crearTerceto("OR", aux1, aux2);
		sprintf(aux1, "[ %d ]", numeroTerceto);
		indice_condicion = crearTerceto("JZ", aux1, "");
		apilar(&pilaPos, indice_condicion);
	}	;

comparacion_i:		comparacion { indice_comparacionI = indice_comparacion; } ;
comparacion_d:		comparacion { indice_comparacionD = indice_comparacion; } ;


comparacion:		
	expresion_i op_comparacion expresion_d
	{	sprintf(aux1, "[ %d ]", indice_condicionI);
		sprintf(aux2, "[ %d ]", indice_condicionD);
		indice_comparacion = crearTerceto("CMP", aux1, aux2);
	}	|
	filtro op_comparacion expresion_d
	{	sprintf(aux2, "[ %d ]", indice_condicionD);
		indice_comparacion = crearTerceto("CMP", "_auxFiltro", aux2);
	}	;


expresion_i: 		expresion { indice_condicionI = indice_expresion; };
expresion_d:		expresion { indice_condicionD = indice_expresion; };

op_comparacion:       
	OP_MENOR {strcpy(opSalto, "JB");} 		|
	OP_MENORIGUAL {strcpy(opSalto, "JBE");}	|
	OP_MAYOR {strcpy(opSalto, "JA");}		|
	OP_MAYORIGUAL {strcpy(opSalto, "JAE");}	|
	OP_IGUAL {strcpy(opSalto, "JE");}		|
	OP_DISTINTO	{strcpy(opSalto, "JNE");}	;



expresion:
	termino	{ indice_expresion = indice_termino; }		|
	expresion OP_SUMA termino
	{	sprintf(aux1, "[ %d ]", indice_expresion);
		sprintf(aux2, "[ %d ]", indice_termino);
	indice_expresion = crearTerceto("ADD", aux1, aux2);
	}		|
	expresion OP_RESTA termino
	{	sprintf(aux1, "[ %d ]", indice_expresion);
		sprintf(aux2, "[ %d ]", indice_termino);
	indice_expresion = crearTerceto("SUB", aux1, aux2);
	}		;

termino:		
	factor { indice_termino = indice_factor; }				|
	termino OP_MUL factor
	{
		sprintf(aux1, "[ %d ]", indice_termino);
		sprintf(aux2, "[ %d ]", indice_factor);
	indice_termino = crearTerceto("MUL", aux1, aux2);
	}	|
	termino OP_DIV factor
	{	sprintf(aux1, "[ %d ]", indice_termino);
		sprintf(aux2, "[ %d ]", indice_factor);
	indice_termino = crearTerceto("DIV", aux1, aux2);
	}	;

factor:		ID
	{	//if(existeID(yylval.str_val))
			indice_factor = crearTerceto(yylval.str_val,"--","--");
		/*SINO ERROR PORQUE NO EXISTE*/
	}				|
	varconstante {indice_factor = crearTerceto(valorConstante, "--", "--");}	|
	PARENTESIS_A expresion PARENTESIS_C {indice_factor = indice_expresion;}	;



imprimir:		PRINT CTE_S {
		strcpy(aux1, yylval.str_val);
		indice_out = crearTerceto("output", aux1, "--");
		strcpy(aux1, "_");
		insertarConstante(strcat(aux1, yylval.str_val), "CONST_STRING", yylval.str_val);
	}	PYC	|
	PRINT ID {
		//if(existeID(yylval.str_val))
			strcpy(aux1, yylval.str_val);
			indice_out = crearTerceto("output", aux1, "--");
		/*SINO ERROR PORQUE NO EXISTE*/
	}	PYC	;
leer:
	READ ID	{
	//if(existeID(yylval.str_val))
		strcpy(aux1, yylval.str_val);
		indice_in = crearTerceto("input", aux1, "--");
	/*SINO ERROR PORQUE NO EXISTE*/
	}	PYC	;

filtro:
	C_FILTER PARENTESIS_A condfiltro COMA CORCHETE_A listvarfiltro CORCHETE_C PARENTESIS_C
	{	while(!pila_vacia(&pilaFiltro))
		{
			modificarTerceto(desapilar(&pilaFiltro), 0);
		}
	}	;

condfiltro:	
	C_FILTER_REFENTEROS op_comparacion expresion ;
/*							C_FILTER_REFENTEROS op_comparacion expresion_i OP_LOGICO_AND C_FILTER_REFENTEROS op_comparacion expresion_d |
							C_FILTER_REFENTEROS op_comparacion expresion_i OP_LOGICO_OR C_FILTER_REFENTEROS op_comparacion expresion_d ;
*/


listvarfiltro:
		listvarfiltro COMA ID
	{	//if(existeID(yylval.str_val))
		strcpy(aux1, yylval.str_val);
		indice_filtro = crearTerceto(aux1, "--", "--");
		sprintf(aux1, "[ %d ]", indice_expresion);
		sprintf(aux2, "[ %d ]", numeroTerceto-1);
		crearTerceto("CMP", aux1, aux2);
		sprintf(aux1, "[ %d ]", numeroTerceto+3);
		crearTerceto(negarSalto(opSalto), aux1, "");
		sprintf(aux1, "[ %d ]", numeroTerceto-3);
		crearTerceto("=", "_auxFiltro", aux1);
		crearTerceto("JMP", "", "");
		apilar(&pilaFiltro, numeroTerceto-1);
		/*SINO ERROR PORQUE NO EXISTE*/
	}	|
	ID
	{	//if(existeID(yylval.str_val))
		strcpy(aux1, yylval.str_val);
		indice_filtro = crearTerceto(aux1, "--", "--");
		sprintf(aux1, "[ %d ]", indice_expresion);
		sprintf(aux2, "[ %d ]", numeroTerceto-1);
		crearTerceto("CMP", aux1, aux2);
		sprintf(aux1, "[ %d ]", numeroTerceto+3);
		crearTerceto(negarSalto(opSalto), aux1, "");
		sprintf(aux1, "[ %d ]", numeroTerceto-3);
		crearTerceto("=", "_auxFiltro", aux1);
		crearTerceto("JMP", "", "");
		apilar(&pilaFiltro, numeroTerceto-1);
		/*SINO ERROR PORQUE NO EXISTE*/
	}	;





%%
/* *******************************************************************************
								DESARROLLO DE FUNCIONES
	****************************************************************************** */

int main(int argc,char *argv[]){

	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
		return 0;
	}

	/* ************ CREACION DE PILAS *********** */
	crearPila(&pilaPos);
	crearPila(&pilaRepeat);
	crearPila(&pilaFiltro);
	/* ****************************************** */



	yyparse();
	fclose(yyin);


  generarAssembler();
	return 0;
}

int yyerror(char * mensaje){
	printf("\n\n\n----- %s -----\n", mensaje);
	system ("Pause");
	exit (1);
}


int crearTerceto(char *operador, char *operando1, char *operando2)
{
	tablaTerceto[numeroTerceto].indice = numeroTerceto;

	strcpy(tablaTerceto[numeroTerceto].dato1, operador);
	strcpy(tablaTerceto[numeroTerceto].dato2, operando1);
	strcpy(tablaTerceto[numeroTerceto].dato3, operando2);
	//printf("TERCERTO: %d - OPERADOR: %s - OPERANDO1: %s - OPERANDO2: %s\n", tablaTerceto[numeroTerceto].indice, tablaTerceto[numeroTerceto].dato1, tablaTerceto[numeroTerceto].dato2, tablaTerceto[numeroTerceto].dato3);
	return numeroTerceto++;
}

void modificarTerceto(int posicion, int inc)
{
	//printf("REEMPLAZANDO: POS %d - INC %d - NUMTERCERO %d\n", posicion, inc, numeroTerceto);
	//printf("EN POS: %s - %s - %s\n", tablaTerceto[posicion].dato1, tablaTerceto[posicion].dato2, tablaTerceto[posicion].dato3);

	sprintf(tablaTerceto[posicion].dato2, "[ %d ]", numeroTerceto + inc);
	//itoa((numeroTerceto + inc), tablaTerceto[posicion].dato2, 10);

}

void mostrarTerceto()
{
  int i;
	for(i = 0; i < numeroTerceto; i++)
		printf("TERCERTO: %d - OPERADOR: %s - OPERANDO1: %s - OPERANDO2: %s\n", tablaTerceto[i].indice, tablaTerceto[i].dato1, tablaTerceto[i].dato2, tablaTerceto[i].dato3);

}

char* negarSalto(char* operadorSalto)
{
	if (strcmp(operadorSalto, "JE") == 0) // IGUAL
	{
		return "JEN"; // DISTINTO
	}
	if (strcmp(operadorSalto, "JNE") == 0) // DISTINTO
	{
		return "JE"; //IGUAL
	}
	if (strcmp(operadorSalto, "JB") == 0) // MENOR
	{
		return "JAE"; // MAYOR O IGUAL
	}
	if (strcmp(operadorSalto, "JA") == 0) //MAYOR
	{
		return "JBE"; //MENOR O IGUAL
	}
	if (strcmp(operadorSalto, "JBE") == 0) //MENOR O IGUAL
	{
		return "JA";	//MAYOR
	}
	if (strcmp(operadorSalto, "JAE") == 0) //MAYOR O IGUAL
	{
		return "JB"; //MENOR
	}
	if (strcmp(operadorSalto, "JZ") == 0) //
	{
		return "JNZ";
	}
	if (strcmp(operadorSalto, "JNZ") == 0)
	{
		return "JZ";
	}
}

void insertarIDs(){
  int i;
	if(cantIds > canttipos) {
		cantIds = canttipos;
	}
	for(i = 0; i < cantIds ; i++) {
		/*SI NO EXISTE, INSERTO*/
		if(existeID(ids[i]) == -1)
		{
			strcpy(tablaId[numeroId].nombre, ids[i]);
			strcpy(tablaId[numeroId].tipo, tipoid[i]);
			strcpy(tablaId[numeroId].valor, "?");
			strcpy(tablaId[numeroId].longitud, "");
			numeroId++;
		}
		/*SI EXISTE, ERROR*/
	}

	memset( ids, '\0', MAX_IDS );
	memset( tipoid, '\0', MAX_IDS );
	cantIds = 0;
	canttipos = 0;


}

void insertarConstante(char* nombre, char* tipo, char* valor)
{
	char auxLongitud[31];

	if(existeID(nombre) == -1) {
		strcpy(tablaId[numeroId].nombre, nombre);
		strcpy(tablaId[numeroId].tipo, tipo);
		strcpy(tablaId[numeroId].valor, valor);
		if(strcmp(tipo, "STRING") == 0){
			sprintf(tablaId[numeroId].longitud, "%d", strlen(tablaId[numeroId].valor) - 2);
		}
		else
			strcpy(tablaId[numeroId].longitud, "");

		numeroId++;
	}
	/* SINO ERROR PORQUE YA EXISTE*/


}

void mostrarID()
{
  int i;
	for( i = 0; i < numeroId; i++)
		printf("ID: %d - NOMBRE: %s - TIPO: %s - VALOR: %s - LONGITUD: %s\n", i, tablaId[i].nombre, tablaId[i].tipo, tablaId[i].valor, tablaId[i].longitud);

}

int existeID(char* id)
{
  int i;
	for(i = 0; i < numeroId; i++)
	{
		if(strcmp(tablaId[i].nombre, id) == 0)
			return i;
	}
	return -1;
}



/* EXPORTACION DE TABLAS */
void exportarTablas()
{
  int i;
	FILE *ts = fopen("ts.txt", "wt");
	FILE *intermedia = fopen("intermedia.txt", "wt");

	fprintf(ts, "NOMBRE\t\t\t\tTIPO\t\t\t\tVALOR\t\t\tLONGITUD\n");

	for(i = 0; i < numeroId; i++) {
		fprintf(ts, "%-30s%-30s%-30s%s\n", tablaId[i].nombre, tablaId[i].tipo, tablaId[i].valor, tablaId[i].longitud);
	}


	for(i = 0; i < numeroTerceto; i++) {
		fprintf(intermedia, "|  %d  | ( %s, %s, %s )\n", tablaTerceto[i].indice, tablaTerceto[i].dato1, tablaTerceto[i].dato2, tablaTerceto[i].dato3);
	}

	fclose(ts);
	fclose(intermedia);

}
/*	**********************************************
	******* GENERACION DE CODIGO ASSEMBLER *******
	*********************************************/
void generarAssembler() {

	FILE *codAssembler = fopen("Final.asm", "wt");
	if(codAssembler == NULL) {
		return;
		printf("%s\n", "No pudo abrir el archivo Final");
	}

	imprimirCabeceraASM(codAssembler);
	imprimirVariablesASM(codAssembler);
	imprimirCabeceraCodeASM(codAssembler);
	recorrerTercetos(codAssembler);



	fclose(codAssembler);
}

void imprimirCabeceraASM(FILE *arch) {
	fprintf(arch, "include macros2.asm\n");
	fprintf(arch, "include number.asm\n\n");
	fprintf(arch, ".MODEL LARGE\n");
	fprintf(arch, ".STACK 200h\n\n");
	fprintf(arch, ".386\n");
	fprintf(arch, "MAXTEXTSIZE equ 50\n\n");
	fprintf(arch, ".DATA\n");
}

void imprimirVariablesASM(FILE *arch) {
  int i;
	char subfijo[50];
  char cadena[20];

	for(i = 0; i < numeroId; i++) {
		strcpy(subfijo, "_");

		fprintf(arch, "\t%s\t%s\t%s", strcat(subfijo, ((strstr(tablaId[i].tipo, "STRING")!= NULL )?sacarComillas(tablaId[i].valor, cadena):(tablaId[i].nombre))), 
                                        (strstr(tablaId[i].tipo, "STRING")!= NULL ? "db" : "dd"), tablaId[i].valor);
		fprintf(arch, "%s\n" , (strstr(tablaId[i].tipo, "STRING")!= NULL ? ", \"$\"": ""));
	}
}

char *sacarComillas(char *val, char *cadena){
  strcpy(cadena, val);
  char *ptrC = strrchr(cadena, '\"');
  *ptrC = '\0';
  ptrC = strchr(cadena, '\"');
  *(ptrC++) = '\0';
  strcpy(cadena, ptrC);
  return cadena;
}

void imprimirCabeceraCodeASM(FILE *arch) {
	fprintf(arch, "\n.CODE\n");
	fprintf(arch, "START:\n");
	fprintf(arch, "; ******* CODIGO PERMANENTE ********\n");
	fprintf(arch, "\tmov AX,@DATA\n");
	fprintf(arch, "\tmov DS,AX\n");
	fprintf(arch, "; **********************************\n");
	fprintf(arch, "\tmov es,ax\n");

}
void recorrerTercetos(FILE *arch) {
	int w=0;
		for(w=0;w<2048;w++){
			vec[w]=-1;
		}
	int j=0;
	for(j=0;j<2048;j++){
		vecRep[j]=-1;
	}
	for(j=0;j<2048;j++){
		if(strcmp(tablaTerceto[j].dato1,"ETQ_REPEAT")==0){
			fprintf(arch,"ETQ_REPEAT_%d:\n",j);
			vec[j]=-1;
			vecRep[j] = j;
	}}
			
	// RECORRER LOS TERCETOS
	for(indiceTerceto = 0; indiceTerceto < numeroTerceto; indiceTerceto++)
	{
		if(vec[indiceTerceto]!=-1){
			fprintf(arch,"ETQ_%d:\n",indiceTerceto);
		}
		if(vecRep[indiceTerceto]!=-1){
			fprintf(arch,"ETQ_REPEAT_%d:\n",indiceTerceto);
		}
		
		
		if(strcmp(tablaTerceto[indiceTerceto].dato2, "--") == 0 && strcmp(tablaTerceto[indiceTerceto].dato3, "--") == 0)
		{
		  crearValor(arch);

		}
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "ADD") == 0)
	  {
      crearFADD(arch);
		}

		if(strcmp(tablaTerceto[indiceTerceto].dato1, "SUB") == 0)
		{
		  crearFSUB(arch);
		}

		{
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "MUL") == 0)
		  crearFMUL(arch);
		}

		if(strcmp(tablaTerceto[indiceTerceto].dato1, "DIV") == 0)
		{
		  crearFDIV(arch);
		}
				if(esSalto(tablaTerceto[indiceTerceto].dato1) == 1) {
			crearSalto(arch);
		}
		
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "input") == 0) {
			crearINPUT(arch);
		}
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "output") == 0) {
			crearOUTPUT(arch);
		}

    if(strcmp(tablaTerceto[indiceTerceto].dato1, "=") == 0){
      crearASIG(arch);
    }


    if(strcmp(tablaTerceto[indiceTerceto].dato1, "CMP") == 0){
      crearCMP(arch);
    }

	}
	
	fprintf(arch,"mov ah,4ch\n" );
    fprintf(arch,"mov al,0\n" );
    fprintf(arch,"int 21h\n" );
	fprintf(arch,"\nSTRLEN PROC NEAR\n");
	fprintf(arch,"\tmov BX,0\n");
	fprintf(arch,"\nSTRL01:\n");
	fprintf(arch,"\tcmp BYTE PTR [SI+BX],'$'\n");
	fprintf(arch,"\tje STREND\n");
	fprintf(arch,"\tinc BX\n");
	fprintf(arch,"\tjmp STRL01\n");
	fprintf(arch,"\nSTREND:\n");
	fprintf(arch,"\tret\n");
	fprintf(arch,"\nSTRLEN ENDP\n");
	fprintf(arch,"\nCOPIAR PROC NEAR\n");
	fprintf(arch,"\tcall STRLEN\n");
	fprintf(arch,"\tcmp BX,MAXTEXTSIZE\n");
	fprintf(arch,"\tjle COPIARSIZEOK\n");
	fprintf(arch,"\tmov BX,MAXTEXTSIZE\n");
	fprintf(arch,"\nCOPIARSIZEOK:\n");
	fprintf(arch,"\tmov CX,BX\n");
	fprintf(arch,"\tcld\n");
	fprintf(arch,"\trep movsb\n");
	fprintf(arch,"\tmov al,'$'\n");
	fprintf(arch,"\tmov BYTE PTR [DI],al\n");
	fprintf(arch,"\tret\n");
	fprintf(arch,"\nCOPIAR ENDP\n");
	fprintf(arch,"\nEND START\n");
	fclose(arch);
	
	
	
}

void crearValor(FILE *pf)
{
	char buffer[20];
	char op[10] = "FLD ";
 
    strcpy(underscore, "_");
    strcpy(cteAux, tablaTerceto[indiceTerceto].dato1);
    crearFloat(cteAux);
    strcat(underscore, cteAux);
    crearInstruccion(pf, "\t", op, underscore, "");
    strcpy(aux, "@aux");
    strcat(aux, itoa(tablaTerceto[indiceTerceto].indice, buffer, 10));
    strcpy(tercetoLeido[tablaTerceto[indiceTerceto].indice].aux, aux);
    crearInstruccion(pf, "\t", "FSTP", aux, "");
	//}
}

void crearFloat(char *valor){
	int i;
	for (i=0;i<strlen(valor);i++){
		if (valor[i] == '.'){
			valor[i] = '_';
		}
	}
}

void crearFADD(FILE *pf)
{
	char *cad;
	char buffer[20];
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
  printf("\n\n\n%d\n\n\n", atoi(cad));
	crearInstruccion(pf, "\t", "FLD ", tercetoLeido[atoi(cad)].aux, "");
	cad = strchr(tablaTerceto[indiceTerceto].dato3,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t","FADD", tercetoLeido[atoi(cad)].aux, "");
	strcpy(aux, "@aux");
	strcat(aux, itoa(tablaTerceto[indiceTerceto].indice, buffer, 10));
	strcpy(tercetoLeido[tablaTerceto[indiceTerceto].indice].aux, aux);
	crearInstruccion(pf, "\t", "FSTP", aux, "");
}

void crearFSUB(FILE *pf)
{
	char buffer[20];
	char *cad;
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t", "FLD ", tercetoLeido[atoi(cad)].aux, "");
	cad = strchr(tercetoArchivo.dato3,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t","FSUB", tercetoLeido[atoi(cad)].aux, "");
	strcpy(aux, "@aux");
	strcat(aux, itoa(tablaTerceto[indiceTerceto].indice, buffer, 10));
	strcpy(tercetoLeido[tablaTerceto[indiceTerceto].indice].aux, aux);
	crearInstruccion(pf, "\t", "FSTP", aux, "");
}

void crearFMUL(FILE *pf)
{
	char buffer[20];
	char *cad;
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t", "FLD ", tercetoLeido[atoi(cad)].aux, "");
	cad = strchr(tablaTerceto[indiceTerceto].dato3,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t","FMUL", tercetoLeido[atoi(cad)].aux, "");
	strcpy(aux, "@aux");
	strcat(aux, itoa(tablaTerceto[indiceTerceto].indice, buffer, 10));
	strcpy(tercetoLeido[tablaTerceto[indiceTerceto].indice].aux, aux);
  crearInstruccion(pf, "\t", "FSTP", aux, "");
}

void crearFDIV(FILE *pf)
{
	char buffer[20];
	char *cad;
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t", "FLD ", tercetoLeido[atoi(cad)].aux, "");
	cad = strchr(tablaTerceto[indiceTerceto].dato3,'[');
	cad += 2; // Salteo el espacio entre el corchete y el indice
	crearInstruccion(pf, "\t","FDIV", tercetoLeido[atoi(cad)].aux, "");
	strcpy(aux, "@aux");
	strcat(aux, itoa(tablaTerceto[indiceTerceto].indice, buffer, 10));
	strcpy(tercetoLeido[tablaTerceto[indiceTerceto].indice].aux, aux);
  crearInstruccion(pf, "\t", "FSTP", aux, "");
}

void crearASIG(FILE *pf)
{
	char buffer[20];
  char op[10] = "FLD ";
  if( *(tablaTerceto[indiceTerceto].dato3) == '[' ){
    strcpy(cteAux, tercetoLeido[atoi((tablaTerceto[indiceTerceto].dato3)+2)].aux);
    crearInstruccion(pf, "\t", op, cteAux, "");
    crearInstruccion(pf, "\t", "FSTP", tablaTerceto[indiceTerceto].dato2, "");
  }
  if( tipoElemento(tablaTerceto[indiceTerceto].dato3) == 2 || tipoElemento(tablaTerceto[indiceTerceto].dato3) == 1){
    strcpy(cteAux, "_");
    strcat(cteAux, tablaTerceto[indiceTerceto].dato3);
    crearFloat(cteAux);
    crearInstruccion(pf, "\t", "FLD ", cteAux, "");
    strcpy(cteAux, "_");
    strcat(cteAux, tablaTerceto[indiceTerceto].dato2);
    crearInstruccion(pf, "\t", "FSTP", cteAux, "");
  }
  if( tipoElemento(tablaTerceto[indiceTerceto].dato3) == 5 || tipoElemento(tablaTerceto[indiceTerceto].dato3) == 4){
    strcpy(cteAux, "_");
    strcat(cteAux, tablaTerceto[indiceTerceto].dato3);
    crearInstruccion(pf, "\t", "FLD ", cteAux, "");
    strcpy(cteAux, "_");
    strcat(cteAux, tablaTerceto[indiceTerceto].dato2);
    crearInstruccion(pf, "\t", "FSTP", cteAux, "");
  }

}

void crearCMP(FILE *pf)
{
  char op1[50];
  if(*(tablaTerceto[indiceTerceto].dato2) == '['){
    strcpy(op1, tercetoLeido[atoi(tablaTerceto[indiceTerceto].dato2+1)].aux);
    crearInstruccion(pf, "\t", "FLD ", op1, "");
  } else
    if(tipoElemento(tablaTerceto[indiceTerceto].dato2) == 1 || tipoElemento(tablaTerceto[indiceTerceto].dato2) == 2 ||
        tipoElemento(tablaTerceto[indiceTerceto].dato2) == 4 || tipoElemento(tablaTerceto[indiceTerceto].dato2) == 5 ){
          strcpy(op1, "_");
          strcat(op1, tablaTerceto[indiceTerceto].dato2);
          printf("\n\n%s\n\n",op1);
          crearFloat(op1);
          crearInstruccion(pf, "\t", "FLD ", op1, "");
        }
  if(*(tablaTerceto[indiceTerceto].dato3) == '['){
    strcpy(op1, tercetoLeido[atoi(tablaTerceto[indiceTerceto].dato3+1)].aux);
    crearInstruccion(pf, "\t", "FCOMP", op1, "");
  }else
    if(tipoElemento(tablaTerceto[indiceTerceto].dato3) == 1 || tipoElemento(tablaTerceto[indiceTerceto].dato3) == 2 ||
        tipoElemento(tablaTerceto[indiceTerceto].dato3) == 4 || tipoElemento(tablaTerceto[indiceTerceto].dato3) == 5 ){
          strcpy(op1, "_");
          strcat(op1, tablaTerceto[indiceTerceto].dato3);
          crearFloat(op1);
          crearInstruccion(pf, "\t", "FCOMP", op1, "");
        }
  crearInstruccion(pf, "\t", "FSTSW","AX","");
  crearInstruccion(pf, "\t", "SAHF", "","");
}


/* domingo 20hs:= NO ANDA BIEN, LEE MAL LAS VARIABLES POR ALGUN MOTIVO
  lunes 2:12 hs:= creo que lo arregle
*/
int tipoElemento(char *elemento)
{
  int i = 0;
  char auxVal[35] = "_";
  while(i < 2048)
  {
    if(strcmp(elemento, tablaId[i].valor) == 0){//es una constante
      if(strcmp(tablaId[i].tipo, "CONST_INT") == 0){
        return 1;
      }else{
        if(strcmp(tablaId[i].tipo, "CONST_FLOAT") == 0){
          return 2;
        }else{
          if(strcmp(tablaId[i].tipo, "CONST_STRING") == 0){
            return 3;
          }
        }
      }
    }else{
      if(strcmp(tablaId[i].valor, "?") == 0){//Es una variable
        if(strcmp(tablaId[i].nombre, elemento) == 0){
          if(strcmp(tablaId[i].tipo, "INTEGER") == 0){
            return 4;
          }else{
            if(strcmp(tablaId[i].tipo, "FLOAT") == 0){
              return 5;
            }
          }
        }
      }
    }
    i++;
  }

  return -1;
}
int esSalto(char *instruccion) {
	
	char saltos[9][10] = {"JE", "JNE", "JB", "JAE", "JA", "JBE", "JZ", "JNZ", "JMP"};
	int i=0;
	for(i = 0; i < 9; i++) {
		if(strcmp(instruccion, saltos[i]) == 0) {
			return 1;
		}
		
	}
	
	return 0;
}

void crearSalto(FILE *arch) {
	char *cad;
	char buffer[20];
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; // Salteo el espacio entre el corchete y el indice
	printf("\n\n\n%d\n\n\n", atoi(cad));
	if(vecRep[atoi(cad)]!=-1)
	{
		sprintf(buffer, "ETQ_REPEAT_%d", atoi(cad));
	crearInstruccion(arch, "\t", tablaTerceto[indiceTerceto].dato1, buffer, "");

	}
	else{
		vec[atoi(cad)]=atoi(cad);
		sprintf(buffer, "ETQ_%d", atoi(cad));
		crearInstruccion(arch, "\t", tablaTerceto[indiceTerceto].dato1, buffer, "");}
}

void crearOUTPUT(FILE *arch) {
	char subfijo[50] = "_";
	
	
	
	if(tipoElemento(tablaTerceto[indiceTerceto].dato2) == 3) { //SI ES STRING
		crearInstruccion(arch, "\t", "displayString", strcat(subfijo, tablaId[buscarPorValor(tablaTerceto[indiceTerceto].dato2)].nombre), "");
	}
	else {
		crearInstruccion(arch, "\t", "DisplayFloat", strcat(subfijo, tablaId[existeID(tablaTerceto[indiceTerceto].dato2)].nombre), ", 2");
	}
	
	crearInstruccion(arch, "\t", "newLine", "", "");
	
}

void crearINPUT(FILE *arch) {
	char subfijo[50] = "_";
	/*if(tipoElemento(tablaTerceto[indiceTerceto].dato2) == 4) { //SI ES INTEGER
		crearInstruccion(arch, "\t", "displayString", strcat(subfijo, tablaId[buscarPorValor(tablaTerceto[indiceTerceto].dato2)].nombre), "");
	}*/
	/*if (tipoElemento(tablaTerceto[indiceTerceto].dato2) == 5) {*/
		crearInstruccion(arch, "\t", "GetFloat", strcat(subfijo, tablaId[existeID(tablaTerceto[indiceTerceto].dato2)].nombre), "");
	/*}
	else
		printf("ERROR\n\n\n");
	*/
}	

void crearInstruccion(FILE *pf,char *c1,char *c2,char *c3, char *c4){
	
	fprintf(pf, "%s\t%s\t%s\t%s\n", c1, c2, c3, c4);
}

void reemplazo(char *v, char c1, char c2) {

    int i;

    for (i=0;v[i]!='\0';i++)
    {
        if (*(v+i)==c1)
        {
            *(v+i)=c2;
        }
    }

}

int buscarPorValor(char *id){
	int i;
	for(i = 0; i < numeroId; i++)
	{
		if(strcmp(tablaId[i].valor, id) == 0)
			return i;
	}
	return -1;
	
}
