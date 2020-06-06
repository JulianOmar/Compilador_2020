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


CTE_E			(-?)([1-9])({DIGITO})*
CTE_R			(-?)({DIGITO})*"."({DIGITO})*
CTE_S 			\".*\"

%%
"REPEAT"		{return C_REPEAT_A; }
"UNTIL"			{return C_REPEAT_C; }
"IF"			{return C_IF_A; }
"ELSE"			{return C_IF_E; }

"FILTER"		{return C_FILTER; }
"_"				{return C_FILTER_REFENTEROS; }

"PRINT"			{ return PRINT; }
"READ"			{ return READ; }


"VAR"			{ return VAR; }
"ENDVAR"		{ return ENDVAR; }
"CONST"			{ return CONST; }
"Integer"		{ return INTEGER; }
"Float"			{ return FLOAT; }
"String"		{ return STRING; }


"="				{ return OP_ASIG;}
"+"				{ return OP_SUMA;}
"-"				{ return OP_RESTA;}
"*"				{ return OP_MUL;}
"/"				{ return OP_DIV;}

"("				{ return PARENTESIS_A;}
")"				{ return PARENTESIS_C;}
"{"				{ return LLAVE_A;}
"}"				{ return LLAVE_C;}
"["				{ return CORCHETE_A; }
"]"				{ return CORCHETE_C; }
","				{ return COMA; }
";"				{ return PYC; }
":"				{ return DOSPUNTOS; }

"=="			{ return OP_IGUAL;}
"!=="			{ return OP_DISTINTO;}
"<"				{ return OP_MENOR;}
"<="			{ return OP_MENORIGUAL;}
">"				{ return OP_MAYOR;}
">="			{ return OP_MAYORIGUAL;}
"AND"			{ return OP_LOGICO_AND;}
"OR"			{ return OP_LOGICO_OR;}
"!"				{ return OP_NEGACION; }

{ID}			{
					yylval.str_val = yytext;
					return ID;
				}
{CTE_E}			{ 	if(atoi(yytext)<=32767 && atoi(yytext)>=-32768)
					{
						yylval.intval = atoi(yytext);
						/*insertarEnTabla("","CONST_INT","--",yylval.intval,0);*/
						return CTE_E;
					}
					cota_error("Variable Entera supera limite permitido");
				}
{CTE_R}			{
					if(atof(yytext)<=2147483647 && atof(yytext)>=-2137483648)
					{
						yylval.val = atof(yytext);						
						/*insertarEnTabla("","CONST_REAL","--",0,yylval.val);*/
						return CTE_R;
					}
					cota_error("Variable Real supera limite permitido");
				}
{CTE_S}			{
					if(strlen(yytext)<=32){ /* TAMBIEN CUENTA LAS COMILLAS; SON 2 COMILLAS + 30 CARACTERES */
						yylval.str_val = yytext;
						/*insertarEnTabla(yylval.str_val,"CONST_STR",yylval.str_val,0,0);*/
						return CTE_S;
					}
					cota_error("Constante String supera Maximo 30 caracteres.");
				}
{COMENTARIO}	{  }
[\t{1}]			{  }		/* NO RETORNA TOKEN */
[\n{1}]			{  }		/* NO RETORNA TOKEN */
[" "{1}]		{  }		/* NO RETORNA TOKEN */

"\n"
"\t"
%%

int cota_error(char* mensaje)
{
	printf("\n\nError lexico: %s\n", mensaje);
	system ("Pause");
	exit (1);
}
