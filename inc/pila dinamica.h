#ifndef PILA_DINAMICA_H_INCLUDED
#define PILA_DINAMICA_H_INCLUDED

/* declaracion */
struct tpila{
  int clave;
  struct tpila *sig;
};

/* prototipos e implementacion */
int crearPila(struct tpila **pila);
int pilaVacia(struct tpila *pila);
void apilar(struct tpila *pila, int elem);
int desapilar(struct tpila *pila);

void mostrarPila(struct tpila *pila);


#endif // PILA_DINAMICA_H_INCLUDED
