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
t_pila pilaOr;
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
int condicionDoble = 0;
char valorConstante[50];
char valorConstEspecial[50];
char aux1[31], aux2[31], aux3[31], aux4[31], opSalto[6];

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

void crearTercetoAsm(int ind, char *varAux);
void crearFloat(char *); /* funcion para cambiar los puntos de una variable */
int tipoElemento(char *); /* funcion para obtener el tipo del elemento
                           float a un _ para poder llamarla como cte sin nombre */
void crearInstruccion(FILE *,char *,char *,char *, char *);
/* Condensa la funcion fprintf con un formato ""%s\t%s\t%s\t%s\n" */
void leerTerceto(char*);
/* Recibe una linea del archivo de tercetos, y lo pasa a la estructura de tercetos */
void generarAssembler();
void imprimirVariablesASM(FILE *);
void imprimirCabeceraASM(FILE *);
void imprimirCabeceraCodeASM(FILE *);
void imprimirColaCodeASM(FILE *);
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
void crearRepeat(FILE *);
void crearAuxFiltro(FILE *);

char *sacarComillas(char *, char *);
char *sacarComillaConst(char *, char*);
int esSalto(char *);
void crearSalto(FILE *);
void reemplazo(char *v, char c1, char c2);
int buscarPorValor(char *id);
int leerIndiceTercero(char *dato);

int vec[2048];
int vecRep[2048];
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
%token OP_ASIG ASIG_MAS ASIG_MEN ASIG_MULT ASIG_DIV OP_SUMA OP_RESTA OP_MUL OP_DIV
%token PARENTESIS_A PARENTESIS_C LLAVE_A LLAVE_C CORCHETE_A CORCHETE_C COMA PYC DOSPUNTOS
%token OP_IGUAL OP_DISTINTO OP_MENOR OP_MENORIGUAL OP_MAYOR OP_MAYORIGUAL OP_LOGICO_AND OP_LOGICO_OR OP_NEGACION


%%

start				:		archivo ; /* SIMBOLO INICIAL */

/* DECLARACION GENERAL DE PROGRAMA
	- DECLARACIONES Y CUERPO DE PROGRAMA
	- CUERPO DE PROGRAMA
*/
archivo				:		VAR bloqdeclaracion ENDVAR bloqprograma {exportarTablas(); generarAssembler();} ;

/* REGLAS BLOQUE DE DECLARACIONES */
bloqdeclaracion		:		bloqdeclaracion declaracion ;
bloqdeclaracion		:		declaracion ;

declaracion			:		CORCHETE_A listatipos CORCHETE_C DOSPUNTOS CORCHETE_A listavariables CORCHETE_C PYC {insertarIDs();};

listatipos			:		listatipos COMA listadato	|
							listadato					;

listadato			:		INTEGER {sprintf(tipoid[canttipos++], "%s", "INTEGER"); }	|
							FLOAT	{sprintf(tipoid[canttipos++], "%s", "FLOAT"); }		;

listavariables		:		listavariables COMA ID {strcpy(cadAux,yylval.str_val); strcpy(ids[cantIds], strtok(cadAux," ,:"));cantIds++;}	|
							ID{strcpy(cadAux,yylval.str_val); strcpy(ids[cantIds], strtok(cadAux," ,:"));cantIds++;}						;
/* FIN REGLAS BLOQUE DE DECLARACIONES */

/* REGLAS BLOQUE DE CUERPO DE PROGRAMA */

bloqprograma		:		bloqprograma sentencia ;
bloqprograma		:		sentencia ;

sentencia			:		constante	|
							asignacion 	|
							decision	|
							bucle		|
							leer		|
							imprimir	|
							filtro		; /*SACAR*/

tiposoloid			: 		ID {strcpy(aux1, yylval.str_val);};

constante			:		CONST tiposoloid OP_ASIG CTE_E
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

asignacion:	ID
			{	if((idAsig1 = existeID(yylval.str_val)) != -1)
					strcpy(aux3, yylval.str_val);
				else
					yyerror("SINTAX ERROR: ID no declarado anteriormente");
			}
			tipAsig { crearTerceto("=", aux3, aux2); };


tipAsig : OP_ASIG expresion /*tipoasig*/ PYC
			{
				if(indice_expresion != -1)
					sprintf(aux2, "[ %d ]", indice_expresion);
				
								
			}

		| 	ASIG_MAS 	tipoasig PYC {
			indice_termino = crearTerceto("ADD", aux3, valorConstante);
			sprintf(aux2, "[ %d ]", indice_termino);
			
		}

		|	ASIG_MEN 	tipoasig PYC
		{
			indice_termino = crearTerceto("SUB", aux3, valorConstante);
			sprintf(aux2, "[ %d ]", indice_termino);
		}
		|	ASIG_MULT 	tipoasig PYC
		{
			indice_termino = crearTerceto("MUL", aux3, valorConstante);
			sprintf(aux2, "[ %d ]", indice_termino);
		}
		|	ASIG_DIV 	tipoasig PYC
		{
			indice_termino = crearTerceto("DIV", aux3, valorConstante);
			sprintf(aux2, "[ %d ]", indice_termino);
		};

tipoasig			:		varconstante
							{ 	if(strcmp(tablaId[idAsig1].tipo, aux2) != 0)
									yyerror("SINTAX ERROR: Asignacion de dos tipos disntitos");
							}
							
							| ID
							{	if((idAsig2 = existeID(yylval.str_val)) != -1) {
									if(strcmp(tablaId[idAsig1].tipo, tablaId[idAsig2].tipo) != 0)
										yyerror("SINTAX ERROR: Asignacion de dos tipos disntitos");
									else
										strcpy(valorConstante, yylval.str_val);
									}
								else
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
							};

varconstante		:	CTE_E
                  {
                    sprintf(valorConstante, "%0.2f", (double) yylval.intval);
                    strcpy(aux2, "INTEGER");
                    strcpy(cadAux, "_");
                    crearFloat(strcat(cadAux, valorConstante));
                    insertarConstante(cadAux, "CONST_INTEGER", valorConstante);
                    /*toa(yylval.intval, valorConstante, 10); strcpy(aux2, "INTEGER");*/
                  }	

                  |	CTE_R
                  {
                    sprintf(valorConstante, "%0.2f", (double) yylval.val);
                    strcpy(aux2,"FLOAT");
                    strcpy(cadAux, "_");
                    crearFloat(strcat(cadAux, valorConstante));
                    insertarConstante(cadAux, "CONST_FLOAT", valorConstante);
                    /*gcvt(yylval.val, 10, valorConstante); strcpy(aux2, "FLOAT");*/
                  };



decision			:		C_IF_A PARENTESIS_A condicion PARENTESIS_C LLAVE_A bloqprograma LLAVE_C
							{	modificarTerceto(desapilar(&pilaPos), 0);
								if(condicionDoble == 1)
									modificarTerceto(desapilar(&pilaPos), 0);
							}	|
							C_IF_A PARENTESIS_A condicion PARENTESIS_C LLAVE_A bloqprograma LLAVE_C
							{	modificarTerceto(desapilar(&pilaPos), 1);
								if(condicionDoble == 1)
									modificarTerceto(desapilar(&pilaPos), 1);
								
								indice_if = crearTerceto("JMP", "", "");
								apilar(&pilaPos, indice_if);
							}
							C_IF_E LLAVE_A bloqprograma LLAVE_C	{modificarTerceto(desapilar(&pilaPos), 0);}	;

bucle				:		C_REPEAT_A
							{	indice_repeat = crearTerceto(";ETQ_REPEAT", "", "");
								apilar(&pilaRepeat, indice_repeat);

							}
							bloqprograma C_REPEAT_C PARENTESIS_A condicion PARENTESIS_C PYC
							{
								modificarTerceto(numeroTerceto-1, (-1)*(numeroTerceto - desapilar(&pilaRepeat) - 1));

							};

condicion			:		comparacion
							{	sprintf(aux1, "[ %d ]", indice_comparacion);
								indice_condicion = crearTerceto(opSalto, aux1, "--");
								apilar(&pilaPos, indice_condicion);
								condicionDoble = 0;
							}	
							
							|OP_NEGACION PARENTESIS_A comparacion PARENTESIS_C
							{	sprintf(aux1, "[ %d ]", indice_comparacion);
								indice_condicion = crearTerceto(negarSalto(opSalto), aux1, "");
								apilar(&pilaPos, indice_condicion);
								condicionDoble = 0;
							}	|
							comparacion_i OP_LOGICO_AND comparacion_d
							{	
								condicionDoble = 1;
							}	|
							comparacion_i 	{	modificarTerceto(indice_comparacionI, 1);
												desapilar(&pilaPos);
												indice_condicion = crearTerceto(negarSalto(opSalto), "RESERVADO", "--");
												apilar(&pilaOr, indice_condicion); 
												
											}
							OP_LOGICO_OR comparacion_d
							{	
								indice_condicion = crearTerceto(negarSalto(opSalto), "RESERVADO", "--");
								apilar(&pilaOr, indice_condicion); 
								modificarTerceto(desapilar(&pilaOr), 0);
								modificarTerceto(desapilar(&pilaOr), 0);
								condicionDoble = 0;
							}	;

comparacion_i		:		comparacion { 
											indice_comparacionI = crearTerceto(opSalto, "RESERVADO", "--");
											apilar(&pilaPos, indice_comparacionI);
										} ;

comparacion_d		:		comparacion {	
											indice_comparacionD = crearTerceto(opSalto, "RESERVADO", "--");
											apilar(&pilaPos, indice_comparacionD);
										} ;


comparacion			:		expresion_i
							{
								if (indice_condicionI != -1)
									sprintf(aux4, "[ %d ]", indice_condicionI);
								else
									strcpy(aux4, aux2);
							}
							op_comparacion expresion_d
							{							
								if (indice_condicionD != -1)
									sprintf(aux2, "[ %d ]", indice_condicionD);

								indice_comparacion = crearTerceto("CMP", aux4, aux2);
							}	
							
							|	filtro op_comparacion expresion_d
							{	sprintf(aux2, "[ %d ]", indice_condicionD);

								crearTerceto("auxFiltro", "--", "--");
								sprintf(aux1, "[ %d ]", numeroTerceto-1);
								
								indice_comparacion = crearTerceto("CMP", aux4, aux2);
							}	;


expresion_i			: 		expresion { indice_condicionI = indice_expresion; };
expresion_d			:		expresion { indice_condicionD = indice_expresion; };

op_comparacion      :       OP_MENOR {strcpy(opSalto, "JNB");} 		|
							OP_MENORIGUAL {strcpy(opSalto, " JNBE");}	|
							OP_MAYOR {strcpy(opSalto, "JNA");}		|
							OP_MAYORIGUAL {strcpy(opSalto, "JNAE");}	|
							OP_IGUAL {strcpy(opSalto, "JNE");}		|
							OP_DISTINTO	{strcpy(opSalto, "JE");}	;


/*MANEJO DE EXPRESION - LISTO*/
expresion			:		termino	{ indice_expresion = indice_termino; 
							}		
						
						|	expresion
							{
								if (indice_expresion != -1)
									sprintf(aux3, "[ %d ]", indice_expresion);
								else
									strcpy(aux3, aux2);
							}
							OP_SUMA termino
							{								
								if (indice_termino != -1)
									sprintf(aux2, "[ %d ]", indice_termino);							
								indice_expresion = crearTerceto("ADD", aux3, aux2);
							}
						
						|	expresion
							{
								if (indice_expresion != -1)
									sprintf(aux3, "[ %d ]", indice_expresion);
								else
									strcpy(aux3, aux2);
							}
							OP_RESTA termino
							{	
								if (indice_termino != -1)
									sprintf(aux2, "[ %d ]", indice_termino);
							
								indice_expresion = crearTerceto("SUB", aux3, aux2);
							}		;

termino				:		factor {indice_termino = indice_factor; }
							|
							termino
							{
								if (indice_termino != -1)
									sprintf(aux1, "[ %d ]", indice_termino);
								else
									strcpy(aux1, aux2);
							}
							OP_MUL factor
							{								
								if(indice_factor != -1)
									sprintf(aux2, "[ %d ]", indice_factor);

								indice_termino = crearTerceto("MUL", aux1, aux2);
							}
							
							|
								termino
							{
								if (indice_termino != -1)
									sprintf(aux1, "[ %d ]", indice_termino);
								else
									strcpy(aux1, aux2);
							}
							OP_DIV factor
							{	
								if (indice_factor != -1)
									sprintf(aux2, "[ %d ]", indice_factor);
								indice_termino = crearTerceto("DIV", aux1, aux2);
							}
							;
							

factor				:		ID
							{	if(existeID(yylval.str_val) != -1){
									//indice_factor = -1;															
									//strcpy(aux2, yylval.str_val);
									indice_factor = crearTerceto(yylval.str_val,"--","--");
								} else { /*SINO ERROR PORQUE NO EXISTE*/
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
								}
							}				
							|
							varconstante {
								//indice_factor = -1;								
								//strcpy(aux2, valorConstante);
								indice_factor = crearTerceto(valorConstante, "--", "--");
								}	
							;
							|
							PARENTESIS_A expresion PARENTESIS_C {indice_factor = indice_expresion;}	;
							



imprimir			:		PRINT CTE_S {
								strcpy(aux1, yylval.str_val);
								indice_out = crearTerceto("output", aux1, "--");
								strcpy(aux1, "_");
								insertarConstante(strcat(aux1, yylval.str_val), "CONST_STRING", yylval.str_val);
							}	PYC	|
							PRINT ID {
								if(existeID(yylval.str_val) != -1) {
									strcpy(aux1, yylval.str_val);
									indice_out = crearTerceto("output", aux1, "--");
								} else {/*SINO ERROR PORQUE NO EXISTE*/
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
								}
							}	PYC	;
leer				:		READ ID	{
								if(existeID(yylval.str_val) != -1) {
									strcpy(aux1, yylval.str_val);
									indice_in = crearTerceto("input", aux1, "--");
								} else {/*SINO ERROR PORQUE NO EXISTE*/
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
								}
							}	PYC	;

filtro				:		C_FILTER PARENTESIS_A condfiltro COMA CORCHETE_A listvarfiltro CORCHETE_C PARENTESIS_C
							{	while(!pila_vacia(&pilaFiltro))
								{
									modificarTerceto(desapilar(&pilaFiltro), 0);
								}
							}	;

condfiltro			:		C_FILTER_REFENTEROS op_comparacion expresion ;
/*							C_FILTER_REFENTEROS op_comparacion expresion_i OP_LOGICO_AND C_FILTER_REFENTEROS op_comparacion expresion_d |
							C_FILTER_REFENTEROS op_comparacion expresion_i OP_LOGICO_OR C_FILTER_REFENTEROS op_comparacion expresion_d ;
*/
listvarfiltro		:		listvarfiltro COMA ID
							{	if(existeID(yylval.str_val) != -1) {
									strcpy(aux1, yylval.str_val);
									indice_filtro = crearTerceto(aux1, "--", "--");

									
									sprintf(aux1, "[ %d ]", indice_expresion);									
									sprintf(aux2, "[ %d ]", numeroTerceto-1);
									crearTerceto("CMP", aux2, aux1);

									sprintf(aux1, "[ %d ]", numeroTerceto+3);
									crearTerceto(negarSalto(opSalto), aux1, "");

									sprintf(aux1, "[ %d ]", numeroTerceto-3);

									crearTerceto("=", "auxFiltro", aux1);
									crearTerceto("JMP", "", "");
									
									apilar(&pilaFiltro, numeroTerceto-1);
								} else {/*SINO ERROR PORQUE NO EXISTE*/
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
								}
							}	|
							ID
							{	if(existeID(yylval.str_val) != -1) {
									strcpy(aux1, yylval.str_val);
									indice_filtro = crearTerceto(aux1, "--", "--");

									
									sprintf(aux1, "[ %d ]", indice_expresion);
									sprintf(aux2, "[ %d ]", numeroTerceto-1);
									crearTerceto("CMP", aux2, aux1);

									sprintf(aux1, "[ %d ]", numeroTerceto+3);
									crearTerceto(negarSalto(opSalto), aux1, "");

									sprintf(aux1, "[ %d ]", numeroTerceto-3);

									crearTerceto("=", "auxFiltro", aux1);
									crearTerceto("JMP", "", "");
									apilar(&pilaFiltro, numeroTerceto-1);
								} else {/*SINO ERROR PORQUE NO EXISTE*/
									yyerror("SINTAX ERROR: ID no declarado anteriormente");
								}
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

	/************* CREACION DE PILAS *********** */
	crearPila(&pilaPos);
	crearPila(&pilaRepeat);
	crearPila(&pilaFiltro);
	crearPila(&pilaOr);
	/* ****************************************** */

	yyparse();
	fclose(yyin);
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
	
	if (strcmp(operadorSalto, "JNB") == 0) // 
	{
		return "JNAE"; // 
	}
	if (strcmp(operadorSalto, "JNBE") == 0) // 
	{
		return "JNA"; //
	}
	if (strcmp(operadorSalto, "JNA") == 0) // 
	{
		return "JNBE"; // 
	}
	if (strcmp(operadorSalto, "JNAE") == 0) //
	{
		return "JNB"; //
	}
	if (strcmp(operadorSalto, "JNE") == 0) //
	{
		return "JE";	//
	}
	if (strcmp(operadorSalto, "JE") == 0) //
	{
		return "JNE"; //
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
	sacarComillaConst(nombre, nombre);
	reemplazo(nombre, ' ', '_');

	if(existeID(nombre) == -1) {
		strcpy(tablaId[numeroId].nombre, nombre);
		strcpy(tablaId[numeroId].tipo, tipo);
		strcpy(tablaId[numeroId].valor, valor);
		if(strcmp(tipo, "CONST_STRING") == 0){
			sprintf(tablaId[numeroId].longitud, "%d", strlen(tablaId[numeroId].valor) - 2);
		}
		else
			strcpy(tablaId[numeroId].longitud, "");
		numeroId++;
	}
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

	strcpy(tablaId[numeroId].nombre, "auxFiltro");
	strcpy(tablaId[numeroId].tipo, "INTEGER");
	strcpy(tablaId[numeroId].valor, "?");
	strcpy(tablaId[numeroId].longitud, "");
	numeroId++;
	
	for(i = 0; i < numeroId; i++) {
		fprintf(ts, "%-30s%-30s%-30s%s\n", tablaId[i].nombre, tablaId[i].tipo, tablaId[i].valor, tablaId[i].longitud);
	}
	
	for(i = 0; i < numeroTerceto; i++) {
		fprintf(intermedia, "|  %d  | ( %s, %s, %s )\n", tablaTerceto[i].indice, tablaTerceto[i].dato1, tablaTerceto[i].dato2, tablaTerceto[i].dato3);
	}

	fclose(ts);
	fclose(intermedia);
}


/*  **********************************************
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

	imprimirColaCodeASM(codAssembler);
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
  char buffer[20];
  char buffer2[20];

	for(i = 0; i < numeroId; i++) {
		strcpy(subfijo, "_");
		fprintf(arch, "\t%s\t%s\t%s", strcat(subfijo, ((strstr(tablaId[i].tipo, "CONST_STRING")!= NULL )?sacarComillas(tablaId[i].valor, cadena):(tablaId[i].nombre))), 
                                        (strstr(tablaId[i].tipo, "CONST_STRING")!= NULL ? "db" : "dd"), tablaId[i].valor);

		strcpy(buffer, ", ");
		fprintf(arch, "%s\n" , (strstr(tablaId[i].tipo, "CONST_STRING")!= NULL ? strcat(buffer, tablaId[i].longitud) : ""));
	}
	
	for(i = 0; i < numeroTerceto; i++) {
		sprintf(subfijo, "@aux%d", i);
		fprintf(arch, "\t%s\tdd\t?\n", subfijo);
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
	fprintf(arch, "\t\tmov AX,@DATA\n");
	fprintf(arch, "\t\tmov DS,AX\n");
	fprintf(arch, "\t\tmov es,ax\n");
	fprintf(arch, "; **********************************\n");

}
void recorrerTercetos(FILE *arch) 
{
	for(indiceTerceto = 0; indiceTerceto < numeroTerceto; indiceTerceto++)
	{	
		if(((strcmp("=", tablaTerceto[indiceTerceto].dato1) == 0) && (tipoElemento(tablaTerceto[indiceTerceto].dato2) < 4)) && strcmp(tablaTerceto[indiceTerceto].dato2, "auxFiltro") != 0) { // ES UNA CONSTANTe
			printf("SALTER CONSTANTE: %d , %s , %s , %s\n", tablaTerceto[indiceTerceto].indice, tablaTerceto[indiceTerceto].dato1, tablaTerceto[indiceTerceto].dato2, tablaTerceto[indiceTerceto].dato3);
			continue;
		}
		
		fprintf(arch, "ETQ_%d:\n", tablaTerceto[indiceTerceto]);
		
		if(strcmp(tablaTerceto[indiceTerceto].dato2, "auxFiltro") == 0){			
			crearAuxFiltro(arch);
			continue;
		}
		
		if(strcmp(tablaTerceto[indiceTerceto].dato2, "--") == 0 && strcmp(tablaTerceto[indiceTerceto].dato3, "--") == 0)
		{
			printf("CREAR VALOR - %d\n", indiceTerceto);
			crearValor(arch);
			continue;

		}
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "ADD") == 0)
		{
			printf("CREAR ADD - %d\n", indiceTerceto);
			crearFADD(arch);
			continue;
		}

		if(strcmp(tablaTerceto[indiceTerceto].dato1, "SUB") == 0)
		{
			printf("CREAR SUB - %d\n", indiceTerceto);
			crearFSUB(arch);
			continue;
		}

		
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "MUL") == 0){
			printf("CREAR MUL - %d\n", indiceTerceto);
			crearFMUL(arch);
			continue;
		}

		if(strcmp(tablaTerceto[indiceTerceto].dato1, "DIV") == 0)
		{
			printf("CREAR DIV - %d\n", indiceTerceto);
			crearFDIV(arch);
			continue;
		}
				if(esSalto(tablaTerceto[indiceTerceto].dato1) == 1) {
			crearSalto(arch);
		}

		if(strcmp(tablaTerceto[indiceTerceto].dato1, "=") == 0){
			printf("CREAR ASIG - %d\n", indiceTerceto);
			crearASIG(arch);
			continue;
		}


		if(strcmp(tablaTerceto[indiceTerceto].dato1, "CMP") == 0){
			printf("CREAR CMP - %d\n", indiceTerceto);
			crearCMP(arch);
			continue;
		}
			
		if(esSalto(tablaTerceto[indiceTerceto].dato1) == 1) {
			printf("CREAR SALTO - %d\n", indiceTerceto);
			crearSalto(arch);
			continue;
		}
		
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "input") == 0) {
			printf("CREAR INPUT - %d\n", indiceTerceto);
			crearINPUT(arch);
			continue;
		}
		if(strcmp(tablaTerceto[indiceTerceto].dato1, "output") == 0) {
			printf("CREAR OUTPUT - %d\n", indiceTerceto);
			crearOUTPUT(arch);
			continue;
		}
		
		if(strcmp(tablaTerceto[indiceTerceto].dato1, ";ETQ_REPEAT") == 0) {
			printf("CREAR REPEAT - %d\n", indiceTerceto);
			crearRepeat(arch);
			continue;
		}
		
	}

	fprintf(arch, "ETQ_%d:\n", indiceTerceto);

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


void imprimirColaCodeASM(FILE *arch) 
{
	fprintf(arch, "ETQ_%d:\n", indiceTerceto);
	fprintf(arch, "\t\tmov ax, 4C00h\n");
	fprintf(arch, "\t\tint 21h\n");
	fprintf(arch, "END START");
}

void crearValor(FILE *arch)
{
	char buffer[50] = "_";
	char p[10] = "FLD ";
	if(tablaTerceto[indiceTerceto].dato1[0] >= 'A' && tablaTerceto[indiceTerceto].dato1[0] <= 'z') {
		crearInstruccion(arch, "\t", "FLD", strcat(buffer, tablaId[existeID(tablaTerceto[indiceTerceto].dato1)].nombre), "");
		sprintf(buffer, "@aux%d", indiceTerceto);
		crearInstruccion(arch, "\t", "FSTP", buffer, "");		
	} else {
		crearInstruccion(arch, "\t", "FLD", strcat(buffer, tablaId[buscarPorValor(tablaTerceto[indiceTerceto].dato1)].nombre), "");
		sprintf(buffer, "@aux%d", indiceTerceto);
		crearInstruccion(arch, "\t", "FSTP", buffer, "");
	}
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
	char subfijo[50];
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato2));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	crearInstruccion(pf, "\t", "FADD", "", "");
	sprintf(subfijo, "@aux%d", tablaTerceto[indiceTerceto].indice);
	crearInstruccion(pf, "\t", "FSTP", subfijo, "");
	crearInstruccion(pf, "\t", "FFREE", "", "");
	

}

void crearFSUB(FILE *pf)
{
	char subfijo[50];	
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato2));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));
	crearInstruccion(pf, "\t", "FSUB", subfijo, "");
	sprintf(subfijo, "@aux%d", tablaTerceto[indiceTerceto].indice);
	crearInstruccion(pf, "\t", "FSTP", subfijo, "");	
}

void crearFMUL(FILE *pf)
{
	char subfijo[50];
	
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato2));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));
	crearInstruccion(pf, "\t", "FMUL", subfijo, "");
	sprintf(subfijo, "@aux%d", tablaTerceto[indiceTerceto].indice);
	crearInstruccion(pf, "\t", "FSTP", subfijo, "");	
	
}

void crearFDIV(FILE *pf)
{	
	char subfijo[50];
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato2));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));
	crearInstruccion(pf, "\t", "FDIV", subfijo, "");
	sprintf(subfijo, "@aux%d", tablaTerceto[indiceTerceto].indice);
	crearInstruccion(pf, "\t", "FSTP", subfijo, "");	
}

void crearASIG(FILE *arch){
	char buffer[50] = "_";
	char p[10] = "FLD ";	
	
	if(tablaTerceto[indiceTerceto].dato3[0] >= 'A' && tablaTerceto[indiceTerceto].dato3[0] <= 'z') {
		crearInstruccion(arch, "\t", "FLD", strcat(buffer, tablaId[existeID(tablaTerceto[indiceTerceto].dato3)].nombre), "");
		strcpy(buffer, "_");
		crearInstruccion(arch, "\t", "FSTP", strcat(buffer, tablaTerceto[indiceTerceto].dato2), "");		
	} else {
		crearInstruccion(arch, "\t", "FLD", strcat(buffer, tablaId[buscarPorValor(tablaTerceto[indiceTerceto].dato3)].nombre), "");
		strcpy(buffer, "_");
		crearInstruccion(arch, "\t", "FSTP", strcat(buffer, tablaTerceto[indiceTerceto].dato2), "");
	}
}


void crearAuxFiltro(FILE *arch){
	char buffer[50];
	char p[10] = "FLD ";	
	sprintf(buffer, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));	
	crearInstruccion(arch, "\t", "FLD", buffer, "");
	strcpy(buffer, "_");
	crearInstruccion(arch, "\t", "FSTP", strcat(buffer, tablaTerceto[indiceTerceto].dato2), "");
}

void crearCMP(FILE *pf){
	char subfijo[50];
	
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato2));
	crearInstruccion(pf, "\t", "FLD", subfijo, "");
	sprintf(subfijo, "@aux%d", leerIndiceTercero(tablaTerceto[indiceTerceto].dato3));
	crearInstruccion(pf, "\t", "FCOMP", subfijo, "");
	crearInstruccion(pf, "\t", "FSTSW", "ax", "");
	crearInstruccion(pf, "\t", "SAHF", "", "");	
	printf("FIN CMP\n");	
}

void crearRepeat(FILE *pf){
	crearInstruccion(pf, "\t", tablaTerceto[indiceTerceto].dato1, "", "");
}


int tipoElemento(char *elemento)
{
  int i = 0;
  char auxVal[35] = "_";
  while(i < 2048)
  {
    if(strcmp(elemento, tablaId[i].valor) == 0){//es una constante
      if(strcmp(tablaId[i].tipo, "CONST_INT") == 0){
		  printf("\t\tCONST_INT\n");
        return 1;
      }else{
        if(strcmp(tablaId[i].tipo, "CONST_FLOAT") == 0){
			printf("\t\tCONST_FLOAT\n");
          return 2;
        }else{
			if(strcmp(tablaId[i].tipo, "CONST_STRING") == 0){
				printf("\t\tCONST_STRING\n");
				return 3;
          }
        }
      }
    }else{
		if(strcmp(tablaId[i].valor, "?") == 0){//Es una variable
			if(strcmp(tablaId[i].nombre, elemento) == 0){
				if(strcmp(tablaId[i].tipo, "INTEGER") == 0){
					printf("\t\tINTEGER\n");
					return 4;
				}else{
					if(strcmp(tablaId[i].tipo, "FLOAT") == 0){
						printf("\t\tFLOAT\n");
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
	char saltos[9][10] = {"JE", "JNE", "JNAE", "JNA", "JNBE", "JNB", "JZ", "JNZ", "JMP"};
	int i;
	for(i = 0; i < 9; i++) {
		if(strcmp(instruccion, saltos[i]) == 0) {
			return 1;
		}		
	}	
	return 0;
}

void crearSalto(FILE *arch) {
	/***** REVISAR *****/
	char *cad;
	char buffer[20];
	int i;
	cad = strchr(tablaTerceto[indiceTerceto].dato2,'[');
	cad+=2; 
	
	sprintf(buffer, "ETQ_%d", atoi(cad));
	crearInstruccion(arch, "\t", tablaTerceto[indiceTerceto].dato1, buffer, "");
}


void crearOUTPUT(FILE *arch) {
	char subfijo[50] = "";

	if(tipoElemento(tablaTerceto[indiceTerceto].dato2) == 3) { //SI ES STRING
		crearInstruccion(arch, "\t", "displayString", strcat(subfijo, tablaId[buscarPorValor(tablaTerceto[indiceTerceto].dato2)].nombre), "");
	}
	else {
		crearInstruccion(arch, "\t", "DisplayFloat", strcat(subfijo, tablaId[existeID(tablaTerceto[indiceTerceto].dato2)].nombre), ", 2");
	}	
	crearInstruccion(arch, "\t", "newLine", "", "");	
}

void crearINPUT(FILE *arch) {//////////////////////////////////////
	char subfijo[50] = "_";	
	
	crearInstruccion(arch, "\t", "GetFloat", strcat(subfijo, tablaId[existeID(tablaTerceto[indiceTerceto].dato2)].nombre), "");
	
}	

void crearInstruccion(FILE *pf,char *c1,char *c2,char *c3, char *c4){

	fprintf(pf, "%s\t%s\t%s\t%s\n", c1, c2, c3, c4);
}


char *sacarComillaConst(char *val, char *esc){
	int i;
	char *sal = esc;
    for (i=0; val[i] != '\0';i++)
    {
        if (val[i] != '\"')
        {
            *esc = val[i];
            esc++;
        }
    }
    *(esc) = '\0';
    return sal;
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

int leerIndiceTercero(char *dato){	
	char *puntero;
	puntero = strrchr(dato, '[');	
	return atoi(puntero+2);
}


