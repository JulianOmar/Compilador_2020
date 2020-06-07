%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "y.tab.h"
FILE  *yyin;

int cota_error(char* mensaje);
void insertarEnTabla(char*,char*,char*,int,double);

%}
%option noyywrap
%option yylineno

DIGITO			[0-9]
LETRA			[a-zA-Z]
CARACTER		[^"-""/"]

ID				{LETRA}({LETRA}|{DIGITO}|_)*
COMENTARIO  	("--/")({CARACTER})*("--/"({CARACTER})*"/--")?({CARACTER})*("/--")


CTE_E		(-?)([1-9])({DIGITO})*
CTE_R		(-?)({DIGITO})*"."({DIGITO})*
CTE_S 		\".*\"

%%
"REPEAT"		{ printf("REPEAT\n"); 		return C_REPEAT_A; }
"UNTIL"			{ printf("UNTIL");			return C_REPEAT_C; }
"IF"			{ printf("IF");				return C_IF_A; }
"ELSE"			{ printf("ELSE");			return C_IF_E; }

"FILTER"		{ printf("FILTER");			return C_FILTER; }
"_"				{ printf("_");				return C_FILTER_REFENTEROS; }

"PRINT"			{ printf("PRINT");			return PRINT; }
"READ"			{ printf("READ");			return READ; }


"VAR"			{ return VAR; }
"ENDVAR"		{ return ENDVAR; }
"CONST"			{ printf("CONST"); 			return CONST; }
"Integer"		{ printf("Integer");		return INTEGER; }
"Float"			{ printf("Float");			return FLOAT; }
"String"		{ printf("String");			return STRING; }


"="			{ printf("=");				return OP_ASIG;}
"+"			{ printf("+");				return OP_SUMA;}
"-"			{ printf("-");				return OP_RESTA;}
"*"			{ printf("*");				return OP_MUL;}
"/"			{ printf("/");				return OP_DIV;}

"("			{ printf("(");				return PARENTESIS_A;}
")"			{ printf(")");				return PARENTESIS_C;}
"{"			{ printf("{");				return LLAVE_A;}
"}"			{ printf("}");				return LLAVE_C;}
"["			{ printf("[");				return CORCHETE_A; }
"]"			{ printf("]");				return CORCHETE_C; }
","			{ printf(",");				return COMA; }
";"			{ printf(";");				return PYC; }
":"			{ printf(":");				return DOSPUNTOS; }

"=="		{ printf("=="); 	return OP_IGUAL;}
"!=="		{ printf("!=="); 	return OP_DISTINTO;}
"<"			{ printf("<"); 		return OP_MENOR;}
"<="		{ printf("<="); 	return OP_MENORIGUAL;}
">"			{ printf(">"); 		return OP_MAYOR;}
">="		{ printf(">=");		return OP_MAYORIGUAL;}
"AND"		{ printf("AND");	return OP_LOGICO_AND;}
"OR"		{ printf("OR");		return OP_LOGICO_OR;}
"!"			{ printf("!");		return OP_NEGACION; }

{ID}			{
					yylval.str_val = yytext;
					printf( "ID(%s)", yylval.str_val);
					return ID;
				}
{CTE_E}			{ 	if(atoi(yytext)<=32767 && atoi(yytext)>=-32768)
					{
						yylval.intval = atoi(yytext);
						printf( "ENTERO(%d)", yylval.intval);
						/*insertarEnTabla("","CONST_INT","--",yylval.intval,0);*/
						return CTE_E;
					}
					cota_error("Variable Entera supera limite permitido");
				}
{CTE_R}			{
					if(atof(yytext)<=2147483647 && atof(yytext)>=-2137483648)
					{
						yylval.val = atof(yytext);
						printf( "FLOAT(%f)", yylval.val);
						/*insertarEnTabla("","CONST_REAL","--",0,yylval.val);*/
						return CTE_R;
					}
					cota_error("Variable Real supera limite permitido");
				}
{CTE_S}			{
					if(strlen(yytext)<=32){ /* TAMBIEN CUENTA LAS COMILLAS; SON 2 COMILLAS + 30 CARACTERES */
						yylval.str_val = yytext;
						printf( "STRING(%s)", yylval.str_val);
						/*insertarEnTabla(yylval.str_val,"CONST_STR",yylval.str_val,0,0);*/
						return CTE_S;
					}
					cota_error("Constante String supera Maximo 30 caracteres.");
				}
{COMENTARIO}	{ printf("/* LINEA DE COMENTARIOS */"); }
[\t{1}]			{ printf("\t"); }		/* NO RETORNA TOKEN */
[\n{1}]			{ printf("\n"); }		/* NO RETORNA TOKEN */
[" "{1}]		{ printf(" "); }		/* NO RETORNA TOKEN */

"\n"
"\t"
%%

int cota_error(char* mensaje)
{
	printf("\n\nError lexico: %s\n", mensaje);
	system ("Pause");
	exit (1);
}
