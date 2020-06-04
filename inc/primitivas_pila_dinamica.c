#include "primitivas_pila_dinamica.h"

//no sé por qué si no pongo las bibliotecas acá me tira error
#include<stdio.h>
#include<stdlib.h>

void crearPila(t_pila *p)
{
    *p=NULL;
}

int pila_llena(const t_pila *p)
{
    void *aux=malloc(sizeof(t_nodo));
    free(aux);
    return aux==NULL;
}

int apilar(t_pila *p,const int d)
{
    t_nodo *nuevo=(t_nodo*)malloc(sizeof(t_nodo));
    if(!nuevo)
        return MEMORIA_LLENA;
    nuevo->dato=d;
    nuevo->sig=*p;
    *p=nuevo;
    return OK;
}

int pila_vacia(const t_pila *p)
{
    return *p==NULL;
}

int desapilar(t_pila *p)
{
	int d;
	
    if(*p==NULL)
        return PILA_VACIA;
    t_nodo *aux=*p;
    d=(*p)->dato;//*d=aux->dato;
    *p=aux->sig;//*p=(*p)->sig;
    free(aux);
    return d;
}

int ver_tope(const t_pila *p,int d)
{
    if(*p==NULL)
        return PILA_VACIA;
    d=(*p)->dato;
    return OK;
}

void vaciar_pila(t_pila *p)
{
    t_nodo *aux;
    while(*p)
    {
        aux=*p;
        *p=aux->sig;
        free(aux);
    }
}

void mostrarPila(t_pila pila)
{

	t_nodo *aux = pila;
	int valor;
  
	printf("\n----------PILA-----------");
  
	while (aux != NULL){
        valor = aux->dato;  
        printf("\n Elemento: %d", valor);
        aux = aux->sig;
        }
    printf("\n--------FIN DE PILA---------\n\n");
}